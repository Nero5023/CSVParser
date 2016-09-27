import XCTest
@testable import SwiftCSVParser

class SwiftCSVParserTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
//    XCTAssertEqual(SwiftCSVParser().text, "Hello, World!")
    do {
      var csv = try SwiftCSVParser(filePath: "/Users/Nero/Desktop/quotes.csv")
//      print(csv.content.word())
      let content = csv.content
//      try csv.wirite(toFilePath: "/Users/Nero/Desktop/test2.csv")
      let index = content.characters.index(of: "\r")
      print(index)
//      csv[0] = ["id", "name", "helloworld"]
      
      for line in csv {
        print(line)
      }
      print(csv[4])
      
    }catch let error {
      print(error)
      
    }
  }

  func testPerformance() {
    measure {
      var csv = try! SwiftCSVParser(filePath: "/Users/Nero/Desktop/large.csv")
      for line in csv {
//        print(line)
      }
//      csv[0] = ["sid", "sname", "sage", "ajob"]
//      try! csv.wirite(toFilePath: "/Users/Nero/Desktop/large2.csv")
    }
  }
  
  static var allTests : [(String, (SwiftCSVParserTests) -> () throws -> Void)] {
    return [
      ("testExample", testExample),
    ]
  }
}
