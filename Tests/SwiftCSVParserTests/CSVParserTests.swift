import XCTest
@testable import CSVParser

class CSVParserTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    do {
      var csv = try CSVParser(filePath: "/Users/Nero/Desktop/quotes.csv")

      let content = csv.content
      let index = content.characters.index(of: "\r")
      print(index)

      
      for line in csv {
        print(line)
      }
      for line in csv.content.lines() {
        print(line)
      }
      print(csv[4])
      
    }catch let error {
      print(error)
      
    }
  }

  func testPerformance() {
    measure {
      
      var csv = try! CSVParser(filePath: "/Users/Nero/Desktop/large.csv")

      for line in csv {

      }
    }
    
  }

  
  static var allTests : [(String, (CSVParserTests) -> () throws -> Void)] {
    return [
      ("testExample", testExample),
    ]
  }
}
