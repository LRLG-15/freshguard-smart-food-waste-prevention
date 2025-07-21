//
//  AIManager.swift
//  FreshGuard - Food Waste Prevention App
//
//  AI-powered food analysis and smart recommendations
//

import UIKit
import SwiftUI
import Foundation

class AIManager: ObservableObject {
    static let shared = AIManager()
    
    @Published var isAnalyzing = false
    
    private init() {}
    
    // MARK: - Food Name Analysis & Correction
    func analyzeFoodItemName(input: String) -> (correctedName: String, suggestedCategory: FoodCategory?, confidence: Double) {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        var corrected = trimmed
        var category: FoodCategory? = nil
        var confidence: Double = 1.0
        
        // Common spelling corrections
        let corrections: [String: String] = [
            "aple": "Apple",
            "banan": "Banana",
            "tomatoe": "Tomato",
            "potatoe": "Potato",
            "chiken": "Chicken",
            "bred": "Bread",
            "mlik": "Milk",
            "chees": "Cheese",
            "letuce": "Lettuce",
            "carot": "Carrot"
        ]
        
        // Language translations (Spanish/French to English)
        let translations: [String: (english: String, category: FoodCategory)] = [
            "manzana": ("Apple", .fruits),
            "plátano": ("Banana", .fruits),
            "leche": ("Milk", .dairy),
            "queso": ("Cheese", .dairy),
            "pollo": ("Chicken", .meat),
            "carne": ("Meat", .meat),
            "carne de hamburgesa": ("Hamburger", .meat),
            "hamburguesa": ("Hamburger", .meat),
            "pan": ("Bread", .grains),
            "tomate": ("Tomato", .vegetables),
            "lechuga": ("Lettuce", .vegetables),
            "zanahoria": ("Carrot", .vegetables),
            "pomme": ("Apple", .fruits),
            "banane": ("Banana", .fruits),
            "lait": ("Milk", .dairy),
            "fromage": ("Cheese", .dairy),
            "poulet": ("Chicken", .meat),
            "viande": ("Meat", .meat),
            "pain": ("Bread", .grains),
            "tomate": ("Tomato", .vegetables),
            "laitue": ("Lettuce", .vegetables),
            "carotte": ("Carrot", .vegetables)
        ]
        
        let lowercased = trimmed.lowercased()
        
        // Check for translations first
        for (foreign, translation) in translations {
            if lowercased.contains(foreign) {
                corrected = translation.english
                category = translation.category
                confidence = 0.9
                break
            }
        }
        
        // Check for spelling corrections
        if category == nil {
            for (misspelled, correct) in corrections {
                if lowercased.contains(misspelled) {
                    corrected = correct
                    confidence = 0.8
                    break
                }
            }
        }
        
        // Auto-categorize based on keywords if not already set
        if category == nil {
            category = categorizeByKeywords(corrected)
        }
        
        return (corrected, category, confidence)
    }
    
    // MARK: - Emoji Suggestion
    func suggestEmoji(for productName: String) -> String {
        let lowercased = productName.lowercased()
        
        let emojiMap: [String: String] = [
            "apple": "🍎",
            "banana": "🍌",
            "milk": "🥛",
            "chicken": "🐔",
            "lettuce": "🥬",
            "bread": "🍞",
            "cheese": "🧀",
            "carrot": "🥕",
            "grape": "🍇",
            "avocado": "🥑",
            "tomato": "🍅",
            "potato": "🥔",
            "cucumber": "🥒",
            "corn": "🌽",
            "broccoli": "🥦",
            "strawberry": "🍓",
            "kiwi": "🥝",
            "orange": "🍊",
            "mango": "🥭",
            "peach": "🍑",
            "egg": "🥚",
            "fish": "🐟",
            "beef": "🥩",
            "pork": "🍖",
            "rice": "🍚",
            "pasta": "🍝",
            "coffee": "☕️",
            "tea": "🍵"
        ]
        
        for (key, emoji) in emojiMap {
            if lowercased.contains(key) {
                return emoji
            }
        }
        
        return "🍽️" // default emoji
    }
    
    private func categorizeByKeywords(_ name: String) -> FoodCategory? {
        let lowercased = name.lowercased()
        
        let fruitKeywords = ["apple", "banana", "orange", "grape", "berry", "fruit", "mango", "kiwi", "peach", "pear"]
        let vegetableKeywords = ["lettuce", "carrot", "tomato", "potato", "onion", "pepper", "broccoli", "spinach", "cucumber"]
        let dairyKeywords = ["milk", "cheese", "yogurt", "butter", "cream", "dairy"]
        let meatKeywords = ["chicken", "beef", "pork", "fish", "meat", "turkey", "salmon", "tuna", "hamburger"]
        let grainKeywords = ["bread", "rice", "pasta", "cereal", "oats", "wheat", "grain"]
        let beverageKeywords = ["juice", "soda", "water", "coffee", "tea", "drink", "beverage"]
        
        if fruitKeywords.contains(where: { lowercased.contains($0) }) { return .fruits }
        if vegetableKeywords.contains(where: { lowercased.contains($0) }) { return .vegetables }
        if dairyKeywords.contains(where: { lowercased.contains($0) }) { return .dairy }
        if meatKeywords.contains(where: { lowercased.contains($0) }) { return .meat }
        if grainKeywords.contains(where: { lowercased.contains($0) }) { return .grains }
        if beverageKeywords.contains(where: { lowercased.contains($0) }) { return .beverages }
        
        return nil
    }
    
    // MARK: - Food Image Analysis
    func analyzeFoodImage(image: UIImage, completion: @escaping (FoodImageAnalysis) -> Void) {
        isAnalyzing = true
        
        // Simulate AI processing time
        DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
            DispatchQueue.main.async {
                self.isAnalyzing = false
                
                // Simulate AI analysis results
                let freshness = Double.random(in: 0.3...1.0)
                let isFresh = freshness > 0.6
                
                let analysis = FoodImageAnalysis(
                    isFresh: isFresh,
                    freshnessScore: freshness,
                    analysisMessage: self.generateFreshnessMessage(score: freshness),
                    detectedItems: self.simulateDetectedItems(),
                    recommendations: self.generateRecommendations(freshness: freshness)
                )
                
                completion(analysis)
            }
        }
    }
    
    private func generateFreshnessMessage(score: Double) -> String {
        switch score {
        case 0.8...1.0:
            return "Looks perfectly fresh and ready to eat! 🌟"
        case 0.6...0.8:
            return "Appears fresh, should be consumed soon. ✅"
        case 0.4...0.6:
            return "Shows some signs of aging, use within 1-2 days. ⚠️"
        case 0.2...0.4:
            return "Quality is declining, consider using immediately. 🔶"
        default:
            return "May not be safe to consume. Consider discarding. ❌"
        }
    }
    
    private func simulateDetectedItems() -> [String] {
        let possibleItems = ["Apple", "Banana", "Lettuce", "Tomato", "Bread", "Cheese"]
        return Array(possibleItems.shuffled().prefix(Int.random(in: 1...3)))
    }
    
    private func generateRecommendations(freshness: Double) -> [String] {
        if freshness > 0.8 {
            return ["Store in optimal conditions", "Perfect for raw consumption", "Can be used in any recipe"]
        } else if freshness > 0.6 {
            return ["Use within 2-3 days", "Great for cooking", "Consider meal prep"]
        } else if freshness > 0.4 {
            return ["Cook thoroughly before eating", "Use in soups or stews", "Freeze if not using immediately"]
        } else {
            return ["Not recommended for consumption", "Consider composting", "Check for spoilage signs"]
        }
    }
    
    // MARK: - Smart Expiration Calculation
    func calculateSmartExpiry(for category: FoodCategory, acquiredDate: Date, isOrganic: Bool = false) -> Date {
        var baseShelfLife: Int
        
        switch category {
        case .fruits:
            baseShelfLife = isOrganic ? 5 : 7
        case .vegetables:
            baseShelfLife = isOrganic ? 4 : 6
        case .dairy:
            baseShelfLife = 10
        case .meat:
            baseShelfLife = 3
        case .grains:
            baseShelfLife = 14
        case .beverages:
            baseShelfLife = 30
        case .snacks:
            baseShelfLife = 60
        case .other:
            baseShelfLife = 7
        }
        
        // Add some randomness to simulate real-world variation
        let variation = Int.random(in: -1...2)
        let finalShelfLife = max(1, baseShelfLife + variation)
        
        return Calendar.current.date(byAdding: .day, value: finalShelfLife, to: acquiredDate) ?? acquiredDate
    }
    
    // MARK: - Smart Insights & Predictions
    func generateWasteInsights(for items: [FoodItem]) -> WasteInsights {
        let totalItems = items.count
        let expiredItems = items.filter { $0.daysUntilExpiration < 0 && !$0.isConsumed }
        let expiringSoon = items.filter { $0.daysUntilExpiration <= 2 && $0.daysUntilExpiration >= 0 && !$0.isConsumed }
        
        let wasteRate = totalItems > 0 ? Double(expiredItems.count) / Double(totalItems) : 0.0
        let riskItems = expiringSoon.count
        
        // Calculate category-based insights
        let categoryWaste = Dictionary(grouping: expiredItems) { $0.category }
        let mostWastedCategory = categoryWaste.max { $0.value.count < $1.value.count }?.key
        
        // Generate personalized recommendations
        let recommendations = generatePersonalizedRecommendations(
            wasteRate: wasteRate,
            riskItems: riskItems,
            mostWastedCategory: mostWastedCategory
        )
        
        return WasteInsights(
            wasteRate: wasteRate,
            itemsAtRisk: riskItems,
            mostWastedCategory: mostWastedCategory,
            recommendations: recommendations,
            projectedSavings: calculateProjectedSavings(wasteRate: wasteRate),
            environmentalImpact: calculateEnvironmentalImpact(savedItems: items.filter { $0.isConsumed }.count)
        )
    }
    
    private func generatePersonalizedRecommendations(wasteRate: Double, riskItems: Int, mostWastedCategory: FoodCategory?) -> [String] {
        var recommendations: [String] = []
        
        if wasteRate > 0.3 {
            recommendations.append("🎯 Focus on smaller grocery trips to reduce waste")
            recommendations.append("📱 Set more frequent expiration reminders")
        }
        
        if riskItems > 3 {
            recommendations.append("⚡ Plan meals using items expiring soon")
            recommendations.append("🍲 Try batch cooking to use multiple ingredients")
        }
        
        if let category = mostWastedCategory {
            recommendations.append("🔍 Consider buying less \(category.rawValue.lowercased()) or storing them differently")
        }
        
        recommendations.append("🌟 You're doing great! Keep tracking to improve further")
        
        return recommendations
    }
    
    private func calculateProjectedSavings(wasteRate: Double) -> Double {
        let averageMonthlySpend = 300.0 // Assume average monthly grocery spend
        let potentialSavings = averageMonthlySpend * wasteRate
        return max(0, potentialSavings)
    }
    
    private func calculateEnvironmentalImpact(savedItems: Int) -> EnvironmentalImpact {
        let co2PerItem = 0.5 // kg CO2 per saved item
        let waterPerItem = 50.0 // liters per saved item
        
        return EnvironmentalImpact(
            co2Saved: Double(savedItems) * co2PerItem,
            waterSaved: Double(savedItems) * waterPerItem,
            equivalentTrees: Double(savedItems) * 0.02 // Rough estimate
        )
    }
}

// MARK: - Supporting Models
struct FoodImageAnalysis {
    let isFresh: Bool
    let freshnessScore: Double
    let analysisMessage: String
    let detectedItems: [String]
    let recommendations: [String]
}

struct WasteInsights {
    let wasteRate: Double
    let itemsAtRisk: Int
    let mostWastedCategory: FoodCategory?
    let recommendations: [String]
    let projectedSavings: Double
    let environmentalImpact: EnvironmentalImpact
}

struct EnvironmentalImpact {
    let co2Saved: Double
    let waterSaved: Double
    let equivalentTrees: Double
}
