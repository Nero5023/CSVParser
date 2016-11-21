//
//  Parser.swift
//  CSVParser
//
//  Created by Nero Zuo on 16/9/29.
//
//

import Foundation



extension CSVParser {
  //if there is no quotes in content
  func parserNoQuote() {
    self._rows = self.content.nzSplitElements(lineSeparator: self.lineSeparator, delimiter: self.delimiter)
  }
  
  func parseWithQuotes() throws {
    let inputContents = content.characters

    var cursor = inputContents.startIndex
    var nextDelimiter = inputContents.index(of: self.delimiter)
    var nextLine = inputContents.index(of: self.lineSeparator)
    var row = [String]()
    while true && cursor != inputContents.endIndex {
      
      // need to pares with quotes
      if inputContents[cursor] == quotes {
        var nextQuote = cursor
        cursor = inputContents.index(after: cursor)
        while true {
          if let nextQ = self.content.index(of: quotes, after: inputContents.index(after: nextQuote) ) {
            nextQuote = nextQ
            
            // end of file
            if nextQuote == inputContents.endIndex
                        || inputContents.index(after: nextQuote) == inputContents.endIndex {
              
              row.append(self.content.substring(with: cursor..<nextQuote))
              self._rows.append(row)
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
              self._rows.append(row)
              row.removeAll(keepingCapacity: true)
              //nextDelimiter = inputContents.suffix(from: cursor).index(of: self.delimiter)
              cursor = inputContents.index(nextQuote, offsetBy: 1 + 1)
              nextDelimiter = self.content.index(of: self.delimiter, after: cursor)
              nextLine = self.content.index(of: self.lineSeparator, after: cursor)
              break
            }
            
          }else {
            throw CSVParserError.containMismatchedQuotes
          }
        }
        continue
      }
      
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
        self._rows.append(row)
        row.removeAll(keepingCapacity: true)
        cursor = inputContents.index(nextNewLine, offsetBy: 1)
        
        nextLine = self.content.index(of: self.lineSeparator, after: cursor)
        
        continue
      }
      
      // the last element
      if cursor != inputContents.endIndex && nextDelimiter == nil && nextLine == nil {
        row.append(self.content.substring(with: cursor..<self.content.endIndex))
        self._rows.append(row)
        row.removeAll(keepingCapacity: true)
        cursor = self.content.endIndex
        
      }
      
      break
    }
  
  }
  
  
  //Functional Parse
//    func concurrencyParse(handler:  @escaping ()->()) {
//      let wordsInOneTime = 100
//      let parseGroup = DispatchGroup()
//      // writeRowQueue is a serial queue not concurrent
//      let writeRowQueue = DispatchQueue(label: "com.csvparser.write", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
//      writeRowQueue.setTarget(queue: DispatchQueue.global(qos: .default))
//      for i in 0...self.lines.count / wordsInOneTime {
//        let workItem = DispatchWorkItem(block: {
//          let min = wordsInOneTime < (self.lines.count - i*wordsInOneTime) ? wordsInOneTime : (self.lines.count - i*wordsInOneTime)
//          for j in 0..<min{
//            let index = i*wordsInOneTime + j
//  //          self.rows[index] =
//            let parsedLine = self.lines[index].words()
//  //          dispatch_barrier_async(<#T##queue: DispatchQueue##DispatchQueue#>, <#T##block: () -> Void##() -> Void#>)
//            writeRowQueue.async(group: parseGroup, qos: .default, flags: .barrier) {
//              self.rows[index] = parsedLine
//            }
//          }
//        })
//        DispatchQueue.global(qos: .userInitiated).async(group: parseGroup, execute: workItem)
//  
//      }
//  //    parseGroup.notify(queue: DispatchQueue.main, execute: handler)
//      parseGroup.wait()
//      handler()
//    }
  
  
  
}

