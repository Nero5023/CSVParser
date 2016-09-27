import Foundation


struct SwiftCSVParser {
  
  var content: String {
    didSet {
      let regx = try! NSRegularExpression(pattern: "(.+)", options: .caseInsensitive)
      regexResults = regx.matches(in: content, options: [], range: NSRange(location: 0, length: content.characters.count))
    }
  }
  var regexResults: [NSTextCheckingResult]
  let delimiter: Character
  
  init(filePath: String, delimiter: Character = ",") throws {
    content = try String(contentsOfFile: filePath)
    self.delimiter = delimiter
    let regx = try! NSRegularExpression(pattern: "(.+)", options: .caseInsensitive)
    regexResults = regx.matches(in: content, options: [], range: NSRange(location: 0, length: content.characters.count))
  }

  
  func elements() -> [String] {
    return content.words(splitBy: CharacterSet(charactersIn:  "\(delimiter)\r\n")).0
  }
  
  func wirite(toFilePath path: String) throws {
    try self.content.write(to: URL(fileURLWithPath: path), atomically: false, encoding: .utf8)
  }
  
}

extension String {
//  func word(spliBy split: CharacterSet = .alphanumerics) -> [String] {
//    return self.utf16.split { x in
//      // 这里强制 不太好
//      ! (UnicodeScalar(x)!)
//    }.flatMap(String.init)
//  }
//  func word(splitBy split: CharacterSet = CharacterSet(charactersIn: ",\r\n")) -> [String] {
//    let quote = "\""
//    var apperQuote = false
//    return self.utf16.split(maxSplits: Int.max, omittingEmptySubsequences: false) { x in
//      if quote == String(UnicodeScalar(x)!) {
//        if !apperQuote {
//          apperQuote = true
//        }else {
//          apperQuote = false
//        }
//      }
//      if apperQuote {
//        return false
//      }else {
//        return split.contains(UnicodeScalar(x)!)
//      }
//    }.flatMap(String.init)
//  }
  
  func words(splitBy split: CharacterSet = CharacterSet(charactersIn: ",\r\n"), apperQuote: Bool = false) -> ([String], Bool) {
    let quote = "\""
    var apperQuote = apperQuote
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
    return (result, apperQuote)
  }
}

struct CSVParserIterator: IteratorProtocol {
  
  typealias Element = [String]
  
  var rangesIterator: IndexingIterator<[NSRange]>
  let content: String
  let delimiter: Character
  init(regexResults: [NSTextCheckingResult], content: String, delimiter: Character) {
    self.content = content
    self.delimiter = delimiter
    self.rangesIterator = regexResults.map { $0.range }.makeIterator()
  }
  
  
//  public mutating func next() -> Array<String>? {
//    return self.rangesIterator.next().flatMap{ (content as NSString).substring(with: $0)}?.word(splitBy: CharacterSet(charactersIn:  "\(delimiter)\r\n"))
//  }
  
  public mutating func next() -> [String]? {
    
    func combine(_ words0: [String],_ words1: [String]) -> [String] {
      if words0 == [] || words1 == [] {
        return words0 + words1
      }
      let words0Last = words0.last!
      let words1First = words1.first!
      let wordsCombine = words0Last + "\r\n" + words1First
      var result = Array(words0.dropLast())
      result.append(wordsCombine)
      result.append(contentsOf: words1.dropFirst())
      return result
    }
    
    func iter(words: [String], apperQuote: Bool) -> [String]? {
      guard let range = self.rangesIterator.next() else {
        if words == [] {
          return nil
        }else {
          return words
        }
        
      }
      let (newWords, didApperQuote) = (content as NSString).substring(with: range).words(splitBy: CharacterSet(charactersIn:  "\(delimiter)\r\n"), apperQuote: apperQuote)
      if didApperQuote {
        return iter(words: combine(words, newWords), apperQuote: didApperQuote)
      }else {
        return combine(words, newWords)
      }
    }
    return iter(words: [], apperQuote: false)
  }
  
  
}

extension SwiftCSVParser: Sequence {
  public func makeIterator() -> CSVParserIterator {
    return CSVParserIterator(regexResults: self.regexResults, content: self.content, delimiter: self.delimiter)
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
      let result = self.enumerated().filter { (offset, _ ) -> Bool in
        return offset == idx
      }.first?.1
      if let result = result {
        return result
      }else {
        fatalError("Index: \(idx) out of range")
      }
    }
    
    set (newValue) {
      let nsrange = self.regexResults[idx].range
      let start = self.content.index(self.content.startIndex, offsetBy: nsrange.location)
      let end = self.content.index(start, offsetBy: nsrange.length)
      let range = start..<end
      self.content.replaceSubrange(range, with: newValue.joined(separator: "\(self.delimiter)"))
    }
  }
}
