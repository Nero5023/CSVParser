import Foundation


struct SwiftCSVParser {
  
  let content: String
  
  init(filePath: String) throws {
    content = try String(contentsOfFile: filePath)
  }

  
  func elements() -> [String] {
    return content.word()
  }
  
}

extension String {
  func word(spliBy split: CharacterSet = .alphanumerics) -> [String] {
    return self.utf16.split { x in
      // 这里强制 不太好
      !split.contains(UnicodeScalar(x)!)
    }.flatMap(String.init)
  }
}

struct CSVParserIterator: IteratorProtocol {
  
  typealias Element = [String]
  
  let content: NSString
  fileprivate let regexResults: [NSTextCheckingResult]
  var rangesIterator: IndexingIterator<[NSRange]>
  
  init(_ content: String) {
    self.content = content as NSString
    let regx = try! NSRegularExpression(pattern: "(.+)", options: .caseInsensitive)
    regexResults = regx.matches(in: content, options: [], range: NSRange(location: 0, length: content.characters.count))
//    let ranges = regexResults.map { $0.range }
    self.rangesIterator = regexResults.map { $0.range }.makeIterator()
  }
  
  
  public mutating func next() -> Array<String>? {
    return self.rangesIterator.next().flatMap{ self.content.substring(with: $0) }?.word()
  }
  
  
}

extension SwiftCSVParser: Sequence {
  public func makeIterator() -> CSVParserIterator {
    return CSVParserIterator(self.content)
  }
}


extension SwiftCSVParser: Collection {
  public typealias Index = Int
  public var startIndex: Index { return 0 }
  public var endIndex: Index {
    return self.makeIterator().regexResults.count
  }
  
  public func index(after i: Int) -> Int {
    return i+1
  }
  
  subscript(idx: Index) -> [String] {
    guard idx >= 0 && idx <= self.endIndex else { fatalError("Out of range") }
    let regex = self.makeIterator().regexResults[idx]
    return (self.content as NSString).substring(with: regex.range ).word()
  }
}
