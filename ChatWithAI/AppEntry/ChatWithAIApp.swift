//
//  ChatWithAIApp.swift
//  ChatWithAI
//
//  Created by Pratik Parmar on 23/04/26.
//

import SwiftUI

@main
struct ChatWithAIApp: App {
    var body: some Scene {
        WindowGroup {
            ChatView(
                viewModel: ChatViewModel(
                    messages: [],
                    chatService: ChatService(networkService: NetworkManager())
                )
            )
        }
    }
}
