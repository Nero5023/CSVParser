import Foundation

class CSVParser {
  
  
  var content: String
  var rows: [[String]]
  
  // config
  let delimiter: Character
  let lineSeparator: Character = "\n"
  let quotes: Character = "\""
  
  var headers: [String] {
    get {
      return self.rows.first ?? []
    }
  }
  
  init(content: String, delimiter: Character = ",") {
    self.content = content
    self.delimiter = delimiter
    self.rows = []

    self.parse()
  }

  convenience init(filePath: String, delimiter: Character = ",") throws {
    let fileContent = try String(contentsOfFile: filePath)
    self.init(content: fileContent, delimiter: delimiter)
  }
  
  func wirite(toFilePath path: String) throws {
    try self.rows.map{ $0.joined(separator: String(self.delimiter)) }.joined(separator: String(self.lineSeparator)).write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
  }
  
  func enumeratedWithDic() -> [[String: String]] {
    return self.rows.dropFirst().map {
      var dic = [String: String]()
      for (index, word) in $0.enumerated() {
        dic[self.headers[index]] = word
      }
      return dic
    }
  }
  
  private func parse() {
    if let _ = self.content.range(of: String(self.quotes)) {
//      self.parseWithQuotes()
      self.newParse()
    }else {
      self.parserNoQuote()
    }
  }
  
//  func concurrencyParse(handler:  @escaping ()->()) {
//    let wordsInOneTime = 100
//    let parseGroup = DispatchGroup()
//    // writeRowQueue is a serial queue not concurrent
//    let writeRowQueue = DispatchQueue(label: "com.csvparser.write", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
//    writeRowQueue.setTarget(queue: DispatchQueue.global(qos: .default))
//    for i in 0...self.lines.count / wordsInOneTime {
//      let workItem = DispatchWorkItem(block: {
//        let min = wordsInOneTime < (self.lines.count - i*wordsInOneTime) ? wordsInOneTime : (self.lines.count - i*wordsInOneTime)
//        for j in 0..<min{
//          let index = i*wordsInOneTime + j
////          self.rows[index] =
//          let parsedLine = self.lines[index].words()
////          dispatch_barrier_async(<#T##queue: DispatchQueue##DispatchQueue#>, <#T##block: () -> Void##() -> Void#>)
//          writeRowQueue.async(group: parseGroup, qos: .default, flags: .barrier) {
//            self.rows[index] = parsedLine
//          }
//        }
//      })
//      DispatchQueue.global(qos: .userInitiated).async(group: parseGroup, execute: workItem)
//
//    }
////    parseGroup.notify(queue: DispatchQueue.main, execute: handler)
//    parseGroup.wait()
//    handler()
//  }
  
  
  
}

extension String {
  
  func words(splitBy split: Character = ",") -> [String] {
    let quote = "\""
    var apperQuote = false
    let result = self.utf16.split(maxSplits: Int.max, omittingEmptySubsequences: false) { x in
      if quote == String(UnicodeScalar(x)!) {
        apperQuote = !apperQuote
      }
      if apperQuote {
        return false
      }else {
        return Character(UnicodeScalar(x)!) == split
      }
      }.flatMap(String.init)
    return result
  }
  
  func lines(splitBy split: CharacterSet = CharacterSet(charactersIn: "\r\n")) -> [String] {
    let quote = "\""
    var apperQuote = false
    let result = self.utf16.split(maxSplits: Int.max, omittingEmptySubsequences: false) { x in
      if quote == String(UnicodeScalar(x)!) {
        apperQuote = !apperQuote
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
  
  var rowsIterator: IndexingIterator<[[String]]>
  
  init(rows: [[String]]) {
    self.rowsIterator = rows.makeIterator()
  }
  
  
  public mutating func next() -> [String]? {
    return self.rowsIterator.next()
  }
  
}

extension CSVParser: Sequence {
  public func makeIterator() -> CSVParserIterator {
    return CSVParserIterator(rows: self.rows)
  }
}


extension CSVParser: Collection {
  public typealias Index = Int
  public var startIndex: Index { return self.rows.startIndex }
  public var endIndex: Index {
    return self.rows.endIndex
  }
  
  public func index(after i: Index) -> Index {
    return self.rows.index(after: i)
  }
  
  subscript(idx: Index) -> [String] {
    get {
      return self.rows[idx]
    }
    
    set (newValue) {
      self.rows[idx] = newValue
    }
  }
}

extension CSVParser {
  subscript(key: String) -> [String]? {
    guard let index = self.headers.index(of: key) else {
      return nil
    }
    // may be wrong here
    // must parse first
    return self.rows.dropFirst().map {
      $0[index]
    }
  }
}
