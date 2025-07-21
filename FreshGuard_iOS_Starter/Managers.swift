//
//  Managers.swift
//  FreshGuard - Food Waste Prevention App
//
//  Core managers for food tracking, gamification, and notifications
//

import SwiftUI
import Foundation
import UserNotifications

// MARK: - Food Manager
class FoodManager: ObservableObject {
    @Published var foodItems: [FoodItem] = []
    @Published var isLoading = false
    
    private let userDefaults = UserDefaults.standard
    private let foodItemsKey = "SavedFoodItems"
    
    init() {
        loadFoodItems()
    }
    
    // MARK: - Computed Properties
    var expiringSoonItems: [FoodItem] {
        foodItems.filter { !$0.isConsumed && $0.daysUntilExpiration <= 3 && $0.daysUntilExpiration >= 0 }
            .sorted { $0.daysUntilExpiration < $1.daysUntilExpiration }
    }
    
    var expiredItems: [FoodItem] {
        foodItems.filter { !$0.isConsumed && $0.daysUntilExpiration < 0 }
    }
    
    var freshItems: [FoodItem] {
        foodItems.filter { !$0.isConsumed && $0.daysUntilExpiration > 3 }
    }
    
    var itemsByCategory: [FoodCategory: [FoodItem]] {
        Dictionary(grouping: foodItems.filter { !$0.isConsumed }) { $0.category }
    }
    
    // MARK: - CRUD Operations
    func addFoodItem(_ item: FoodItem) {
        var newItem = item
        newItem.dateAdded = Date()
        
        // Ensure acquiredDate is set if not provided
        if newItem.acquiredDate == nil {
            newItem.acquiredDate = Date()
        }
        
        foodItems.append(newItem)
        saveFoodItems()
        
        // Schedule notifications for this item
        NotificationManager.shared.scheduleNotifications(for: newItem)
        
        // Update game stats
        GameManager.shared.addPoints(10) // Points for adding food
        GameManager.shared.incrementFoodItemsAdded()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func updateFoodItem(_ item: FoodItem) {
        if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
            foodItems[index] = item
            saveFoodItems()
        }
    }
    
    func deleteFoodItem(_ item: FoodItem) {
        foodItems.removeAll { $0.id == item.id }
        saveFoodItems()
        
        // Cancel notifications for this item
        NotificationManager.shared.cancelNotifications(for: item)
    }
    
    func markAsConsumed(_ item: FoodItem) {
        if let index = foodItems.firstIndex(where: { $0.id == item.id }) {
            foodItems[index].isConsumed = true
            saveFoodItems()
            
            // Award points for preventing waste
            let pointsAwarded = calculatePointsForConsumption(item)
            GameManager.shared.addPoints(pointsAwarded)
            GameManager.shared.incrementItemsSaved()
            
            // Estimate money saved (rough calculation)
            let moneySaved = estimateMoneySaved(for: item)
            GameManager.shared.addMoneySaved(moneySaved)
            
            // Cancel notifications
            NotificationManager.shared.cancelNotifications(for: item)
            
            // Success haptic
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }
    }
    
    // MARK: - Helper Methods
    private func calculatePointsForConsumption(_ item: FoodItem) -> Int {
        switch item.expirationStatus {
        case .expired: return 5 // Still some points for cleanup
        case .expiringToday: return 50 // Great timing!
        case .expiringSoon: return 25 // Good prevention
        case .fresh: return 15 // Normal consumption
        case .veryFresh: return 10 // Early consumption
        }
    }
    
    private func estimateMoneySaved(for item: FoodItem) -> Double {
        // Rough estimates based on food category
        switch item.category {
        case .meat: return 8.0
        case .dairy: return 4.0
        case .fruits: return 3.0
        case .vegetables: return 2.5
        case .grains: return 2.0
        case .beverages: return 3.5
        case .snacks: return 2.0
        case .other: return 2.5
        }
    }
    
    // MARK: - Data Persistence
    private func saveFoodItems() {
        if let encoded = try? JSONEncoder().encode(foodItems) {
            userDefaults.set(encoded, forKey: foodItemsKey)
        }
    }
    
    private func loadFoodItems() {
        if let data = userDefaults.data(forKey: foodItemsKey),
           let decoded = try? JSONDecoder().decode([FoodItem].self, from: data) {
            foodItems = decoded
        } else {
            // Load sample data for development
            #if DEBUG
            foodItems = FoodItem.sampleItems
            #endif
        }
    }
    
    // MARK: - Search and Filter
    func searchItems(query: String) -> [FoodItem] {
        if query.isEmpty {
            return foodItems.filter { !$0.isConsumed }
        }
        return foodItems.filter { !$0.isConsumed && $0.name.localizedCaseInsensitiveContains(query) }
    }
    
    func itemsInCategory(_ category: FoodCategory) -> [FoodItem] {
        return foodItems.filter { !$0.isConsumed && $0.category == category }
    }
}

// MARK: - Game Manager
class GameManager: ObservableObject {
    @Published var userStats = UserStats()
    @Published var achievements: [Achievement] = Achievement.allAchievements
    @Published var dailyChallenge: DailyChallenge
    
    static let shared = GameManager()
    
    private let userDefaults = UserDefaults.standard
    private let userStatsKey = "UserStats"
    private let achievementsKey = "Achievements"
    private let dailyChallengeKey = "DailyChallenge"
    
    init() {
        // Initialize with a random daily challenge
        self.dailyChallenge = DailyChallenge.challenges.randomElement() ?? DailyChallenge.challenges[0]
        loadGameData()
        checkForNewDay()
    }
    
    // MARK: - Computed Properties
    var totalPoints: Int { userStats.totalPoints }
    var currentStreak: Int { userStats.currentStreak }
    var itemsSaved: Int { userStats.itemsSaved }
    var moneySaved: Double { userStats.moneySaved }
    
    var unlockedAchievements: [Achievement] {
        achievements.filter { $0.isUnlocked }
    }
    
    var nextAchievement: Achievement? {
        achievements.filter { !$0.isUnlocked }.min { $0.pointsRequired < $1.pointsRequired }
    }
    
    // MARK: - Points and Rewards
    func addPoints(_ points: Int) {
        userStats.totalPoints += points
        checkForNewAchievements()
        saveGameData()
        
        // Update daily challenge progress if applicable
        updateDailyChallengeProgress()
    }
    
    func incrementItemsSaved() {
        userStats.itemsSaved += 1
        updateStreak()
        saveGameData()
    }
    
    func addMoneySaved(_ amount: Double) {
        userStats.moneySaved += amount
        saveGameData()
    }
    
    func incrementFoodItemsAdded() {
        userStats.totalFoodItemsAdded += 1
        updateDailyChallengeProgress()
        saveGameData()
    }
    
    func incrementRecipesTried() {
        userStats.recipesTriedCount += 1
        addPoints(25) // Bonus points for trying recipes
        updateDailyChallengeProgress()
        saveGameData()
    }
    
    // MARK: - Streak Management
    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let lastActive = calendar.startOfDay(for: userStats.lastActiveDate)
        
        if calendar.isDate(lastActive, inSameDayAs: today) {
            // Same day, no change to streak
            return
        } else if calendar.dateComponents([.day], from: lastActive, to: today).day == 1 {
            // Consecutive day, increment streak
            userStats.currentStreak += 1
            userStats.wastePreventionDays += 1
        } else {
            // Streak broken, reset
            userStats.currentStreak = 1
        }
        
        // Update longest streak
        if userStats.currentStreak > userStats.longestStreak {
            userStats.longestStreak = userStats.currentStreak
        }
        
        userStats.lastActiveDate = Date()
    }
    
    // MARK: - Achievements
    private func checkForNewAchievements() {
        for index in achievements.indices {
            if !achievements[index].isUnlocked && userStats.totalPoints >= achievements[index].pointsRequired {
                achievements[index].isUnlocked = true
                achievements[index].dateUnlocked = Date()
                
                // Show achievement notification
                showAchievementUnlocked(achievements[index])
            }
        }
    }
    
    private func showAchievementUnlocked(_ achievement: Achievement) {
        // This would trigger a celebration animation in the UI
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
        
        // You could also show a custom alert or animation here
        print("🎉 Achievement Unlocked: \(achievement.title)")
    }
    
    // MARK: - Daily Challenge
    private func checkForNewDay() {
        let calendar = Calendar.current
        let today = Date()
        
        if !calendar.isDate(dailyChallenge.date, inSameDayAs: today) {
            // New day, generate new challenge
            generateNewDailyChallenge()
        }
    }
    
    private func generateNewDailyChallenge() {
        dailyChallenge = DailyChallenge.challenges.randomElement() ?? DailyChallenge.challenges[0]
        dailyChallenge.date = Date()
        dailyChallenge.progress = 0
        dailyChallenge.isCompleted = false
        saveGameData()
    }
    
    private func updateDailyChallengeProgress() {
        guard !dailyChallenge.isCompleted else { return }
        
        // Update progress based on challenge type
        switch dailyChallenge.title {
        case "Fresh Tracker":
            // This would be called when food items are added
            dailyChallenge.progress = min(dailyChallenge.progress + 1, dailyChallenge.target)
        case "Recipe Explorer":
            // This would be called when recipes are tried
            if userStats.recipesTriedCount > 0 {
                dailyChallenge.progress = 1
            }
        default:
            break
        }
        
        // Check if challenge is completed
        if dailyChallenge.progress >= dailyChallenge.target && !dailyChallenge.isCompleted {
            completeDailyChallenge()
        }
        
        saveGameData()
    }
    
    private func completeDailyChallenge() {
        dailyChallenge.isCompleted = true
        addPoints(dailyChallenge.pointsReward)
        
        // Celebration feedback
        let successFeedback = UINotificationFeedbackGenerator()
        successFeedback.notificationOccurred(.success)
        
        print("🎯 Daily Challenge Completed: \(dailyChallenge.title)")
    }
    
    // MARK: - Data Persistence
    private func saveGameData() {
        // Save user stats
        if let statsData = try? JSONEncoder().encode(userStats) {
            userDefaults.set(statsData, forKey: userStatsKey)
        }
        
        // Save achievements
        if let achievementsData = try? JSONEncoder().encode(achievements) {
            userDefaults.set(achievementsData, forKey: achievementsKey)
        }
        
        // Save daily challenge
        if let challengeData = try? JSONEncoder().encode(dailyChallenge) {
            userDefaults.set(challengeData, forKey: dailyChallengeKey)
        }
    }
    
    private func loadGameData() {
        // Load user stats
        if let statsData = userDefaults.data(forKey: userStatsKey),
           let decodedStats = try? JSONDecoder().decode(UserStats.self, from: statsData) {
            userStats = decodedStats
        }
        
        // Load achievements
        if let achievementsData = userDefaults.data(forKey: achievementsKey),
           let decodedAchievements = try? JSONDecoder().decode([Achievement].self, from: achievementsData) {
            achievements = decodedAchievements
        }
        
        // Load daily challenge
        if let challengeData = userDefaults.data(forKey: dailyChallengeKey),
           let decodedChallenge = try? JSONDecoder().decode(DailyChallenge.self, from: challengeData) {
            dailyChallenge = decodedChallenge
        }
    }
    
    // MARK: - Reset (for testing)
    func resetGameData() {
        userStats = UserStats()
        achievements = Achievement.allAchievements
        generateNewDailyChallenge()
        saveGameData()
    }
}

// MARK: - Notification Manager
class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    override init() {
        super.init()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotifications(for item: FoodItem) {
        guard let expirationDate = item.expirationDate else { return }
        
        let calendar = Calendar.current
        let notificationTypes: [NotificationType] = [.threeDayWarning, .oneDayWarning, .expiringToday]
        
        for notificationType in notificationTypes {
            let daysToSubtract: Int
            switch notificationType {
            case .threeDayWarning: daysToSubtract = 3
            case .oneDayWarning: daysToSubtract = 1
            case .expiringToday: daysToSubtract = 0
            case .expired: continue // We don't schedule expired notifications
            }
            
            guard let notificationDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: expirationDate),
                  notificationDate > Date() else { continue }
            
            let content = UNMutableNotificationContent()
            content.title = notificationType.title
            content.body = "\(item.name) \(notificationType.body)"
            content.sound = .default
            content.badge = 1
            
            // Add custom data
            content.userInfo = [
                "foodItemId": item.id.uuidString,
                "notificationType": notificationType.rawValue
            ]
            
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let identifier = "\(item.id.uuidString)-\(notificationType.rawValue)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func cancelNotifications(for item: FoodItem) {
        let identifiers = NotificationType.allCases.map { "\(item.id.uuidString)-\($0.rawValue)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

// MARK: - Recipe Manager
class RecipeManager: ObservableObject {
    @Published var recipes: [Recipe] = Recipe.sampleRecipes
    @Published var suggestedRecipes: [Recipe] = []
    @Published var isLoading = false
    
    func getSuggestedRecipes(for foodItems: [FoodItem]) {
        isLoading = true
        
        // Filter recipes that can be made with available ingredients
        let availableRecipes = recipes.filter { recipe in
            recipe.canMakeWith(userIngredients: foodItems)
        }
        
        // Prioritize recipes that use expiring ingredients
        let expiringItems = foodItems.filter { $0.daysUntilExpiration <= 3 }
        let prioritizedRecipes = availableRecipes.sorted { recipe1, recipe2 in
            let recipe1Score = calculateRecipeScore(recipe1, expiringItems: expiringItems)
            let recipe2Score = calculateRecipeScore(recipe2, expiringItems: expiringItems)
            return recipe1Score > recipe2Score
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Simulate API delay
            self.suggestedRecipes = Array(prioritizedRecipes.prefix(5))
            self.isLoading = false
        }
    }
    
    private func calculateRecipeScore(_ recipe: Recipe, expiringItems: [FoodItem]) -> Int {
        var score = 0
        
        // Higher score for recipes using expiring ingredients
        for ingredient in recipe.ingredients {
            if expiringItems.contains(where: { $0.name.localizedCaseInsensitiveContains(ingredient) }) {
                score += 10
            }
        }
        
        // Bonus for easier recipes
        switch recipe.difficulty {
        case .easy: score += 5
        case .medium: score += 3
        case .hard: score += 1
        }
        
        // Bonus for quicker recipes
        if recipe.prepTime <= 15 {
            score += 3
        } else if recipe.prepTime <= 30 {
            score += 1
        }
        
        return score
    }
}
