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
    let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)
    return jsonStr
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
  
  static public func jsonToCSVString(jsonData: Data) throws -> String {
    guard let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? Array<Dictionary<String, Any>> else {
      return ""
    }
    let delimiter = ","
    let lineSeparator = "\r\n"
    if jsonObj.count == 0 {
      return ""
    }
    let header = jsonObj[0].keys
    let headerStr = header.dropFirst().reduce(header.first!) { result, col in
      result + delimiter + col
    }
    
    func dicToStr(dic: [String: Any]) -> String {
      var result = lineSeparator
      for key in header {
        result = result + parseValue(value: dic[key]) + delimiter
      }
      result.remove(at: result.index(before: result.endIndex))
      return result
    }
    
    func parseValue(value: Any?) -> String {
      if let value = value as? String {
        return value
      }else if let intValue = value as? Int {
        return String(intValue)
      }else if let floatValue = value as? Float {
        return String(floatValue)
      }
      return ""
    }
    
    let csvContent = jsonObj.reduce(headerStr) { (result, row) -> String in
      result + dicToStr(dic: row)
    }
    return csvContent
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
