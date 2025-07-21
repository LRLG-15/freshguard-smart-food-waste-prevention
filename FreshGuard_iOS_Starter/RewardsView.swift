//
//  RewardsView.swift
//  FreshGuard - Food Waste Prevention App
//
//  Gamified rewards and achievements system
//

import SwiftUI

struct RewardsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedTab = 0
    @State private var showingAchievementDetail = false
    @State private var selectedAchievement: Achievement?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom Header with Gradient
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Your Journey")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Level \(gameManager.totalPoints / 100 + 1) • \(gameManager.totalPoints) points")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        // Profile Avatar with Level Ring
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: CGFloat(gameManager.totalPoints % 100) / 100.0)
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
                    
                    // Tab Selector
                    HStack(spacing: 0) {
                        TabButton(title: "Achievements", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabButton(title: "Streaks", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        TabButton(title: "Impact", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(
                    LinearGradient(
                        colors: [Color.pastelBlue, Color.pastelPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                
                // Content Area
                ScrollView {
                    switch selectedTab {
                    case 0:
                        AchievementsView()
                            .environmentObject(gameManager)
                    case 1:
                        StreaksView()
                            .environmentObject(gameManager)
                    case 2:
                        ImpactView()
                            .environmentObject(gameManager)
                    default:
                        AchievementsView()
                            .environmentObject(gameManager)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color.white.opacity(0.2) : Color.clear)
                )
        }
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var showingDetail = false
    @State private var selectedAchievement: Achievement?
    
    var body: some View {
        LazyVStack(spacing: 20) {
            // Progress to Next Achievement
            if let nextAchievement = gameManager.nextAchievement {
                NextAchievementCard(achievement: nextAchievement, currentPoints: gameManager.totalPoints)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
            }
            
            // Achievements Grid
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("All Achievements")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(gameManager.unlockedAchievements.count)/\(gameManager.achievements.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(gameManager.achievements) { achievement in
                        AchievementCard(achievement: achievement) {
                            selectedAchievement = achievement
                            showingDetail = true
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showingDetail) {
            if let achievement = selectedAchievement {
                AchievementDetailView(achievement: achievement)
            }
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? Color.pastelYellow : Color(.systemGray5))
                        .frame(width: 60, height: 60)
                    
                    if achievement.isUnlocked {
                        // Use a medal image from Pexels
                        AsyncImage(url: URL(string: "https://images.pexels.com/photos/1263986/pexels-photo-1263986.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&dpr=2")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        } placeholder: {
                            Text(achievement.emoji)
                                .font(.title)
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(spacing: 4) {
                    Text(achievement.title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                    
                    if !achievement.isUnlocked {
                        Text("\(achievement.pointsRequired) pts")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(achievement.isUnlocked ? Color.pastelYellow.opacity(0.1) : Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Next Achievement Card
struct NextAchievementCard: View {
    let achievement: Achievement
    let currentPoints: Int
    
    var progress: Double {
        Double(currentPoints) / Double(achievement.pointsRequired)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Next Achievement")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(currentPoints)/\(achievement.pointsRequired)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Text(achievement.emoji)
                    .font(.title)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(achievement.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(achievement.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color.pastelGreen))
                .scaleEffect(y: 2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

// MARK: - Streaks View
struct StreaksView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Current Streak Card
            VStack(spacing: 16) {
                Text("Current Streak")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ZStack {
                    Circle()
                        .fill(Color.pastelOrange.opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    VStack {
                        Text("\(gameManager.currentStreak)")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.pastelOrange)
                        
                        Text("days")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Text("Keep it up! 🔥")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Streak Stats
            VStack(alignment: .leading, spacing: 16) {
                Text("Streak Statistics")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    StreakStatRow(
                        title: "Longest Streak",
                        value: "\(gameManager.userStats.longestStreak) days",
                        icon: "flame.fill",
                        color: .pastelRed
                    )
                    
                    StreakStatRow(
                        title: "Waste Prevention Days",
                        value: "\(gameManager.userStats.wastePreventionDays)",
                        icon: "leaf.fill",
                        color: .pastelGreen
                    )
                    
                    StreakStatRow(
                        title: "Total Active Days",
                        value: "\(gameManager.userStats.totalFoodItemsAdded)",
                        icon: "calendar.badge.plus",
                        color: .pastelBlue
                    )
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
}

// MARK: - Streak Stat Row
struct StreakStatRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Impact View
struct ImpactView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Environmental Impact Hero Card
            VStack(spacing: 16) {
                Text("Your Environmental Impact")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                // Beautiful nature image from Pexels
                AsyncImage(url: URL(string: "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=400&h=200&dpr=2")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                        .cornerRadius(16)
                } placeholder: {
                    Rectangle()
                        .fill(Color.pastelGreen.opacity(0.3))
                        .frame(height: 150)
                        .cornerRadius(16)
                }
                
                Text("Every saved item makes a difference! 🌱")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // Impact Stats
            VStack(alignment: .leading, spacing: 16) {
                Text("Impact Statistics")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 20)
                
                VStack(spacing: 12) {
                    ImpactStatCard(
                        title: "CO₂ Saved",
                        value: String(format: "%.1f kg", gameManager.userStats.co2Saved),
                        subtitle: "Equivalent to planting \(Int(gameManager.userStats.co2Saved * 0.02)) trees",
                        icon: "leaf.fill",
                        color: .pastelGreen,
                        image: "https://images.pexels.com/photos/1072179/pexels-photo-1072179.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&dpr=2"
                    )
                    
                    ImpactStatCard(
                        title: "Water Saved",
                        value: String(format: "%.0f L", gameManager.userStats.waterSaved),
                        subtitle: "Enough for \(Int(gameManager.userStats.waterSaved / 8)) days of drinking water",
                        icon: "drop.fill",
                        color: .pastelBlue,
                        image: "https://images.pexels.com/photos/416528/pexels-photo-416528.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&dpr=2"
                    )
                    
                    ImpactStatCard(
                        title: "Money Saved",
                        value: String(format: "$%.0f", gameManager.moneySaved),
                        subtitle: "Keep up the great work!",
                        icon: "dollarsign.circle.fill",
                        color: .pastelYellow,
                        image: "https://images.pexels.com/photos/259027/pexels-photo-259027.jpeg?auto=compress&cs=tinysrgb&w=100&h=100&dpr=2"
                    )
                }
                .padding(.horizontal, 20)
            }
            
            Spacer()
        }
    }
}

// MARK: - Impact Stat Card
struct ImpactStatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let image: String
    
    var body: some View {
        HStack(spacing: 16) {
            AsyncImage(url: URL(string: image)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(color)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Achievement Detail View
struct AchievementDetailView: View {
    let achievement: Achievement
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // Achievement Icon
                ZStack {
                    Circle()
                        .fill(achievement.isUnlocked ? Color.pastelYellow : Color(.systemGray5))
                        .frame(width: 120, height: 120)
                    
                    if achievement.isUnlocked {
                        AsyncImage(url: URL(string: "https://images.pexels.com/photos/1263986/pexels-photo-1263986.jpeg?auto=compress&cs=tinysrgb&w=200&h=200&dpr=2")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } placeholder: {
                            Text(achievement.emoji)
                                .font(.system(size: 48))
                        }
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                    }
                }
                
                VStack(spacing: 8) {
                    Text(achievement.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(achievement.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    if achievement.isUnlocked, let date = achievement.dateUnlocked {
                        Text("Unlocked on \(date, style: .date)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    } else {
                        Text("Requires \(achievement.pointsRequired) points")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Color Extensions
extension Color {
    static let pastelBlue = Color(red: 0.7, green: 0.85, blue: 1.0)
    static let pastelGreen = Color(red: 0.85, green: 1.0, blue: 0.85)
    static let pastelYellow = Color(red: 1.0, green: 0.95, blue: 0.7)
    static let pastelOrange = Color(red: 1.0, green: 0.85, blue: 0.7)
    static let pastelPurple = Color(red: 0.9, green: 0.8, blue: 1.0)
    static let pastelRed = Color(red: 1.0, green: 0.8, blue: 0.8)
}

#Preview {
    RewardsView()
        .environmentObject(GameManager.shared)
}
