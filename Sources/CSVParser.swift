import Foundation


class CSVParser {
  
  var content: String
  
  let delimiter: Character
  var lines: [String]
  
  
  init(content: String, delimiter: Character = ",") {
    self.content = content
    self.delimiter = delimiter
    self.lines = content.lines()
  }

  convenience init(filePath: String, delimiter: Character = ",") throws {
    let fileContent = try String(contentsOfFile: filePath)
    self.init(content: fileContent, delimiter: delimiter)
    
  }
  
  func wirite(toFilePath path: String) throws {
    try self.lines.joined(separator: "\r\n").write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
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

extension CSVParser: Sequence {
  public func makeIterator() -> CSVParserIterator {
    return CSVParserIterator(lines: self.lines, delimiter: self.delimiter)
  }
}


extension CSVParser: Collection {
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
