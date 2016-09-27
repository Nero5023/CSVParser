import Foundation


struct SwiftCSVParser {
  
  var content: String
  
  let delimiter: Character
  var lines: [String]
  
  init(filePath: String, delimiter: Character = ",") throws {
    content = try String(contentsOfFile: filePath)
    self.delimiter = delimiter
    self.lines = content.lines()
  }

  
  func wirite(toFilePath path: String) throws {
    try self.content.write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
  }
}

extension String {
  
  func words(splitBy split: CharacterSet = CharacterSet(charactersIn: ",\r\n")) -> [String] {
    let quote = "\""
    var apperQuote = false
    let result = self.utf16.split(maxSplits: Int.max, omittingEmptySubsequences: false) { x in
      if quote == String(UnicodeScalar(x)!) {
        if !apperQuote {
          apperQuote = true
        }else {
          apperQuote = false
        }
      }
      if apperQuote {
        return false
      }else { 
        return split.contains(UnicodeScalar(x)!)
      }
      }.flatMap(String.init)
    return result
  }
  
  func lines(splitBy split: CharacterSet = CharacterSet(charactersIn: "\r\n")) -> [String] {
    let quote = "\""
    var apperQuote = false
    let result = self.utf16.split(maxSplits: Int.max, omittingEmptySubsequences: false) { x in
      if quote == String(UnicodeScalar(x)!) {
        if !apperQuote {
          apperQuote = true
        }else {
          apperQuote = false
        }
      }
      if apperQuote {
        return false
      }else {
        return split.contains(UnicodeScalar(x)!)
      }
      }.flatMap(String.init)
    return result
  }
  
}

struct CSVParserIterator: IteratorProtocol {
  
  typealias Element = [String]
  
  let delimiter: Character
  let lines: [String]
  var linesIterator: IndexingIterator<[String]>
  
  init(lines: [String], delimiter: Character) {
    self.lines = lines
    self.delimiter = delimiter
    self.linesIterator = self.lines.makeIterator()
  }
  
  
  public mutating func next() -> [String]? {
    return self.linesIterator.next().map{ $0.words() }
  }
  
}

extension SwiftCSVParser: Sequence {
  public func makeIterator() -> CSVParserIterator {
    return CSVParserIterator(lines: self.lines, delimiter: self.delimiter)
  }
}


extension SwiftCSVParser: Collection {
  public typealias Index = Int
  public var startIndex: Index { return self.lines.startIndex }
  public var endIndex: Index {
    return self.lines.endIndex
  }
  
  public func index(after i: Index) -> Index {
    return self.lines.index(after: i)
  }
  
  subscript(idx: Index) -> [String] {
    get {
      return self.lines[idx].words()
    }
    
    set (newValue) {
      self.lines[idx] = newValue.joined(separator: String(self.delimiter))
    }
  }
}
