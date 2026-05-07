//
//  ChatView.swift
//  ChatWithAI
//
//  Created by Pratik Parmar on 24/04/26.
//

import SwiftUI

struct ChatView: View {
    
    @ObservedObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack {
            titleView()
            chatSection()
            inputSection()
        }
        .padding()
    }
    
    @ViewBuilder
    func titleView() -> some View {
        HStack {
            Spacer()
            Text("Your AI Chat")
                .font(.system(.headline).bold())
            Spacer()
        }
    }
    
    @ViewBuilder
    func chatSection() -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(viewModel.messages) { message in
                        chatBubble(message: message)
                            .id(message.id)
                    }
                    
                    if viewModel.isLoading {
                        loadingView()
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .id("BOTTOM")
                }
            }
            .frame(maxHeight: .infinity)
            .scrollIndicators(.hidden)
            .onChange(of: viewModel.messages) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: viewModel.isLoading) {
                scrollToBottom(proxy: proxy)
            }
        }
    }
        
    @ViewBuilder
    func chatBubble(message: Message) -> some View {
        HStack {
            if message.sender == .user {
                Spacer(minLength: 8)
            }
            
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 8) {
                Text(message.text)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(message.sender == .user ? .white : .black)
                
                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.purple)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        message.sender == .ai
                        ? Color.purple.opacity(0.15)
                        : Color.purple.opacity(0.75)
                    )
            }
            
            if message.sender == .ai {
                Spacer(minLength: 8)
            }
        }
        .padding(.horizontal, 6)
    }
    
    @ViewBuilder
    func inputSection() -> some View {
        HStack {
            
            TextField(
                text: $viewModel.inputString,
                prompt: Text("Write here..")
            ) {
                
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.purple.opacity(0.2))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.purple.opacity(0.6), lineWidth: 1)
            }
            
            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "paperplane.circle")
                    .resizable()
                    .frame(width: 42, height: 42)
                    .foregroundStyle(Color.purple.opacity(0.8))
                
            }
            .disabled(!viewModel.canSendMessage)
            .opacity(viewModel.canSendMessage ? 1 : 0.4)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
    }
    
    @ViewBuilder
    func loadingView() -> some View {
        HStack() {
            TypingIndicatorView()
            Spacer()
        }
        .padding(.horizontal, 6)
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        withAnimation {
            proxy.scrollTo("BOTTOM", anchor: .bottom)
        }
    }
}


#Preview {
    ChatView(
        viewModel: ChatViewModel(
            messages: [
                Message(text: "hi", sender: .user),
                Message(text: "hi, how can i help you today", sender: .ai),
                Message(text: "i want to find some open apis related to music", sender: .user),
                Message(text: "sure, let me check..", sender: .ai)
            ],
            chatService: ChatService(networkService: NetworkManager())
        )
    )
}
