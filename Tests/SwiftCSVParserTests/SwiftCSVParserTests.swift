import XCTest
@testable import SwiftCSVParser

class SwiftCSVParserTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
//    XCTAssertEqual(SwiftCSVParser().text, "Hello, World!")
    do {
      let csv = try SwiftCSVParser(filePath: "/Users/Nero/Desktop/test.csv")
      print(csv.content.word())
      let content = csv.content
      let index = content.characters.index(of: "\r")
      print(index)
//      var iterator = CSVParserInter(content)
//      print(iterator.next())
      for line in csv {
        print(csv.underestimatedCount)
        print(line)
      }
      print("CSV 3th")
      print(csv[5])
      
    }catch let error {
      print(error)
      
    }
    
  }

  func testPerformance() {
    measure {
      do {
        let csv = try SwiftCSVParser(filePath: "/Users/Nero/Desktop/large.csv")
        for _ in csv {
          
        }
      }catch let error {
        print(error)
        
      }
    }
  }
  
  static var allTests : [(String, (SwiftCSVParserTests) -> () throws -> Void)] {
    return [
      ("testExample", testExample),
    ]
  }
}
