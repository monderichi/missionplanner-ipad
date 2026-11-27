// Minimal XCTest stand-in so MAVLinkKit's XCTest files run with Command Line Tools only
// (CLT ships Swift Testing but not XCTest). Only the APIs the suite uses are implemented.
@_exported import Foundation

public enum XCTestShim {
    public static var failures: [String] = []
    public static var current = ""
    static func fail(_ msg: String, _ file: StaticString, _ line: UInt) {
        failures.append("\(current): \(file):\(line): \(msg)")
        FileHandle.standardError.write("  FAIL \(current) \(file):\(line): \(msg)\n".data(using: .utf8)!)
    }
}

open class XCTestCase {
    public required init() {}
    open func setUp() {}
    open func tearDown() {}
}

public func XCTFail(_ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    XCTestShim.fail("XCTFail \(m())", file, line)
}
public func XCTAssertTrue(_ e: @autoclosure () throws -> Bool, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { if try !e() { XCTestShim.fail("XCTAssertTrue \(m())", file, line) } } catch { XCTestShim.fail("threw \(error)", file, line) }
}
public func XCTAssertFalse(_ e: @autoclosure () throws -> Bool, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { if try e() { XCTestShim.fail("XCTAssertFalse \(m())", file, line) } } catch { XCTestShim.fail("threw \(error)", file, line) }
}
public func XCTAssertNil(_ e: @autoclosure () throws -> Any?, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { if let v = try e() { XCTestShim.fail("XCTAssertNil got \(v) \(m())", file, line) } } catch { XCTestShim.fail("threw \(error)", file, line) }
}
public func XCTAssertNotNil(_ e: @autoclosure () throws -> Any?, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { if try e() == nil { XCTestShim.fail("XCTAssertNotNil \(m())", file, line) } } catch { XCTestShim.fail("threw \(error)", file, line) }
}
public func XCTAssertEqual<T: Equatable>(_ a: @autoclosure () throws -> T, _ b: @autoclosure () throws -> T, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { let x = try a(), y = try b(); if x != y { XCTestShim.fail("XCTAssertEqual (\(x)) != (\(y)) \(m())", file, line) } } catch { XCTestShim.fail("threw \(error)", file, line) }
}
public func XCTAssertNotEqual<T: Equatable>(_ a: @autoclosure () throws -> T, _ b: @autoclosure () throws -> T, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { let x = try a(), y = try b(); if x == y { XCTestShim.fail("XCTAssertNotEqual (\(x)) == (\(y)) \(m())", file, line) } } catch { XCTestShim.fail("threw \(error)", file, line) }
}
public func XCTAssertEqual<T: FloatingPoint>(_ a: @autoclosure () throws -> T, _ b: @autoclosure () throws -> T, accuracy: T, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { let x = try a(), y = try b(); if !(abs(x - y) <= accuracy) { XCTestShim.fail("XCTAssertEqual (\(x)) != (\(y)) ±\(accuracy) \(m())", file, line) } } catch { XCTestShim.fail("threw \(error)", file, line) }
}
public func XCTAssertGreaterThanOrEqual<T: Comparable>(_ a: @autoclosure () throws -> T, _ b: @autoclosure () throws -> T, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { let x = try a(), y = try b(); if !(x >= y) { XCTestShim.fail("XCTAssertGreaterThanOrEqual \(x) < \(y) \(m())", file, line) } } catch { XCTestShim.fail("threw \(error)", file, line) }
}
public func XCTAssertLessThanOrEqual<T: Comparable>(_ a: @autoclosure () throws -> T, _ b: @autoclosure () throws -> T, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { let x = try a(), y = try b(); if !(x <= y) { XCTestShim.fail("XCTAssertLessThanOrEqual \(x) > \(y) \(m())", file, line) } } catch { XCTestShim.fail("threw \(error)", file, line) }
}
public func XCTAssertThrowsError<T>(_ e: @autoclosure () throws -> T, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line, _ handler: (Error) -> Void = { _ in }) {
    do { _ = try e(); XCTestShim.fail("XCTAssertThrowsError: no error \(m())", file, line) } catch { handler(error) }
}
public func XCTAssertNoThrow<T>(_ e: @autoclosure () throws -> T, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) {
    do { _ = try e() } catch { XCTestShim.fail("XCTAssertNoThrow threw \(error) \(m())", file, line) }
}
public struct XCTUnwrapError: Error {}
public func XCTUnwrap<T>(_ e: @autoclosure () throws -> T?, _ m: @autoclosure () -> String = "", file: StaticString = #filePath, line: UInt = #line) throws -> T {
    guard let v = try e() else { XCTestShim.fail("XCTUnwrap nil \(m())", file, line); throw XCTUnwrapError() }
    return v
}
