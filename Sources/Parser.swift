//
//  Parser.swift
//  CSVParser
//
//  Created by Nero Zuo on 16/9/29.
//
//

import Foundation

extension String {
  // to split to lines
  func nzSplitLines(lineSeparator: String) -> [String] {
    let splitsSet = CharacterSet(charactersIn: lineSeparator)
    return self.utf16.split {
      splitsSet.contains(UnicodeScalar($0)!)
    }.flatMap(String.init)
  }
  
  // to split to elements
  func nzSplitElements(delimiter: Character) -> [String] {
    return self.utf16.split {
      return Character(UnicodeScalar($0)!) == delimiter
    }.flatMap(String.init)
  }
  
  // from string to object data
  func nzSplitElements(lineSeparator: String, delimiter: Character) -> [[String]] {
    let splitsSet = CharacterSet(charactersIn: lineSeparator)
    let rowString =  self.utf16.split {
      splitsSet.contains(UnicodeScalar($0)!)
    }
    return rowString.map {
      $0.split {
        Character(UnicodeScalar($0)!) == delimiter
      }.flatMap(String.init)
    }
  }
}

extension CSVParser {
  //if there is no quotes in content
  func parserNoQuote() {
    self.rows = self.content.nzSplitElements(lineSeparator: self.lineSeparator, delimiter: self.delimiter)
  }
  
  
}
