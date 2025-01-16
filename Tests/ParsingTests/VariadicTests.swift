import Parsing
import XCTest

final class NParsingTests: XCTestCase {
  func testParsing11() throws {
    struct ParserTest: Parser {
      var body: some Parser<Substring, (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)>
      {
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
      }
    }
    
    var input = "1.2.3.4.5.6.7.8.9.10.11.12"[...]
    let output: (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int) = try ParserTest()
      .parse(&input)
    XCTAssertEqual(output.0, 1)
    XCTAssertEqual(output.1, 2)
    XCTAssertEqual(output.2, 3)
    XCTAssertEqual(output.3, 4)
    XCTAssertEqual(output.4, 5)
    XCTAssertEqual(output.5, 6)
    XCTAssertEqual(output.6, 7)
    XCTAssertEqual(output.7, 8)
    XCTAssertEqual(output.8, 9)
    XCTAssertEqual(output.9, 10)
    XCTAssertEqual(output.10, 11)
    XCTAssertEqual(output.11, 12)
  }
}

final class NPrintingTests: XCTestCase {
  
  
  func test2Print() throws {
    struct PrinterTest: ParserPrinter {
      var body: some ParserPrinter<Substring, (Int, Int)> {
        Digits()
        "."
        Digits()
        "."
      }
    }
    
    let x = try PrinterTest().print((2, 2))
    XCTAssertEqual("2.2.", x)
  }
  
  func test3Print() throws {
    struct PrinterTest: ParserPrinter {
      var body: some ParserPrinter<Substring, (Int, Int, Int)> {
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
      }
    }
    let x = try PrinterTest().print((2, 2, 2))
    XCTAssertEqual("2.2.2.", x)
  }
  
  
  func test11Print() throws {
    struct PrinterTest: ParserPrinter {
      var body: some ParserPrinter<Substring, (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)> {
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
        "."
        Digits()
      }
    }
    
    let x = try PrinterTest().print((2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2))
    XCTAssertEqual("2.2.2.2.2.2.2.2.2.2.2.", x)
  }
}
