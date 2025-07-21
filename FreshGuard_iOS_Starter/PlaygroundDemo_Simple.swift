//
//  PlaygroundDemo_Simple.swift
//  FreshGuard - Ultra-Simple Playground Version
//
//  This version is guaranteed to work in Swift Playgrounds
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    static let pastelBlue = Color(red: 0.7, green: 0.85, blue: 1.0)
    static let pastelGreen = Color(red: 0.85, green: 1.0, blue: 0.85)
    static let pastelYellow = Color(red: 1.0, green: 0.95, blue: 0.7)
    static let pastelOrange = Color(red: 1.0, green: 0.85, blue: 0.7)
    static let pastelPurple = Color(red: 0.9, green: 0.8, blue: 1.0)
}

// MARK: - Simple Food Model
struct FoodItem: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let daysLeft: Int
    
    var statusColor: Color {
        switch daysLeft {
        case ..<0: return .red
        case 0: return .orange
        case 1...2: return .yellow
        case 3...7: return .green
        default: return .blue
        }
    }
}

// MARK: - Sample Data
let foods = [
    FoodItem(name: "Bananas", emoji: "🍌", daysLeft: 2),
    FoodItem(name: "Milk", emoji: "🥛", daysLeft: 5),
    FoodItem(name: "Chicken", emoji: "🐔", daysLeft: 1),
    FoodItem(name: "Lettuce", emoji: "🥬", daysLeft: 7)
]

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
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

// MARK: - Food Card Component
struct FoodCard: View {
    let food: FoodItem
    
    var body: some View {
        VStack(spacing: 8) {
            Text(food.emoji)
                .font(.title)
            Text(food.name)
                .font(.caption)
                .fontWeight(.medium)
            Text("\(food.daysLeft) days")
                .font(.caption2)
                .foregroundColor(food.statusColor)
                .fontWeight(.semibold)
        }
        .frame(width: 80, height: 100)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome Header
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
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                
                // Stats Cards
                VStack(spacing: 16) {
                    Text("Your Impact")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 16) {
                        StatCard(title: "Points", value: "1,250", icon: "star.fill", color: .pastelYellow)
                        StatCard(title: "Items Saved", value: "42", icon: "leaf.fill", color: .pastelGreen)
                        StatCard(title: "Money Saved", value: "$127", icon: "dollarsign.circle.fill", color: .pastelBlue)
                    }
                }
                
                // Expiring Soon
                VStack(alignment: .leading, spacing: 12) {
                    Text("Expiring Soon")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(foods.prefix(3)) { food in
                                FoodCard(food: food)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("FreshGuard")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Add Food View
struct AddFoodView: View {
    @State private var foodName = "aple"
    @State private var showAI = true
    @State private var isOrganic = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("Food Details") {
                    HStack {
                        Text("Name")
                        Spacer()
                        TextField("Enter food name", text: $foodName)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if showAI {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.pastelYellow)
                            VStack(alignment: .leading) {
                                Text("Did you mean: Apple?")
                                    .font(.caption)
                                HStack {
                                    Button("Yes") { showAI = false }
                                        .font(.caption)
                                        .foregroundColor(.pastelBlue)
                                    Button("No") { showAI = false }
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .background(Color.pastelYellow.opacity(0.1))
                        .cornerRadius(8)
                    }
                    
                    Toggle("Organic Product", isOn: $isOrganic)
                }
                
                Section("Smart Features") {
                    HStack {
                        Image(systemName: "brain")
                            .foregroundColor(.pastelPurple)
                        Text("AI will calculate expiration date")
                            .font(.caption)
                    }
                    
                    Button("Add Photo for Analysis") {}
                        .foregroundColor(.pastelBlue)
                }
            }
            .navigationTitle("Add Food")
        }
    }
}

// MARK: - Insights View
struct InsightsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text("AI-Powered Insights")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Smart recommendations")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "brain.head.profile")
                            .font(.title)
                            .foregroundColor(.pastelPurple)
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Waste Analysis
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
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("3 items at risk")
                                }
                                HStack {
                                    Image(systemName: "dollarsign.circle.fill")
                                        .foregroundColor(.green)
                                    Text("$45 potential savings")
                                }
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Predictions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AI Predictions")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.pastelBlue)
                                Text("3 items expire this week")
                                Spacer()
                                Text("85%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Image(systemName: "cart")
                                    .foregroundColor(.pastelBlue)
                                Text("Shop on Thursday")
                                Spacer()
                                Text("72%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            HStack {
                                Image(systemName: "leaf")
                                    .foregroundColor(.pastelBlue)
                                Text("20% waste reduction possible")
                                Spacer()
                                Text("91%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                }
                .padding()
            }
            .navigationTitle("Smart Insights")
        }
    }
}

// MARK: - Rewards View
struct RewardsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
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
                    .padding(.top, 10)
                }
                .padding(.bottom, 20)
                .background(
                    LinearGradient(
                        colors: [Color.pastelBlue, Color.pastelPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        AchievementCard(title: "First Steps", emoji: "👶", unlocked: true)
                        AchievementCard(title: "Waste Warrior", emoji: "🛡️", unlocked: true)
                        AchievementCard(title: "Streak Master", emoji: "🔥", unlocked: false)
                        AchievementCard(title: "Eco Champion", emoji: "🌱", unlocked: false)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let title: String
    let emoji: String
    let unlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(unlocked ? Color.pastelYellow : Color(.systemGray5))
                    .frame(width: 60, height: 60)
                Text(emoji)
                    .font(.title)
                    .opacity(unlocked ? 1.0 : 0.3)
            }
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .opacity(unlocked ? 1.0 : 0.5)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(unlocked ? Color.pastelYellow.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Main App View
struct FreshGuardDemo: View {
    @State private var selectedTab = 0
    @State private var showNotification = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                DashboardView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)
            
            AddFoodView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Food")
                }
                .tag(1)
            
            InsightsView()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Insights")
                }
                .tag(2)
            
            RewardsView()
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
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.pastelGreen)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showNotification)
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

// MARK: - For Swift Playgrounds
struct ContentView: View {
    var body: some View {
        FreshGuardDemo()
    }
}
