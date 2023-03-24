//
//  Compression.swift
//  
//
//  Created by Serena on 21/10/2022
//

import Foundation
@_implementationOnly
import libarchiveBridge

enum CompressionErrors: Swift.Error, LocalizedError, CustomStringConvertible {
    case failedToCopyData(description: String)
    case failedToExtract(description: String, line: Int = #line)
    case failedToArchive(dsecription: String)
    
    var description: String {
        switch self {
        case .failedToCopyData(let description):
            return "Failed to copy data: \(description)"
        case .failedToExtract(let description, let line):
            #if DEBUG
            return "Failed to extract file: \(description) (line: \(line))"
            #else
            return "Failed to extract file: \(description)"
            #endif
        case .failedToArchive(let description):
            return "Error while archiving: \(description)"
        }
    }
    
    var errorDescription: String? {
        description
    }
}

public struct ArchiveOptions: OptionSet {
    public let rawValue: CInt
    
    public init(rawValue: CInt) {
        self.rawValue = rawValue
    }
    
    public static let restoreOwner =            ArchiveOptions(rawValue: ARCHIVE_EXTRACT_OWNER)
    public static let restorePermissions =      ArchiveOptions(rawValue: ARCHIVE_EXTRACT_PERM)
    public static let restoreTime =             ArchiveOptions(rawValue: ARCHIVE_EXTRACT_TIME)
    public static let dontOverwite =            ArchiveOptions(rawValue: ARCHIVE_EXTRACT_NO_OVERWRITE)
    public static let unlink =                  ArchiveOptions(rawValue: ARCHIVE_EXTRACT_UNLINK)

    public static let restoreACLs =             ArchiveOptions(rawValue: ARCHIVE_EXTRACT_ACL)
    public static let restoreFFLags =           ArchiveOptions(rawValue: ARCHIVE_EXTRACT_FFLAGS)
    public static let restoreXattrs =           ArchiveOptions(rawValue: ARCHIVE_EXTRACT_XATTR)
    public static let secureSymlinks =          ArchiveOptions(rawValue: ARCHIVE_EXTRACT_SECURE_SYMLINKS)
    public static let secureNoDotDot =          ArchiveOptions(rawValue: ARCHIVE_EXTRACT_SECURE_NODOTDOT)
    public static let dontCreateParentDirs =    ArchiveOptions(rawValue: ARCHIVE_EXTRACT_NO_AUTODIR)
    public static let sparse =                  ArchiveOptions(rawValue: ARCHIVE_EXTRACT_SPARSE)
    public static let includeMacOSMetadata =    ArchiveOptions(rawValue: ARCHIVE_EXTRACT_MAC_METADATA)
    public static let dontUseHFSCompression =   ArchiveOptions(rawValue: ARCHIVE_EXTRACT_NO_HFS_COMPRESSION)
    public static let forceUseHFSCompression =  ArchiveOptions(rawValue: ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED)
    public static let rejectAbsolutePaths =     ArchiveOptions(rawValue: ARCHIVE_EXTRACT_SECURE_NOABSOLUTEPATHS)
}

public class Compression {
    public static let shared = Compression()
    
    private init() {}
    
    public func extract(
        path compressedFile: URL,
        to destination: URL,
        options: ArchiveOptions = [.restoreTime, .restorePermissions, .restoreACLs, .restoreFFLags]
    ) throws {
        let flags = options.rawValue
        
        let a = archive_read_new()
        archive_read_support_format_all(a)
        archive_read_support_filter_all(a)
        
        let ext = archive_write_disk_new()
        archive_write_disk_set_options(ext, flags)
        
        let archiveEntry = archive_entry_new()
        var r: CInt = 0
        
        defer {
            archive_read_close(a)
            archive_read_free(a)
            archive_write_close(ext)
            archive_write_free(ext)
        }
        
        try compressedFile.withUnsafeFileSystemRepresentation { fsRepresentation in
            guard let fsRepresentation = fsRepresentation,
                  archive_read_open_filename(a, fsRepresentation, 10240) == ARCHIVE_OK else {
                throw CompressionErrors.failedToExtract(description: "Failed to open compressed archive \(compressedFile.path)")
            }
        }
        
        while true {
            r = archive_read_next_header2(a, archiveEntry)
            if r == ARCHIVE_EOF { break } // we're done here.
            
            if r < ARCHIVE_OK {
                throw CompressionErrors.failedToExtract(description: .archiveError(for: a))
            }
            
            let currentPathBeingProcessed = archive_entry_pathname(archiveEntry)!
            let fullOutputPath = destination.appendingPathComponent(String(cString: currentPathBeingProcessed))
            fullOutputPath.withUnsafeFileSystemRepresentation { fsRepresentation in
                archive_entry_set_pathname(archiveEntry, fsRepresentation)
            }
            
            r = archive_write_header(ext, archiveEntry)
            if (r < ARCHIVE_OK) {
                throw CompressionErrors.failedToExtract(description: .archiveError(for: ext))
            }
            
            if archive_entry_size(archiveEntry) > 0 {
                try copyData(ar: a, aw: ext)
            }
            
            r = archive_write_finish_entry(ext)
            if (r < ARCHIVE_OK) {
                throw CompressionErrors.failedToExtract(description: .archiveError(for: ext))
            }
            
        }
    }
    
    /// Compresses the paths given (alongside their subdirectories)  to the given outputPath.
    /// The process handler is called on every URL which gets processed, hence the name
    public func compress(paths: [URL], outputPath: URL, format: FormatType, processHandler: ((URL) -> Void)? = nil) throws {
        let a = archive_write_new()
        var entry: OpaquePointer? = nil
        let buff = UnsafeMutableRawPointer.allocate(byteCount: 8192, alignment: 4)
        var st: stat = stat()
        var fd: CInt = 0
        var len: Int = 0
        
        archive_write_add_filter_gzip(a)
        format.apply(to: a)
        try outputPath.withUnsafeFileSystemRepresentation { fsRepresentation in
            guard archive_write_open_filename(a, fsRepresentation) == ARCHIVE_OK else {
                throw CompressionErrors.failedToArchive(dsecription: "Unable to open a destination to destination path \(outputPath.path)")
            }
        }
        
        func _archiveIndividiualPath(_ path: URL) throws {
            try path.withUnsafeFileSystemRepresentation { fsRepresentation in
                guard let fsRepresentation = fsRepresentation else {
                    throw CompressionErrors.failedToArchive(dsecription: "Path \(path.path) is an invalid path (Cannot generate filesystem representation).")
                }
                
                processHandler?(path)
                guard stat(fsRepresentation, &st) == 0 else {
                    throw CompressionErrors.failedToArchive(dsecription: "Failed to stat (get information of) path \(path.path): \(String.errnoString())")
                }
                
                let attrs = try FileManager.default.attributesOfItem(atPath: path.path)
                guard let type = attrs[.type] as? FileAttributeType, let existingPosixPermissions = attrs[.posixPermissions] as? mode_t else {
                    throw CompressionErrors.failedToArchive(dsecription: "Unable to get type or permissions of path \(path.path): \(String.errnoString()))")
                }
                
                entry = archive_entry_new()
                archive_entry_set_pathname(entry, path.relativePath(from: outputPath))
                
                let archiveType = try __archiveTypeConstant(forPathType: type, path: path)
                archive_entry_set_size(entry, st.st_size)
                archive_entry_set_filetype(entry, CUnsignedInt(archiveType))
                
                archive_entry_set_perm(entry, existingPosixPermissions)
                guard archive_write_header(a, entry) == ARCHIVE_OK else {
                    throw CompressionErrors.failedToArchive(dsecription: "Failed to write header of path \(path.path): \(String.archiveError(for: a))")
                }
                
                fd = open(fsRepresentation, O_RDONLY)
                guard fd != -1 else {
                    throw CompressionErrors.failedToArchive(dsecription: "Failed to open file \(path.path): \(String.errnoString())")
                }
                
                len = read(fd, buff, MemoryLayout.stride(ofValue: buff))
                while len > 0 {
                    archive_write_data(a, buff, len)
                    len = read(fd, buff, MemoryLayout.stride(ofValue: buff))
                }
                
                close(fd)
                archive_entry_free(entry)
            }
        }
        
        let allPaths = paths.flatMap { path in
            let isDir = (try? path.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            if isDir, let enumerator = FileManager.default.enumerator(at: path, includingPropertiesForKeys: nil) {
                return enumerator.allObjects as? [URL] ?? []
            } else {
                return [path]
            }
        }
        
        for path in allPaths {
            try _archiveIndividiualPath(path)
        }
        
        archive_write_close(a)
        archive_write_free(a)
    }
    
    private func copyData(ar: OpaquePointer?, aw: OpaquePointer?) throws {
        var r: CInt = 0
        var size = 0
        var buffer: UnsafeRawPointer? = nil
        var offset: la_int64_t = 0
        
        while true {
            r = archive_read_data_block(ar, &buffer, &size, &offset)
            if r == ARCHIVE_EOF { break } // we're done here.
            // libarchive didn't return an okay status, throw error
            if r < ARCHIVE_OK {
                throw CompressionErrors.failedToCopyData(description: "Error occured while trying to read data block: \(String.archiveError(for: ar))")
            }
            
            
            r = CInt(archive_write_data_block(aw, buffer, Int(size), offset))
            if r < ARCHIVE_OK {
                throw CompressionErrors.failedToCopyData(description: "Failed to write data block: \(String.archiveError(for: aw))")
            }
        }
    }
    
    public enum FormatType: CaseIterable, CustomStringConvertible {
        case zip
        case tar
//        case sevenZip
        
        internal func apply(to a: OpaquePointer?) {
            switch self {
            case .zip:
                archive_write_set_format_zip(a)
            case .tar:
                archive_write_set_format_gnutar(a)
            }
        }
        
        public var fileExtension: String {
            switch self {
            case .zip:
                return "zip"
            case .tar:
                return "tar"
            }
        }
        
        public var description: String {
            switch self {
            case .zip:
                return "Zip"
            case .tar:
                return "Tar"
            }
        }
    }
}


fileprivate extension URL {
    func relativePath(from base: URL) -> String {
        
        //this is the new part, clearly, need to use workBase in lower part
        let workBase = base        
        // Remove/replace "." and "..", make paths absolute:
        let destComponents = self.standardized.resolvingSymlinksInPath().pathComponents
        let baseComponents = workBase.standardized.resolvingSymlinksInPath().pathComponents
        
        // Find number of common path components:
        var i = 0
        while i < destComponents.count &&
                i < baseComponents.count &&
                destComponents[i] == baseComponents[i] {
            i += 1
        }
        
        return destComponents[i...].joined(separator: "/")
    }
    
}

fileprivate func __archiveTypeConstant(forPathType pathType: FileAttributeType, path: URL) throws -> CInt {
    switch pathType {
    case .typeRegular:
        return AE_IFREG
    case .typeDirectory:
        return AE_IFDIR
    case .typeSymbolicLink:
        return AE_IFLNK
    case .typeBlockSpecial:
        return AE_IFBLK
    case .typeSocket:
        return AE_IFSOCK
    case .typeCharacterSpecial:
        return AE_IFCHR
    default:
        throw CompressionErrors.failedToArchive(dsecription: "Unknown type of path \(path.path)")
    }
}

fileprivate extension String {
    // the following functions are here just to make code above clearer
    static func errnoString(_ errnoNumber: CInt = errno) -> String {
        return String(cString: strerror(errnoNumber))
    }
    
    static func archiveError(for archive: OpaquePointer?) -> String {
        return String(cString: archive_error_string(archive))
    }
}
