//
//  ContentView.swift
//  FreshGuard - Food Waste Prevention App
//
//  Created for preventing food waste through smart tracking and gamification
//  Budget-friendly MVP approach for $1000 budget
//

import SwiftUI

struct ContentView: View {
    @StateObject private var foodManager = FoodManager()
    @StateObject private var gameManager = GameManager()
    @State private var selectedTab = 0
    @State private var showingNotification = false
    @State private var notificationMessage = ""
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
            // Home/Dashboard Tab
            DashboardView()
                .environmentObject(foodManager)
                .environmentObject(gameManager)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Add Food Tab
            AddFoodView()
                .environmentObject(foodManager)
                .environmentObject(gameManager)
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Food")
                }
                .tag(1)
            
            // My Fridge Tab
            FridgeView()
                .environmentObject(foodManager)
                .environmentObject(gameManager)
                .tabItem {
                    Image(systemName: "refrigerator.fill")
                    Text("My Fridge")
                }
                .tag(2)
            
            // Recipes Tab
            RecipesView()
                .environmentObject(foodManager)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Recipes")
                }
                .tag(3)
            
            // Smart Insights Tab (My Creative Enhancement)
            InsightsView()
                .environmentObject(foodManager)
                .tabItem {
                    Image(systemName: "brain.head.profile")
                    Text("Insights")
                }
                .tag(4)
            
            // Rewards Tab
            RewardsView()
                .environmentObject(gameManager)
                .tabItem {
                    Image(systemName: "medal.fill")
                    Text("Rewards")
                }
                .tag(5)
            
            // Profile/Stats Tab
            ProfileView()
                .environmentObject(gameManager)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(6)
            }
            .accentColor(Color.pastelBlue)
            
            // Custom notification banner positioned at bottom (not covering recipes button)
            if showingNotification {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.white)
                        
                        Text(notificationMessage)
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
                    .padding(.bottom, 100) // Above tab bar
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showingNotification)
            }
        }
        .onAppear {
            setupNotifications()
        }
        .onReceive(NotificationCenter.default.publisher(for: .foodItemAdded)) { notification in
            if let foodName = notification.userInfo?["foodName"] as? String {
                showNotification("Added \(foodName) to your fridge! 🎉")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .welcomeBack)) { _ in
            showNotification("Welcome back! Keep up the great work! 👋")
        }
    }
    
    private func setupNotifications() {
        NotificationManager.shared.requestPermission()
    }
    
    private func showNotification(_ message: String) {
        notificationMessage = message
        showingNotification = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showingNotification = false
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let foodItemAdded = Notification.Name("foodItemAdded")
    static let welcomeBack = Notification.Name("welcomeBack")
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var foodManager: FoodManager
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Welcome Header
                    WelcomeHeaderView()
                        .environmentObject(gameManager)
                    
                    // Quick Stats Cards
                    QuickStatsView()
                        .environmentObject(foodManager)
                        .environmentObject(gameManager)
                    
                    // Expiring Soon Section
                    ExpiringSoonView()
                        .environmentObject(foodManager)
                    
                    // Daily Challenge
                    DailyChallengeView()
                        .environmentObject(gameManager)
                }
                .padding()
            }
            .navigationTitle("FreshGuard")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Welcome Header
struct WelcomeHeaderView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
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
                
                // Streak Counter
                VStack {
                    Text("\(gameManager.currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Text("day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Quick Stats
struct QuickStatsView: View {
    @EnvironmentObject var foodManager: FoodManager
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Your Impact")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Points",
                    value: "\(gameManager.totalPoints)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Items Saved",
                    value: "\(gameManager.itemsSaved)",
                    icon: "leaf.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Money Saved",
                    value: "$\(gameManager.moneySaved, specifier: "%.0f")",
                    icon: "dollarsign.circle.fill",
                    color: .blue
                )
            }
        }
    }
}

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

// MARK: - Expiring Soon Section
struct ExpiringSoonView: View {
    @EnvironmentObject var foodManager: FoodManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Expiring Soon")
                    .font(.headline)
                
                Spacer()
                
                if !foodManager.expiringSoonItems.isEmpty {
                    Text("\(foodManager.expiringSoonItems.count) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if foodManager.expiringSoonItems.isEmpty {
                Text("Great! No items expiring soon 🎉")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(foodManager.expiringSoonItems.prefix(5)) { item in
                            ExpiringItemCard(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Expiring Item Card
struct ExpiringItemCard: View {
    let item: FoodItem
    
    var body: some View {
        VStack(spacing: 8) {
            Text(item.emoji)
                .font(.title)
            
            Text(item.name)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(item.daysUntilExpiration == 0 ? "Today!" : "\(item.daysUntilExpiration) days")
                .font(.caption2)
                .foregroundColor(item.daysUntilExpiration <= 1 ? .red : .orange)
                .fontWeight(.semibold)
        }
        .frame(width: 80, height: 100)
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Daily Challenge
struct DailyChallengeView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Challenge")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(gameManager.dailyChallenge.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(gameManager.dailyChallenge.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack {
                    Text("\(gameManager.dailyChallenge.progress)/\(gameManager.dailyChallenge.target)")
                        .font(.caption)
                        .fontWeight(.bold)
                    
                    ProgressView(value: Double(gameManager.dailyChallenge.progress), total: Double(gameManager.dailyChallenge.target))
                        .frame(width: 60)
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ContentView()
}
