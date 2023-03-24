//
//  String++.swift
//  Cowabunga
//
//  Created by sourcelocation on 22/02/2023.
//

import Foundation

extension StringProtocol {
    subscript(offset: Int) -> Character { self[index(startIndex, offsetBy: offset)] }
    subscript(range: Range<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: ClosedRange<Int>) -> SubSequence {
        let startIndex = index(self.startIndex, offsetBy: range.lowerBound)
        return self[startIndex..<index(startIndex, offsetBy: range.count)]
    }
    subscript(range: PartialRangeFrom<Int>) -> SubSequence { self[index(startIndex, offsetBy: range.lowerBound)...] }
    subscript(range: PartialRangeThrough<Int>) -> SubSequence { self[...index(startIndex, offsetBy: range.upperBound)] }
    subscript(range: PartialRangeUpTo<Int>) -> SubSequence { self[..<index(startIndex, offsetBy: range.upperBound)] }
}
