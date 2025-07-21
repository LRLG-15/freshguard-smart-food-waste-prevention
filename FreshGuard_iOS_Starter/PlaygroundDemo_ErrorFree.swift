//
//  PlaygroundDemo_ErrorFree.swift
//  FreshGuard - Error-Free Playground Version
//
//  This version removes PlaygroundSupport and fixes all compilation errors
//

import SwiftUI

// MARK: - Simplified Color Extensions
extension Color {
    static let pastelBlue = Color(red: 0.7, green: 0.85, blue: 1.0)
    static let pastelGreen = Color(red: 0.85, green: 1.0, blue: 0.85)
    static let pastelYellow = Color(red: 1.0, green: 0.95, blue: 0.7)
    static let pastelOrange = Color(red: 1.0, green: 0.85, blue: 0.7)
    static let pastelPurple = Color(red: 0.9, green: 0.8, blue: 1.0)
}

// MARK: - Simplified Models
struct SimpleFoodItem: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let daysUntilExpiration: Int
    let category: String
    let isOrganic: Bool
    
    var statusColor: Color {
        switch daysUntilExpiration {
        case ..<0: return .red
        case 0: return .orange
        case 1...2: return .yellow
        case 3...7: return .green
        default: return .blue
        }
    }
}

// MARK: - Demo Data
let sampleFoodItems = [
    SimpleFoodItem(name: "Bananas", emoji: "🍌", daysUntilExpiration: 2, category: "Fruits", isOrganic: false),
    SimpleFoodItem(name: "Organic Milk", emoji: "🥛", daysUntilExpiration: 5, category: "Dairy", isOrganic: true),
    SimpleFoodItem(name: "Chicken Breast", emoji: "🐔", daysUntilExpiration: 1, category: "Meat", isOrganic: false),
    SimpleFoodItem(name: "Organic Lettuce", emoji: "🥬", daysUntilExpiration: 7, category: "Vegetables", isOrganic: true)
]

// MARK: - Helper Components
struct StatCardDemo: View {
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

struct ExpiringItemCardDemo: View {
    let item: SimpleFoodItem
    
    var body: some View {
        VStack(spacing: 8) {
            Text(item.emoji)
                .font(.title)
            Text(item.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            Text("\(item.daysUntilExpiration) days")
                .font(.caption2)
                .foregroundColor(item.statusColor)
                .fontWeight(.semibold)
        }
        .frame(width: 80, height: 100)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PredictionRowDemo: View {
    let icon: String
    let text: String
    let confidence: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pastelBlue)
                .frame(width: 20)
            Text(text)
                .font(.caption)
            Spacer()
            Text("\(confidence)%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

struct RecommendationRowDemo: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.pastelYellow)
                .font(.caption)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}

struct AchievementCardDemo: View {
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

// MARK: - Enhanced Dashboard Demo
struct EnhancedDashboardDemo: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header with new pastel theme
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
                            
                            // Enhanced streak counter
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
                    
                    // Enhanced Stats with new colors
                    VStack(spacing: 16) {
                        Text("Your Impact")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            StatCardDemo(title: "Points", value: "1,250", icon: "star.fill", color: .pastelYellow)
                            StatCardDemo(title: "Items Saved", value: "42", icon: "leaf.fill", color: .pastelGreen)
                            StatCardDemo(title: "Money Saved", value: "$127", icon: "dollarsign.circle.fill", color: .pastelBlue)
                        }
                    }
                    
                    // Expiring Soon with enhanced UI
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Expiring Soon")
                            .font(.headline)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(sampleFoodItems.prefix(3)) { item in
                                    ExpiringItemCardDemo(item: item)
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
}

// MARK: - Enhanced Add Food Demo
struct EnhancedAddFoodDemo: View {
    @State private var foodName = ""
    @State private var showingAICorrection = false
    @State private var boughtToday = true
    @State private var isFreshProduct = false
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
                    
                    // AI Correction Demo
                    if showingAICorrection {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.pastelYellow)
                            VStack(alignment: .leading) {
                                Text("Did you mean: Apple?")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                                HStack {
                                    Button("Yes") { showingAICorrection = false }
                                        .font(.caption)
                                        .foregroundColor(.pastelBlue)
                                    Button("No") { showingAICorrection = false }
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
                
                Section("Acquisition Date") {
                    Toggle("Bought Today", isOn: $boughtToday)
                    if !boughtToday {
                        DatePicker("Date Acquired", selection: .constant(Date()), displayedComponents: .date)
                    }
                }
                
                Section("Expiration") {
                    Toggle("Fresh product (AI auto-calculate)", isOn: $isFreshProduct)
                    if isFreshProduct {
                        Text("AI will calculate optimal expiration date")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Photo Analysis") {
                    Button("Add Photo for AI Analysis") {}
                        .foregroundColor(.pastelBlue)
                }
            }
            .navigationTitle("Add Food")
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if foodName.isEmpty {
                        foodName = "aple"
                        showingAICorrection = true
                    }
                }
            }
        }
    }
}

// MARK: - Smart Insights Demo
struct SmartInsightsDemo: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // AI Header
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
                                .foregroundColor(.pastelPurple)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Waste Rate Analysis
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
                    
                    // Predictive Analytics
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AI Predictions")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            PredictionRowDemo(icon: "calendar", text: "3 items likely to expire this week", confidence: 85)
                            PredictionRowDemo(icon: "cart", text: "Optimal shopping day: Thursday", confidence: 72)
                            PredictionRowDemo(icon: "leaf", text: "20% waste reduction possible", confidence: 91)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.05), radius: 5)
                    
                    // Smart Recommendations
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Smart Recommendations")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            RecommendationRowDemo(text: "🎯 Focus on smaller grocery trips")
                            RecommendationRowDemo(text: "📱 Set more frequent reminders")
                            RecommendationRowDemo(text: "🍲 Try batch cooking this week")
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

// MARK: - Rewards Demo
struct RewardsDemo: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with gradient
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
                        AchievementCardDemo(title: "First Steps", emoji: "👶", isUnlocked: true)
                        AchievementCardDemo(title: "Waste Warrior", emoji: "🛡️", isUnlocked: true)
                        AchievementCardDemo(title: "Streak Master", emoji: "🔥", isUnlocked: false)
                        AchievementCardDemo(title: "Eco Champion", emoji: "🌱", isUnlocked: false)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Main Demo View
struct PlaygroundDemoView: View {
    @State private var selectedTab = 0
    @State private var showingNotification = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Enhanced Dashboard
            EnhancedDashboardDemo()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Enhanced Add Food
            EnhancedAddFoodDemo()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Food")
                }
                .tag(1)
            
            // Smart Insights
            SmartInsightsDemo()
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Insights")
                }
                .tag(2)
            
            // Rewards System
            RewardsDemo()
                .tabItem {
                    Image(systemName: "medal.fill")
                    Text("Rewards")
                }
                .tag(3)
        }
        .accentColor(.pastelBlue)
        .overlay(
            // Custom notification demo
            VStack {
                Spacer()
                if showingNotification {
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
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingNotification)
        )
        .onAppear {
            // Demo notification
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                showingNotification = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showingNotification = false
                }
            }
        }
    }
}

// MARK: - Main App Entry Point
struct ContentView: View {
    var body: some View {
        PlaygroundDemoView()
    }
}

// MARK: - App Structure for Playground
@main
struct FreshGuardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
