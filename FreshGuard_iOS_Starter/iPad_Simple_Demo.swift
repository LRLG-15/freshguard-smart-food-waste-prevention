import SwiftUI
import PlaygroundSupport

extension Color {
    static let pastelBlue = Color(red: 0.7, green: 0.85, blue: 1.0)
    static let pastelGreen = Color(red: 0.85, green: 1.0, blue: 0.85)
    static let pastelYellow = Color(red: 1.0, green: 0.95, blue: 0.7)
    static let pastelOrange = Color(red: 1.0, green: 0.85, blue: 0.7)
}

struct FreshGuardDemo: View {
    @State private var selectedTab = 0
    @State private var showNotification = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardDemo()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            AddFoodDemo()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Food")
                }
                .tag(1)
            
            InsightsDemo()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Insights")
                }
                .tag(2)
            
            RewardsDemo()
                .tabItem {
                    Image(systemName: "medal.fill")
                    Text("Rewards")
                }
                .tag(3)
        }
        .accentColor(.pastelBlue)
        .overlay(
            VStack {
                Spacer()
                if showNotification {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        Text("Added Apple to your fridge! 🎉")
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pastelGreen)
                            .shadow(radius: 8)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom))
                }
            }
            .animation(.spring(), value: showNotification)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showNotification = false
                }
            }
        }
    }
}

struct DashboardDemo: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Good morning! 🌅")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                Text("Let's prevent food waste today")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            VStack {
                                Text("7")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.pastelOrange)
                                Text("day streak")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.pastelOrange.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    
                    VStack(spacing: 16) {
                        Text("Your Impact")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            StatCard(title: "Points", value: "1,250", color: .pastelYellow)
                            StatCard(title: "Items Saved", value: "42", color: .pastelGreen)
                            StatCard(title: "Money Saved", value: "$127", color: .pastelBlue)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("FreshGuard")
        }
    }
}

struct AddFoodDemo: View {
    @State private var foodName = ""
    @State private var showAICorrection = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Food Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Enter food name", text: $foodName)
                    }
                    
                    if showAICorrection {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.pastelYellow)
                            VStack(alignment: .leading) {
                                Text("Did you mean: Apple?")
                                    .font(.caption)
                                HStack {
                                    Button("Yes") { showAICorrection = false }
                                        .foregroundColor(.pastelBlue)
                                    Button("No") { showAICorrection = false }
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.pastelYellow.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                
                Section("New Features") {
                    Toggle("Bought Today", isOn: .constant(true))
                    Toggle("Fresh product (AI auto-calculate)", isOn: .constant(false))
                    Toggle("Organic Product", isOn: .constant(false))
                }
            }
            .navigationTitle("Add Food")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    foodName = "aple"
                    showAICorrection = true
                }
            }
        }
    }
}

struct InsightsDemo: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("AI-Powered Insights")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Text("Personalized recommendations")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "brain.head.profile")
                                .font(.title)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 5)
                    
                    VStack(spacing: 16) {
                        HStack {
                            Text("Waste Rate Analysis")
                                .font(.headline)
                            Spacer()
                            Text("Good job! 👍")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        HStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .stroke(Color(.systemGray5), lineWidth: 8)
                                    .frame(width: 80, height: 80)
                                Circle()
                                    .trim(from: 0, to: 0.15)
                                    .stroke(Color.green, lineWidth: 8)
                                    .frame(width: 80, height: 80)
                                    .rotationEffect(.degrees(-90))
                                Text("15%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("3 items at risk")
                                Text("$45 potential savings")
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 5)
                }
                .padding()
            }
            .navigationTitle("Smart Insights")
        }
    }
}

struct RewardsDemo: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Your Journey")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("Level 13 • 1,250 points")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                .frame(width: 60, height: 60)
                            Circle()
                                .trim(from: 0, to: 0.5)
                                .stroke(Color.white, lineWidth: 3)
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                            Image(systemName: "person.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        colors: [Color.pastelBlue, Color.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        AchievementCard(title: "First Steps", emoji: "👶", isUnlocked: true)
                        AchievementCard(title: "Waste Warrior", emoji: "🛡️", isUnlocked: true)
                        AchievementCard(title: "Streak Master", emoji: "🔥", isUnlocked: false)
                        AchievementCard(title: "Eco Champion", emoji: "🌱", isUnlocked: false)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct AchievementCard: View {
    let title: String
    let emoji: String
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? Color.pastelYellow : Color(.systemGray5))
                    .frame(width: 60, height: 60)
                Text(emoji)
                    .font(.title)
                    .opacity(isUnlocked ? 1.0 : 0.3)
            }
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .opacity(isUnlocked ? 1.0 : 0.5)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(isUnlocked ? Color.pastelYellow.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(16)
    }
}

let demoView = FreshGuardDemo()
PlaygroundPage.current.setLiveView(demoView)
