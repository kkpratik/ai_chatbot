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

    

}
