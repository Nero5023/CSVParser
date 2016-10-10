import Foundation

public class CSVParser {
  
  
  var content: String
  var rows: [[String]]
  
  // config
  let delimiter: Character
  let lineSeparator: Character
  let quotes: Character = "\""
  
  var headers: [String] {
    get {
      return self.rows.first ?? []
    }
  }
  
  public init(content: String, delimiter: Character = ",", lineSeparator: Character = "\n") {
    self.content = content
    self.delimiter = delimiter
    self.lineSeparator = lineSeparator
    self.rows = []
    
    self.parse()
  }

  public convenience init(filePath: String, delimiter: Character = ",", lineSeparator: Character = "\n") throws {
    let fileContent = try String(contentsOfFile: filePath)
    self.init(content: fileContent, delimiter: delimiter, lineSeparator: lineSeparator)
  }
  
  public func wirite(toFilePath path: String) throws {
    try self.rows.map{ $0.joined(separator: String(self.delimiter)) }.joined(separator: String(self.lineSeparator)).write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
  }
  
  public func enumeratedWithDic() -> [[String: String]] {
    return self.rows.dropFirst().map {
      var dic = [String: String]()
      for (index, word) in $0.enumerated() {
        dic[self.headers[index]] = word
      }
      return dic
    }
  }
  
  public func toJSON() throws -> String? {
    let dic = self.enumeratedWithDic()
    let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
    let jsonStr = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)
    return jsonStr as String?
  }
  
  private func parse() {
    if let _ = self.content.range(of: String(self.quotes)) {
      // if the file contains quote '"'
      self.parseWithQuotes()
    }else {
      // if the file not contain quote
      self.parserNoQuote()
    }
  }
  
  private func functionalParse() {
    if let _ = self.content.range(of: String(self.quotes)) {
      // if the file contains quote '"'
//      let startIndex = self.content.characters.startIndex
//      let delimiterIndex = self.content.index(of: self.delimiter, after: startIndex)
//      let lineSIndex = self.content.index(of: self.lineSeparator, after: startIndex)
//      self.rows = functionalParseIter(cursor: startIndex, delimiterIndex: delimiterIndex, lineSIndex: lineSIndex, row: [], rows: [], content: self.content
      self.functionalParseWithQuote()
    }else {
      // if the file not contain quote
      self.parserNoQuote()
    }
  }
}


// Make a CSVParserIterator
public struct CSVParserIterator: IteratorProtocol {
  
  public typealias Element = [String]
  
  var rowsIterator: IndexingIterator<[[String]]>
  
  init(rows: [[String]]) {
    self.rowsIterator = rows.makeIterator()
  }
  
  
  public mutating func next() -> [String]? {
    return self.rowsIterator.next()
  }
  
}

// Comfirm to Sequence protocol
extension CSVParser: Sequence {
  public func makeIterator() -> CSVParserIterator {
    return CSVParserIterator(rows: self.rows)
  }
}


// Comfirm to Collection protocol
extension CSVParser: Collection {
  public typealias Index = Int
  public var startIndex: Index { return self.rows.startIndex }
  public var endIndex: Index {
    return self.rows.endIndex
  }
  
  public func index(after i: Index) -> Index {
    return self.rows.index(after: i)
  }
  
  public subscript(idx: Index) -> [String] {
    get {
      return self.rows[idx]
    }
    
    set (newValue) {
      self.rows[idx] = newValue
    }
  }
}

extension CSVParser {
  // string subscript
  public subscript(key: String) -> [String]? {
    guard let index = self.headers.index(of: key) else {
      return nil
    }
    // may be wrong here
    // must parse first
    return self.rows.dropFirst().map {
      // make sure every column
      if index >= $0.count {
        return ""
      }else {
        return $0[index]
      }
    }
  }
}
