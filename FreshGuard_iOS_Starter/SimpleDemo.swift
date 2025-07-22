import SwiftUI

struct SimpleDemoView: View {
    @State private var foodName: String = ""
    @State private var suggestedEmoji: String = "🍽️"
    @StateObject private var aiManager = AIManager.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Simple FreshGuard Demo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("Enter food name", text: $foodName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: foodName) { newValue in
                        if !newValue.isEmpty {
                            suggestedEmoji = aiManager.suggestEmoji(for: newValue)
                        } else {
                            suggestedEmoji = "🍽️"
                        }
                    }
                
                Text("Suggested Emoji:")
                    .font(.headline)
                
                Text(suggestedEmoji)
                    .font(.system(size: 80))
                
                Spacer()
            }
            .padding()
            .navigationTitle("Simple Demo")
        }
    }
}

#Preview {
    SimpleDemoView()
}
