import XCTest
@testable import HabitTracker

final class GeminiSyncServiceTests: XCTestCase {
    private var service: GeminiSyncService!
    private var customSession: URLSession!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        customSession = URLSession(configuration: config)
        service = GeminiSyncService(session: customSession)
    }
    
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        customSession = nil
        service = nil
        super.tearDown()
    }
    
    func testMissingApiKey_ThrowsError() async {
        do {
            _ = try await service.fetchLatestInterviewQuestions(categories: ["Mobile"], apiKey: "   ")
            XCTFail("Expected missingApiKey error")
        } catch let error as GeminiSyncService.SyncError {
            guard case .missingApiKey = error else {
                return XCTFail("Unexpected error: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchInterviewQuestions_Success() async throws {
        let jsonMock = """
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {
                    "text": "[{\\"title\\":\\"Swift 6 Sendable\\",\\"category\\":\\"Mobile\\",\\"question\\":\\"What is Sendable protocol?\\",\\"keyTakeaways\\":\\"Thread safety\\",\\"companyTag\\":\\"Apple\\",\\"difficulty\\":\\"Medium\\"}]"
                  }
                ]
              }
            }
          ]
        }
        """
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, jsonMock.data(using: .utf8)!)
        }
        
        let questions = try await service.fetchLatestInterviewQuestions(categories: ["Mobile"], apiKey: "test_key_123")
        XCTAssertEqual(questions.count, 1)
        XCTAssertEqual(questions.first?.title, "Swift 6 Sendable")
        XCTAssertEqual(questions.first?.companyTag, "Apple")
        XCTAssertEqual(questions.first?.difficulty, "Medium")
    }
    
    func testGenerateCurriculum_Success() async throws {
        let jsonMock = """
        {
          "candidates": [
            {
              "content": {
                "parts": [
                  {
                    "text": "[{\\"title\\":\\"ARC and Memory Leaks\\",\\"description\\":\\"Learn retain cycles and weak references\\",\\"estimatedMinutes\\":30}]"
                  }
                ]
              }
            }
          ]
        }
        """
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, jsonMock.data(using: .utf8)!)
        }
        
        let curriculum = try await service.generateCurriculum(track: "Swift", targetMinutes: 30, apiKey: "test_key_123")
        XCTAssertEqual(curriculum.count, 1)
        XCTAssertEqual(curriculum.first?.title, "ARC and Memory Leaks")
        XCTAssertEqual(curriculum.first?.estimatedMinutes, 30)
    }
    
    func testHttpError_ThrowsNetworkError() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 401,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, "Unauthorized API Key".data(using: .utf8)!)
        }
        
        do {
            _ = try await service.fetchLatestInterviewQuestions(categories: ["Mobile"], apiKey: "invalid_key")
            XCTFail("Expected networkError with HTTP 401")
        } catch let error as GeminiSyncService.SyncError {
            guard case .networkError(let message) = error else {
                return XCTFail("Unexpected error type: \(error)")
            }
            XCTAssertTrue(message.contains("401"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testEmptyResponse_ThrowsEmptyResponseError() async {
        let jsonMock = """
        {
          "candidates": []
        }
        """
        
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, jsonMock.data(using: .utf8)!)
        }
        
        do {
            _ = try await service.fetchLatestInterviewQuestions(categories: ["Mobile"], apiKey: "key")
            XCTFail("Expected emptyResponse error")
        } catch let error as GeminiSyncService.SyncError {
            guard case .emptyResponse = error else {
                return XCTFail("Unexpected error type: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}
