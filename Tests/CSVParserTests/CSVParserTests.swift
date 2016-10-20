//import XCTest
//@testable import CSVParser
//
//class CSVParserTests: XCTestCase {
//  
//  func testExample() {
//    do {
//      let csv = try CSVParser(filePath: "/Users/Nero/Desktop/empty_fields.csv")
//      
//      for line in csv {
//        print(line)
//      }
//
//      let csv1 = try CSVParser(filePath: "/Users/Nero/Desktop/quotes.csv")
//      let str = try csv1.toJSON()
//      print(str)
//      for line in csv1 {
//        print(line)
//      }
//  
//      let csv2 = try CSVParser(filePath: "/Users/Nero/Desktop/large2.csv")
//      
//      for line in csv2 {
//        print(line)
//      }
//      
//      print(csv2[4])
//      
//    }catch let error {
//      print(error)
//    }
//  }
//  
//  func testParsePerformance() {
//    measure {
//      let _ = try! CSVParser(filePath: "/Users/Nero/Desktop/large.csv")
//    }
//  }
//
//  func testParseJSON() {
//    let jsonstr = try! String(contentsOfFile: "/Users/Nero/Desktop/testjson.json")
//    let jsonData = jsonstr.data(using: .utf8)!
//    let result = try! CSVParser.jsonToCSVString(jsonData: jsonData)
//    print(result)
//  }
//  
//  
//
//  
//  static var allTests : [(String, (CSVParserTests) -> () throws -> Void)] {
//    return [
//      ("testExample", testExample),
//    ]
//  }
//}
