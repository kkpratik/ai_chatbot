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
                VStack(spacing: 18) {
                    ForEach(viewModel.messages) { message in
                        chatBubble(message: message)
                            .id(message.id)
                    }
                    
                    if viewModel.isLoading {
                        loadingView()
                    }
                }
            }
            .frame(maxHeight: .infinity)
            .scrollIndicators(.hidden)
            .onChange(of: viewModel.messages) {
                if let lastId = viewModel.messages.last?.id {
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func chatBubble(message: Message) -> some View {
        HStack {
            if message.sender == .user { Spacer(minLength: 40) }
            
            Text(message.text)
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(message.sender == .ai ? Color.purple.opacity(0.2) : Color.purple.opacity(0.8))
                }
            
            if message.sender == .ai { Spacer(minLength: 40) }
        }
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
                    .stroke(Color.purple.opacity(0.8), lineWidth: 1)
            }
            
            Button {
                viewModel.sendMessage()
            } label: {
                Image(systemName: "paperplane.circle")
                    .resizable()
                    .frame(width: 42, height: 42)
                    .foregroundStyle(viewModel.canSendMessage ? Color.purple.opacity(0.8) : Color.gray)
                
            }
            .disabled(!viewModel.canSendMessage)
            
        }
        .frame(maxWidth: .infinity)
        .frame(height: 64)
    }
    
    @ViewBuilder
    func loadingView() -> some View {
        HStack() {
            Text("Loading...")
                .padding(.horizontal, 18)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.purple.opacity(0.2))
                }
            Spacer()
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
