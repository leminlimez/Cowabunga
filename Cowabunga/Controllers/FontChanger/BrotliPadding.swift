import Compression
import Foundation

enum PackageInBrotliError: Error {
  case notEnoughSpaceForHeader
}

/// Stores the input data in a Brotli stream: does not compress, only store.
/// Pads the last byte of every 16k boundary with 0x41.
func packageInBrotliSkippingLastByteOfPage(input: Data, startingAddress: Int) throws -> Data {
  // https://datatracker.ietf.org/doc/html/rfc7932#section-11.1
  let pageSize = 0x4000
  var currentPageOff = startingAddress & (pageSize - 1)
  // Check for the one case we can't pad around: we start near the end of the page and
  // there's not enough space to pad out the last byte
  let streamHeaderSize = 1
  let metablockHeaderSize = 3
  let metablockPaddingHeaderSize = 2
  let reserveEndSpace = metablockPaddingHeaderSize + 1
  if pageSize - currentPageOff < (streamHeaderSize + reserveEndSpace) {
    throw PackageInBrotliError.notEnoughSpaceForHeader
  }
  let outStream: OutputStream = OutputStream.toMemory()
  outStream.open()
  func write(_ bytes: [UInt8]) {
    outStream.write(bytes, maxLength: bytes.count)
  }
  // stream header
  // WBITS = 18 (encoded as 0011 with little-endian bits)
  write([0b1100])
  currentPageOff += 1
  var inputOff = 0
  while inputOff < input.count {
    var remainingSpace = pageSize - currentPageOff
    if remainingSpace > metablockHeaderSize + reserveEndSpace {
      let dataSize = min(
        remainingSpace - reserveEndSpace - metablockHeaderSize, input.count - inputOff)
      let isLast = 0
      let mNibbles = 0b00  // encoded = 4 nibbles
      let mLenEncoded = dataSize - 1
      // x | xx | 01234
      let firstByte = isLast | (mNibbles << 1) | ((mLenEncoded & 0b11111) << 3)
      // 56789abc
      let secondByte = (mLenEncoded >> 5) & 0xff

      let isUncompressed = 1
      // def | x
      let thirdByte = (mLenEncoded >> 13) & 0b111 | (isUncompressed << 3)
      write([UInt8(firstByte), UInt8(secondByte), UInt8(thirdByte)])
      write([UInt8](input[inputOff..<inputOff + dataSize]))

      inputOff += dataSize
      remainingSpace -= metablockHeaderSize + dataSize
    }
    if !(inputOff < input.count) {
      break  // don't bother with padding, just end stream
    }
    // write padding
    do {
      let dataSize = remainingSpace - metablockPaddingHeaderSize
      let isLast = 0
      let mNibbles = 0b11  // 0 nibbles, represented as 11
      let mSkipBytes = 1
      let mSkipLenEncoded = dataSize - 1
      // x | xx | R | xx | 01
      let firstByte = isLast | (mNibbles << 1) | (mSkipBytes << 4) | ((mSkipLenEncoded & 0b11) << 6)
      // 234567
      let secondByte = (mSkipLenEncoded >> 2) & 0b111111
      write([UInt8(firstByte), UInt8(secondByte)])
      let paddingData = [UInt8](repeating: 0x41, count: dataSize)
      write(paddingData)
    }
    currentPageOff = 0
  }
  // write eod-of-stream
  write([0b11])
  return outStream.property(forKey: .dataWrittenToMemoryStreamKey) as! Data
}

// everything is big endian!
struct Woff2Header {
  // https://www.w3.org/TR/WOFF2/#woff20Header
  var signature: UInt32
  var flavor: UInt32
  var length: UInt32
  var numTables: UInt16
  var reserved: UInt16
  var totalSfntSize: UInt32
  var totalCompressedSize: UInt32
  var majorVersion: UInt16
  var minorVersion: UInt16
  var metaOffset: UInt32
  var metaLength: UInt32
  var metaOrigLength: UInt32
  var privOffset: UInt32
  var privLength: UInt32
}

enum RepackWoff2FontError: Error {
  case malformedInputWoff
  case zhuoweiMessedUp
}

func repackWoff2Font(input: Data) throws -> Data {
  let tableStart = MemoryLayout<Woff2Header>.size
  let headerBytes = [UInt8](input[0..<tableStart])
  let header = headerBytes.withUnsafeBytes { $0.load(as: Woff2Header.self) }
  // skip
  var tableEnd = tableStart
  for _ in 0..<header.numTables.bigEndian {
    // https://www.w3.org/TR/WOFF2/#DataTypes
    // https://developers.google.com/protocol-buffers/docs/encoding#varints
    // https://www.w3.org/TR/WOFF2/#table_dir_format
    let flags = input[tableEnd]
    tableEnd += 1
    let tableId = flags & 0b11_1111
    if tableId == 0b11_1111 {
      tableEnd += 4
      // TODO(zhuowei): read tableId?
    }

    while (input[tableEnd] & 0b1000_0000) != 0 {
      tableEnd += 1
    }
    tableEnd += 1

    let glyfTableId = 10
    let locaTableId = 11
    if tableId == glyfTableId || tableId == locaTableId {
      while (input[tableEnd] & 0b1000_0000) != 0 {
        tableEnd += 1
      }
      tableEnd += 1
    }
  }
  // if this is a collection, we need more
  if header.flavor.bigEndian == 0x7474_6366 {
    func read255UShort() -> UInt16 {
      let oneMoreByteCode1 = 255
      let oneMoreByteCode2 = 254
      let wordCode = 253
      let lowestUCode = 253
      let first = input[tableEnd]
      var outNum: UInt16 = 0
      if first == wordCode {
        outNum = UInt16(input[tableEnd]) << 8 | UInt16(input[tableEnd])
        tableEnd += 2
      } else if first == oneMoreByteCode1 || first == oneMoreByteCode2 {
        outNum =
          UInt16(input[tableEnd])
          + UInt16(first == oneMoreByteCode1 ? lowestUCode : lowestUCode * 2)
        tableEnd += 1
      } else {
        outNum = UInt16(first)
      }
      tableEnd += 1
      return outNum
    }
    // version - skip
    tableEnd += 4
    let numCollectionFonts = read255UShort()
    for _ in 0..<numCollectionFonts {
      let numTables = read255UShort()  // numTables
      tableEnd += 4  // version
      for _ in 0..<numTables {
        _ = read255UShort()  // table index
      }
    }
  }

  // hack: we made a fake Brotli that just returns the uncompresssed input directly
  // so instead of compressed data we get the uncompressed data directly
  // (See repackfonts/BrotliPadding.swift for how to decode Brotli properly)
  let decodedData =
    input.subdata(in: tableEnd..<tableEnd + Int(header.totalCompressedSize.bigEndian))

  let recompressedData = try packageInBrotliSkippingLastByteOfPage(
    input: decodedData, startingAddress: tableEnd)

  // make the output
  var outputData = Data()
  var outputHeader = header
  let paddedLength = (tableEnd + recompressedData.count + 3) & ~3
  let padding = [UInt8](repeating: 0x0, count: paddedLength - (tableEnd + recompressedData.count))
  outputHeader.length = UInt32(tableEnd + recompressedData.count + padding.count).bigEndian
  outputHeader.totalCompressedSize = UInt32(recompressedData.count).bigEndian
  withUnsafeBytes(of: outputHeader) {
    outputData.append(contentsOf: $0)
  }
  outputData.append(input[tableStart..<tableEnd])
  outputData.append(recompressedData)
  outputData.append(contentsOf: padding)
  // verify
  for i in stride(from: 0x3fff, to: outputData.count, by: 0x4000) {
    guard outputData[i] == 0x41 else {
      throw RepackWoff2FontError.zhuoweiMessedUp
    }
  }
  return outputData
}
