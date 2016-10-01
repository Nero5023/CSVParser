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
    let rowString =  self.utf16.split(maxSplits: Int.max, omittingEmptySubsequences: false) {
      Character(UnicodeScalar($0)!) == lineSeparator
    }
    return rowString.map {
      $0.split(maxSplits: Int.max, omittingEmptySubsequences: false) {
        Character(UnicodeScalar($0)!) == delimiter
      }.flatMap(String.init)
    }
  }
  
  func index(of char: Character, after: String.Index) -> String.Index? {
    // don't know
//    return range(of: String(char), options: .literal, range: self.index(after: after)..<self.endIndex, locale: nil)?.lowerBound
    return range(of: String(char), options: .literal, range: after..<self.endIndex, locale: nil)?.lowerBound
  }
  
}

extension CSVParser {
  //if there is no quotes in content
  func parserNoQuote() {
    self.rows = self.content.nzSplitElements(lineSeparator: self.lineSeparator, delimiter: self.delimiter)
  }
  
  func parseWithQuotes() {
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
          if let nextQ = self.content.index(of: quotes, after: inputContents.index(after: nextQuote) ) {
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
              
              nextDelimiter = self.content.index(of: self.delimiter, after: cursor)
              nextLine = self.content.index(of: self.lineSeparator, after: cursor)
              break
            }
            
            // come accross nextline
            if inputContents[inputContents.index(after: nextQuote)] == self.lineSeparator {
              row.append(self.content.substring(with: cursor..<nextQuote))
              self.rows.append(row)
              row.removeAll(keepingCapacity: true)
//              nextDelimiter = inputContents.suffix(from: cursor).index(of: self.delimiter)
              cursor = inputContents.index(nextQuote, offsetBy: 1 + 1)
              nextDelimiter = self.content.index(of: self.delimiter, after: cursor)
              nextLine = self.content.index(of: self.lineSeparator, after: cursor)
              break
            }
            
          }else {
            // TODO: raise error
            fatalError("No matched quotes")
          }
        }
        continue
      }
      
      //
      
      //Next delimiter comes before next newline
      if let nextDelim = nextDelimiter {
        if let nextLine = nextLine , nextDelim >= nextLine   {
          //pass
        }else {
          row.append(self.content.substring(with: cursor..<nextDelim))
          cursor = inputContents.index(nextDelim, offsetBy: 1)
          nextDelimiter = self.content.index(of: self.delimiter, after: cursor)
          continue
        }
      }
      
      // end of row
      if let nextNewLine = nextLine {
        row.append(self.content.substring(with: cursor..<nextNewLine))
        self.rows.append(row)
        row.removeAll(keepingCapacity: true)
        cursor = inputContents.index(nextNewLine, offsetBy: 1)
        
        nextLine = self.content.index(of: self.lineSeparator, after: cursor)
        
        continue
      }
      
      // the last element
      if cursor != inputContents.endIndex && nextDelimiter == nil && nextLine == nil {
        row.append(self.content.substring(with: cursor..<self.content.endIndex))
        self.rows.append(row)
        row.removeAll(keepingCapacity: true)
        cursor = self.content.endIndex
        
      }
      
      break
    }
  
  }
  
  
}

