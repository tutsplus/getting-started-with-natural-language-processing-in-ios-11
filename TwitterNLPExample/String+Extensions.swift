//
//  String+Extensions.swift
//  TwitterNLPExample
//
//  Created by Doron Katz on 12/1/17.
//  Copyright © 2017 Doron Katz. All rights reserved.
//

import Foundation

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}
