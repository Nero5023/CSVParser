import Foundation


public class CSVParser {
  
  var content: String
  var _rows: [[String]]
  
  var rows: [[String]] {
    get {
      if let lastElement = _rows.last, lastElement == [""] {
        return Array(_rows.dropLast())
      }
      return _rows
    }
  }
  
  let hasHeader: Bool
  // config
  let delimiter: Character
  let lineSeparator: Character
  let quotes: Character = "\""
  
  var headers: [String] {
    get {
      if hasHeader {
        return self.rows.first ?? []
      }else {
        return []
      }
    }
  }
  
  /**
    Create a CSVParser from String
   - Parameters:
    - content: the CSV String to parse
    - delimiter: the delimiter of the csv string
    - lineSeparator: the line separator of the csv string
  */
  public init(content: String, delimiter: Character = ",", lineSeparator: Character = "\n", hasHeader: Bool = true) throws {
    self.content = content
    self.delimiter = delimiter
    self.lineSeparator = lineSeparator
    self._rows = []
    self.hasHeader = hasHeader
    try self.parse()
  }
  
  /**
   Create a CSVParser from String
   - Parameters:
     - content: the CSV String to parse
     - delimiter: the delimiter of the csv file
     - lineSeparator: the line separator of the csv file
   */
  public convenience init(filePath: String, delimiter: Character = ",", lineSeparator: Character = "\n") throws {
    let fileContent = try String(contentsOfFile: filePath)
    try self.init(content: fileContent, delimiter: delimiter, lineSeparator: lineSeparator)
  }
  
  /**
   Create a CSVParser from [[String]]
   - Parameters:
   - elements: the elements in the csv file
   - delimiter: the delimiter of the csv file
   - lineSeparator: the line separator of the csv file
   */
  public init(elements: [[String]], delimiter: Character = ",", lineSeparator: Character = "\n", hasHeader: Bool = true) {
    self.content = ""
    self.delimiter = delimiter
    self.lineSeparator = lineSeparator
    self._rows = elements
    self.hasHeader = hasHeader
  }
  
  /**
   Create an empty CSVParser, required by 'RangeReplaceableCollection'
   */
  public convenience required init() {
    self.init(elements:[[]])
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
  
  
  private func parse() throws {
    if let _ = self.content.range(of: String(self.quotes)) {
      // if the file contains quote '"'
      try self.parseWithQuotes()
    }else {
      // if the file not contain quote
      self.parserNoQuote()
    }
  }
  
  private func functionalParse() {
    if let _ = self.content.range(of: String(self.quotes)) {
      // if the file contains quote '"'
      self.functionalParseWithQuote()
    }else {
      // if the file not contain quote
      self.parserNoQuote()
    }
  }
  
  // MARK: CSV To JSON
  /**
   Convert csv to JSON
   
   The return json type
   [
   {
   "header0": "a",
   "header1": "b"
   },
   {
   "header0": "a",
   "header1": "b"
   }
   ]
   
   - Returns: the parsed json string
   */
  public func toJSON() throws -> String? {
    let dic = self.enumeratedWithDic()
    let jsonData = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
    let jsonStr = String(data: jsonData, encoding: String.Encoding.utf8)
    return jsonStr
  }
  
  //MARK: JSON TO CSV
  /**
   Static method Convert Json to csv string
   You can use result to generate a CSVParser instance
   
   The json input now only suport this json type
   [
   {
   "header0": "a",
   "header1": "b"
   },
   {
   "header0": "a",
   "header1": "b"
   }
   ]
   
   - Parameter: jsonData: the json object with Data type.
   - Returns: the parsed CSV String
  */
  static public func jsonToCSVString(jsonData: Data) throws -> String {
    guard let jsonObj = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? Array<Dictionary<String, Any>> else {
      throw CSVParserError.jsonObjTypeNotMatch
    }
    let delimiter = ","
    let lineSeparator = "\n"
    if jsonObj.count == 0 {
      return ""
    }
    let header = jsonObj[0].keys
    let headerStr = header.dropFirst().reduce(header.first!) { result, col in
      result + delimiter + col
    }
    
    // help method
    // parse dic to a line of csv string
    func dicToStr(dic: [String: Any]) -> String {
      var result = lineSeparator
      for key in header {
        result = result + parseDicValue(value: dic[key]) + delimiter
      }
      result.remove(at: result.index(before: result.endIndex))
      return result
    }
    
    // help method
    // parse dic value to string
    func parseDicValue(value: Any?) -> String {
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


//MARK: Make a CSVParserIterator
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

//MARK: Comfirm to Sequence protocol
extension CSVParser: Sequence {
  public func makeIterator() -> CSVParserIterator {
    return CSVParserIterator(rows: self.rows)
  }
}


//MARK: Comfirm to Collection protocol
extension CSVParser: Collection {
  public typealias Index = Int
  public var startIndex: Index { return self.rows.startIndex }
  public var endIndex: Index {
    return self.rows.endIndex
  }
  
  public func index(after i: Index) -> Index {
    return self.rows.index(after: i)
  }
  
  /**
   The Int subscript
   - Returns: the ith row
  */
  public subscript(idx: Index) -> [String] {
    get {
      return self.rows[idx]
    }
    
    set (newValue) {
      self._rows[idx] = newValue
    }
  }
}

extension CSVParser {
  /**
   The String subscript
   - Returns: the column
   */
  public subscript(key: String) -> [String]? {
    guard let index = self.headers.index(of: key) else {
      return nil
    }
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

extension CSVParser: RangeReplaceableCollection {
  public func replaceSubrange<C>(_ subrange: Range<Int>, with newElements: C) where C : Collection, C.Iterator.Element == Array<String> {
    self._rows.replaceSubrange(subrange, with: newElements)
  }
  public func reserveCapacity(_ n: Int) {
    self._rows.reserveCapacity(n)
  }
}
