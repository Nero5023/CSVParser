import XCTest
@testable import CSVParser

class CSVParserTests: XCTestCase {
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    let fileManager = FileManager.default
    
    // Get current directory path
    
    let path = fileManager.currentDirectoryPath
    print(path)
    
    do {
      let csv = try CSVParser(filePath: "/Users/Nero/Desktop/empty_fields.csv")

      
      for line in csv {
        print(line)
      }

      
      let csv1 = try CSVParser(filePath: "/Users/Nero/Desktop/quotes.csv")
      
      
      for line in csv1 {
        print(line)
      }
      
      print(csv1[4])
      
      
      let csv2 = try CSVParser(filePath: "/Users/Nero/Desktop/large.csv")
      
      
      for line in csv2 {
        print(line)
      }
      
      print(csv2[4])
      
    }catch let error {
      print(error)
      
    }
  }
  
//  func testConcurrentPerformance() {
//    let csv = try! CSVParser(filePath: "/Users/Nero/Desktop/large.csv")
//    measure {
//      csv.concurrencyParse {
//        print("done")
//      }
//    }
//    
//  }
//  
  func testParsePerformance() {
    measure {
    let csv = try! CSVParser(filePath: "/Users/Nero/Desktop/large.csv")
      
    }
  }
  func testConcurrencyPerformance() {
    measure {
      let csv = try! CSVParser(filePath: "/Users/Nero/Desktop/large2.csv")
     
    }
  }
  
  func testConcurrencyWrite() {
    let csv = try! CSVParser(filePath: "/Users/Nero/Desktop/large2.csv")
//    csv.concurrencyParse {
//      csv.rows.forEach({ x in
//        if x.count != 4 {
//          XCTAssertEqual("1", "12")
//        }
//      })
//      print("done")
//    }
  }
  

  
  static var allTests : [(String, (CSVParserTests) -> () throws -> Void)] {
    return [
      ("testExample", testExample),
    ]
  }
}
