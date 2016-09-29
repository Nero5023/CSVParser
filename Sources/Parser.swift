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
  func nzSplitLines(lineSeparator: Character) -> [String] {
    return self.utf16.split {
      Character(UnicodeScalar($0)!) == lineSeparator
    }.flatMap(String.init)
  }
  
  // to split to elements
  func nzSplitElements(delimiter: Character) -> [String] {
    return self.utf16.split {
      return Character(UnicodeScalar($0)!) == delimiter
    }.flatMap(String.init)
  }
  
  // from string to object data
  func nzSplitElements(lineSeparator: Character, delimiter: Character) -> [[String]] {
    let rowString =  self.utf16.split {
      Character(UnicodeScalar($0)!) == lineSeparator
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
  
  func parseWithQuotes() {
    let quotes: Character = "\""
    let inputContents = content.characters
    var cursor = inputContents.startIndex
    var nextDelimiter = inputContents.index(of: self.delimiter)
    var nextLine = inputContents.index(of: self.lineSeparator)
    var row = [String]()
    while true {
      // need to pares with quotes
      if inputContents[cursor] == quotes {
        var nextQuote = cursor
        cursor = inputContents.index(after: cursor)
        while true {
          if let nextQ = inputContents.suffix(from: inputContents.index(after: nextQuote)).index(of: quotes) {
            nextQuote = nextQ
            
            // end of file
            if nextQuote == inputContents.endIndex {
              row.append(self.content.substring(with: cursor..<nextQuote))
              self.rows.append(row)
              return
            }
            
            // two quotes together
            if inputContents[inputContents.index(after: nextQuote)] == quotes {
              nextQuote = inputContents.index(after: nextQuote)
              continue
            }
            
            // come across delimiter
            if inputContents[inputContents.index(after: nextQuote)] == self.delimiter {
              row.append(self.content.substring(with: cursor..<nextQuote))
              cursor = inputContents.index(nextQuote, offsetBy: 1 + 1)
              // need to be the cursor next index
              
              nextDelimiter = inputContents.suffix(from: cursor).index(of: self.delimiter)
              nextLine = inputContents.suffix(from: cursor).index(of: self.lineSeparator)
              break
            }
            
            if inputContents[inputContents.index(after: nextQuote)] == self.lineSeparator {
              row.append(self.content.substring(with: cursor..<nextQuote))
              self.rows.append(row)
              row.removeAll(keepingCapacity: true)
              nextDelimiter = inputContents.suffix(from: cursor).index(of: self.delimiter)
              nextLine = inputContents.suffix(from: cursor).index(of: self.lineSeparator)
              break
            }
            continue
          }else {
            // TODO: raise error
            fatalError("No matched quotes")
          }
        }
      }
      
      //TODO: Next delimiter comes before next newline
    }
  
  }
  
  
}

