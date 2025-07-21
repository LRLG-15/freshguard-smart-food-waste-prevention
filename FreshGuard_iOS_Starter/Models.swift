//
//  Models.swift
//  FreshGuard - Food Waste Prevention App
//
//  Core data models for food tracking and gamification
//

import SwiftUI
import Foundation

// MARK: - Food Item Model
struct FoodItem: Identifiable, Codable {
    let id = UUID()
    var name: String
    var category: FoodCategory
    var expirationDate: Date?
    var acquiredDate: Date?  // New: When the product entered the house
    var dateAdded: Date      // When added to the app
    var emoji: String
    var isConsumed: Bool = false
    var notes: String = ""
    var isOrganic: Bool = false  // New: For better AI predictions
    var photoURL: String? = nil  // New: For AI image analysis
    
    // Computed properties
    var daysUntilExpiration: Int {
        guard let expirationDate = expirationDate else { return 999 }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let expiry = calendar.startOfDay(for: expirationDate)
        return calendar.dateComponents([.day], from: today, to: expiry).day ?? 0
    }
    
    var daysInFridge: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let acquired = calendar.startOfDay(for: acquiredDate ?? dateAdded)
        return calendar.dateComponents([.day], from: acquired, to: today).day ?? 0
    }
    
    var expirationStatus: ExpirationStatus {
        let days = daysUntilExpiration
        if days < 0 { return .expired }
        if days == 0 { return .expiringToday }
        if days <= 2 { return .expiringSoon }
        if days <= 7 { return .fresh }
        return .veryFresh
    }
    
    var statusColor: Color {
        switch expirationStatus {
        case .expired: return .red
        case .expiringToday: return .orange
        case .expiringSoon: return .yellow
        case .fresh: return .green
        case .veryFresh: return .blue
        }
    }
    
    // New: Freshness score based on days in fridge and category
    var freshnessScore: Double {
        guard let expirationDate = expirationDate else { return 0.5 }
        let totalShelfLife = expirationDate.timeIntervalSince(acquiredDate ?? dateAdded) / (24 * 60 * 60)
        let daysRemaining = Double(daysUntilExpiration)
        return max(0, min(1, daysRemaining / totalShelfLife))
    }
}

// MARK: - Food Categories
enum FoodCategory: String, CaseIterable, Codable {
    case fruits = "Fruits"
    case vegetables = "Vegetables"
    case dairy = "Dairy"
    case meat = "Meat & Fish"
    case grains = "Grains"
    case beverages = "Beverages"
    case snacks = "Snacks"
    case other = "Other"
    
    var emoji: String {
        switch self {
        case .fruits: return "🍎"
        case .vegetables: return "🥕"
        case .dairy: return "🥛"
        case .meat: return "🥩"
        case .grains: return "🌾"
        case .beverages: return "🥤"
        case .snacks: return "🍿"
        case .other: return "📦"
        }
    }
    
    var color: Color {
        switch self {
        case .fruits: return .red
        case .vegetables: return .green
        case .dairy: return .blue
        case .meat: return .pink
        case .grains: return .orange
        case .beverages: return .cyan
        case .snacks: return .purple
        case .other: return .gray
        }
    }
}

// MARK: - Expiration Status
enum ExpirationStatus {
    case expired
    case expiringToday
    case expiringSoon
    case fresh
    case veryFresh
}

// MARK: - Daily Challenge Model
struct DailyChallenge: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var target: Int
    var progress: Int = 0
    var date: Date
    var isCompleted: Bool = false
    var pointsReward: Int
    
    static let challenges = [
        DailyChallenge(title: "Zero Waste Day", description: "Don't waste any food today", target: 1, date: Date(), pointsReward: 100),
        DailyChallenge(title: "Recipe Explorer", description: "Try a suggested recipe", target: 1, date: Date(), pointsReward: 50),
        DailyChallenge(title: "Fresh Tracker", description: "Add 3 new items to your fridge", target: 3, date: Date(), pointsReward: 30),
        DailyChallenge(title: "Early Bird", description: "Use 2 items before they expire", target: 2, date: Date(), pointsReward: 75)
    ]
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var emoji: String
    var pointsRequired: Int
    var isUnlocked: Bool = false
    var dateUnlocked: Date?
    
    static let allAchievements = [
        Achievement(title: "First Steps", description: "Add your first food item", emoji: "👶", pointsRequired: 10),
        Achievement(title: "Waste Warrior", description: "Save 10 items from expiring", emoji: "🛡️", pointsRequired: 250),
        Achievement(title: "Streak Master", description: "Maintain a 7-day streak", emoji: "🔥", pointsRequired: 350),
        Achievement(title: "Recipe Master", description: "Try 10 suggested recipes", emoji: "👨‍🍳", pointsRequired: 500),
        Achievement(title: "Eco Champion", description: "Save $100 worth of food", emoji: "🌱", pointsRequired: 1000),
        Achievement(title: "Zero Waste Hero", description: "Complete 30 zero-waste days", emoji: "🦸", pointsRequired: 3000)
    ]
}

// MARK: - Recipe Model
struct Recipe: Identifiable, Codable {
    let id = UUID()
    var title: String
    var description: String
    var ingredients: [String]
    var instructions: [String]
    var prepTime: Int // minutes
    var difficulty: RecipeDifficulty
    var category: RecipeCategory
    var imageURL: String?
    
    // Computed property to check if user has ingredients
    func canMakeWith(userIngredients: [FoodItem]) -> Bool {
        let userIngredientNames = userIngredients.map { $0.name.lowercased() }
        let requiredIngredients = ingredients.map { $0.lowercased() }
        
        // Check if user has at least 70% of required ingredients
        let matchingIngredients = requiredIngredients.filter { ingredient in
            userIngredientNames.contains { userIngredient in
                userIngredient.contains(ingredient) || ingredient.contains(userIngredient)
            }
        }
        
        return Double(matchingIngredients.count) / Double(requiredIngredients.count) >= 0.7
    }
}

enum RecipeDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var emoji: String {
        switch self {
        case .easy: return "😊"
        case .medium: return "🤔"
        case .hard: return "😤"
        }
    }
}

enum RecipeCategory: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    case dessert = "Dessert"
    case smoothie = "Smoothie"
    
    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch: return "🌞"
        case .dinner: return "🌙"
        case .snack: return "🍿"
        case .dessert: return "🍰"
        case .smoothie: return "🥤"
        }
    }
}

// MARK: - User Stats Model
struct UserStats: Codable {
    var totalPoints: Int = 0
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var itemsSaved: Int = 0
    var moneySaved: Double = 0.0
    var recipesTriedCount: Int = 0
    var totalFoodItemsAdded: Int = 0
    var wastePreventionDays: Int = 0
    var lastActiveDate: Date = Date()
    
    // Environmental impact calculations
    var co2Saved: Double {
        // Rough estimate: 1 saved food item = 0.5kg CO2 saved
        return Double(itemsSaved) * 0.5
    }
    
    var waterSaved: Double {
        // Rough estimate: 1 saved food item = 50 liters water saved
        return Double(itemsSaved) * 50
    }
}

// MARK: - Notification Model
struct FoodNotification: Identifiable {
    let id = UUID()
    var foodItem: FoodItem
    var notificationType: NotificationType
    var scheduledDate: Date
    var isScheduled: Bool = false
}

enum NotificationType: String, CaseIterable {
    case threeDayWarning = "3 Day Warning"
    case oneDayWarning = "1 Day Warning"
    case expiringToday = "Expiring Today"
    case expired = "Expired"
    
    var title: String {
        switch self {
        case .threeDayWarning: return "Food Expiring Soon"
        case .oneDayWarning: return "Food Expires Tomorrow"
        case .expiringToday: return "Food Expires Today!"
        case .expired: return "Food Has Expired"
        }
    }
    
    var body: String {
        switch self {
        case .threeDayWarning: return "expires in 3 days. Plan to use it soon!"
        case .oneDayWarning: return "expires tomorrow. Use it today!"
        case .expiringToday: return "expires today. Use it now!"
        case .expired: return "has expired. Consider removing it."
        }
    }
}

// MARK: - Sample Data for Development
extension FoodItem {
    static let sampleItems = [
        FoodItem(name: "Bananas", category: .fruits, expirationDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()), acquiredDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()), dateAdded: Date(), emoji: "🍌", isConsumed: false, notes: "", isOrganic: false, photoURL: nil),
        FoodItem(name: "Milk", category: .dairy, expirationDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()), acquiredDate: Calendar.current.date(byAdding: .day, value: -2, to: Date()), dateAdded: Date(), emoji: "🥛", isConsumed: false, notes: "", isOrganic: true, photoURL: nil),
        FoodItem(name: "Chicken Breast", category: .meat, expirationDate: Calendar.current.date(byAdding: .day, value: 1, to: Date()), acquiredDate: Date(), dateAdded: Date(), emoji: "🐔", isConsumed: false, notes: "", isOrganic: false, photoURL: nil),
        FoodItem(name: "Lettuce", category: .vegetables, expirationDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()), acquiredDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()), dateAdded: Date(), emoji: "🥬", isConsumed: false, notes: "", isOrganic: true, photoURL: nil),
        FoodItem(name: "Bread", category: .grains, expirationDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()), acquiredDate: Date(), dateAdded: Date(), emoji: "🍞", isConsumed: false, notes: "", isOrganic: false, photoURL: nil)
    ]
}

extension Recipe {
    static let sampleRecipes = [
        Recipe(
            title: "Banana Smoothie",
            description: "A quick and healthy smoothie using ripe bananas",
            ingredients: ["Bananas", "Milk", "Honey"],
            instructions: ["Peel bananas", "Add all ingredients to blender", "Blend until smooth", "Serve immediately"],
            prepTime: 5,
            difficulty: .easy,
            category: .smoothie
        ),
        Recipe(
            title: "Chicken Salad",
            description: "Fresh salad with grilled chicken",
            ingredients: ["Chicken Breast", "Lettuce", "Tomatoes"],
            instructions: ["Grill chicken breast", "Chop lettuce and tomatoes", "Combine all ingredients", "Add dressing"],
            prepTime: 20,
            difficulty: .medium,
            category: .lunch
        ),
        Recipe(
            title: "French Toast",
            description: "Classic breakfast using day-old bread",
            ingredients: ["Bread", "Milk", "Eggs"],
            instructions: ["Beat eggs with milk", "Dip bread in mixture", "Cook in pan until golden", "Serve with syrup"],
            prepTime: 15,
            difficulty: .easy,
            category: .breakfast
        )
    ]
}
