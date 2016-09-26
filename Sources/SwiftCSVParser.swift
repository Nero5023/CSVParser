import Foundation


struct SwiftCSVParser {
  
  var content: String {
    didSet {
      let regx = try! NSRegularExpression(pattern: "(.+)", options: .caseInsensitive)
      regexResults = regx.matches(in: content, options: [], range: NSRange(location: 0, length: content.characters.count))
    }
  }
  var regexResults: [NSTextCheckingResult]
  
  init(filePath: String) throws {
    content = try String(contentsOfFile: filePath)
    let regx = try! NSRegularExpression(pattern: "(.+)", options: .caseInsensitive)
    regexResults = regx.matches(in: content, options: [], range: NSRange(location: 0, length: content.characters.count))
  }

  
  func elements() -> [String] {
    return content.word()
  }
  
  func wirite(toFilePath path: String) throws {
    try self.content.write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
  }
  
}

extension String {
//  func word(spliBy split: CharacterSet = .alphanumerics) -> [String] {
//    return self.utf16.split { x in
//      // 这里强制 不太好
//      !split.contains(UnicodeScalar(x)!)
//    }.flatMap(String.init)
//  }
  func word(splitBy split: CharacterSet = CharacterSet(charactersIn: ",\r\n")) -> [String] {
    return self.utf16.split { x in
//      UnicodeScalar(x)! == ","
      split.contains(UnicodeScalar(x)!)
    }.flatMap(String.init)
  }
}

struct CSVParserIterator: IteratorProtocol {
  
  typealias Element = [String]
  
  var rangesIterator: IndexingIterator<[NSRange]>
  let content: String
  
  init(regexResults: [NSTextCheckingResult], content: String) {
//    self.content = content as NSString
//    let regx = try! NSRegularExpression(pattern: "(.+)", options: .caseInsensitive)
//    regexResults = regx.matches(in: content, options: [], range: NSRange(location: 0, length: content.characters.count))
//    let ranges = regexResults.map { $0.range }
    self.content = content
    self.rangesIterator = regexResults.map { $0.range }.makeIterator()
  }
  
  
  public mutating func next() -> Array<String>? {
    return self.rangesIterator.next().flatMap{ (content as NSString).substring(with: $0)}?.word()
  }
  
  
}

extension SwiftCSVParser: Sequence {
  public func makeIterator() -> CSVParserIterator {
    return CSVParserIterator(regexResults: self.regexResults, content: self.content)
  }
}


extension SwiftCSVParser: Collection {
  public typealias Index = Int
  public var startIndex: Index { return self.regexResults.startIndex }
  public var endIndex: Index {
    return self.regexResults.endIndex
  }
  
  public func index(after i: Index) -> Index {
    return self.regexResults.index(after: i)
  }
  
  subscript(idx: Index) -> [String] {
    get {
      let regex = self.regexResults[idx]
      return (self.content as NSString).substring(with: regex.range).word()
    }
    
    set (newValue) {
      let nsrange = self.regexResults[idx].range
      let start = self.content.index(self.content.startIndex, offsetBy: nsrange.location)
      let end = self.content.index(start, offsetBy: nsrange.length)
      let range = start..<end
      self.content.replaceSubrange(range, with: newValue.joined(separator: ","))
    }
  }
}
