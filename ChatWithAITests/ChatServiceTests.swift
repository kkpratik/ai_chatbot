//
//  ChatServiceTests.swift
//  ChatWithAITests
//
//  Created by Pratik Parmar on 04/05/26.
//

import XCTest
@testable import ChatWithAI

class MockNetworkService: Networking {
    
    var mockData: Data?
    var mockError: Error?
    
    func request(_ endpoint: Endpoint) async throws -> Data {
        if let error = mockError {
            throw error
        }
        
        return mockData ?? Data()
    }
}

final class ChatServiceTests: XCTestCase {
    
    func test_chatService_response() async throws {
        let json = """
           {
             "choices": [
               {
                 "message": {
                   "role": "assistant",
                   "content": "Hello! How can I help you?"
                 }
               }
             ]
           }
           """
        
        let mock = MockNetworkService()
        mock.mockData = json.data(using: .utf8)
        
        let chatService = ChatService(networkService: mock)
        
        do {
            let response = try await chatService.generateResponse(
                from: [
                    Message(text: "Hi", sender: .user)
                ]
            )
            
            print("✅ Response text:", response.text)
            
            XCTAssertEqual(response.text, "Hello! How can I help you?")
            XCTAssertEqual(response.sender, .ai)
            
        } catch {
            print("❌ ChatService test failed with error:", error)
            XCTFail("Expected successful response, but got error: \(error)")
        }
    }
    
    
    func test_chatService_whenResponseInvalid_shouldThrowError() async {
        
        let json = """
            {}
            """
        
        let mock = MockNetworkService()
        mock.mockData = json.data(using: .utf8)
        
        let chatService = ChatService(networkService: mock)
        do {
            _ = try await chatService.generateResponse(from: [Message(text: "Hi", sender: .user)])
            XCTFail("Expected error but succeeded")
        } catch {
            XCTAssertEqual(error as? ServiceError, ServiceError.noResponseFound)
        }
    }
    
    func test_chatService_shouldPassOn_whenNetworkError_fromNetworkManager() async {
        let mock = MockNetworkService()
        mock.mockError = NetworkError.invalidUrl
        
        let chatService = ChatService(networkService: mock)
        do {
            _ = try await chatService.generateResponse(from: [Message(text: "Hi", sender: .user)])
            XCTFail("Expected error but succeeded")
        } catch {
            if let networkError = error as? NetworkError {
                XCTAssertEqual(networkError, .invalidUrl)
            } else {
                XCTFail("Unexpected error type")
            }
        }
    }
    
    @MainActor
    func test_viewModel_whenUnauthorisedNetworkError_appendsUnauthorisedMessage() async {
        let mockNetworkService = MockNetworkService()
        mockNetworkService.mockError = NetworkError.unauthorised
        let mockChatService = ChatService(networkService: mockNetworkService)
        
        let viewModel = ChatViewModel(messages: [Message](), chatService: mockChatService)
        viewModel.inputString = "Hi"
        await viewModel.performSendMessage()
        
        XCTAssertEqual(viewModel.messages.count, 2)
        XCTAssertEqual(viewModel.messages.last?.text, "Authorization failed. Please check the API key.")
        XCTAssertEqual(viewModel.messages.last?.sender, .ai)
    }
    
}
