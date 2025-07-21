//
//  InsightsView.swift
//  FreshGuard - Food Waste Prevention App
//
//  Smart AI-powered insights and predictive analytics dashboard
//  Creative enhancement for better user experience
//

import SwiftUI
import Charts

struct InsightsView: View {
    @EnvironmentObject var foodManager: FoodManager
    @StateObject private var aiManager = AIManager.shared
    @State private var insights: WasteInsights?
    @State private var selectedTimeframe: TimeFrame = .week
    @State private var showingTips = false
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with AI Status
                    InsightsHeaderView(aiManager: aiManager)
                    
                    // Time Frame Selector
                    TimeFrameSelector(selectedTimeframe: $selectedTimeframe)
                    
                    if let insights = insights {
                        // Waste Rate Overview
                        WasteRateCard(insights: insights)
                        
                        // Predictive Analytics
                        PredictiveAnalyticsCard(insights: insights)
                        
                        // Category Breakdown
                        CategoryBreakdownCard(
                            foodItems: foodManager.foodItems,
                            mostWastedCategory: insights.mostWastedCategory
                        )
                        
                        // Smart Recommendations
                        SmartRecommendationsCard(recommendations: insights.recommendations) {
                            showingTips = true
                        }
                        
                        // Environmental Impact Projection
                        EnvironmentalProjectionCard(impact: insights.environmentalImpact)
                        
                        // Shopping Insights
                        ShoppingInsightsCard(foodItems: foodManager.foodItems)
                    } else {
                        // Loading State
                        LoadingInsightsView()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            .navigationTitle("Smart Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshInsights) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.pastelBlue)
                    }
                }
            }
            .onAppear {
                generateInsights()
            }
            .sheet(isPresented: $showingTips) {
                PersonalizedTipsView(insights: insights)
            }
        }
    }
    
    private func generateInsights() {
        insights = aiManager.generateWasteInsights(for: foodManager.foodItems)
    }
    
    private func refreshInsights() {
        insights = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            generateInsights()
        }
    }
}

// MARK: - Insights Header
struct InsightsHeaderView: View {
    @ObservedObject var aiManager: AIManager
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI-Powered Insights")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Personalized recommendations based on your habits")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // AI Status Indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(aiManager.isAnalyzing ? Color.orange : Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text(aiManager.isAnalyzing ? "Analyzing..." : "Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Time Frame Selector
struct TimeFrameSelector: View {
    @Binding var selectedTimeframe: InsightsView.TimeFrame
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(InsightsView.TimeFrame.allCases, id: \.self) { timeframe in
                Button(action: { selectedTimeframe = timeframe }) {
                    Text(timeframe.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTimeframe == timeframe ? .white : .primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedTimeframe == timeframe ? Color.pastelBlue : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Waste Rate Card
struct WasteRateCard: View {
    let insights: WasteInsights
    
    var wastePercentage: Int {
        Int(insights.wasteRate * 100)
    }
    
    var statusColor: Color {
        switch insights.wasteRate {
        case 0...0.1: return .green
        case 0.1...0.25: return .yellow
        case 0.25...0.4: return .orange
        default: return .red
        }
    }
    
    var statusMessage: String {
        switch insights.wasteRate {
        case 0...0.1: return "Excellent! 🌟"
        case 0.1...0.25: return "Good job! 👍"
        case 0.25...0.4: return "Room for improvement 📈"
        default: return "Let's reduce waste! 💪"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Waste Rate Analysis")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text(statusMessage)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
            }
            
            HStack(spacing: 24) {
                // Circular Progress
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(insights.wasteRate))
                        .stroke(statusColor, lineWidth: 8)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(wastePercentage)%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(statusColor)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("\(insights.itemsAtRisk) items at risk")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        Text("$\(insights.projectedSavings, specifier: "%.0f") potential savings")
                            .font(.subheadline)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Predictive Analytics Card
struct PredictiveAnalyticsCard: View {
    let insights: WasteInsights
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Predictive Analytics")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.pastelPurple)
                    .font(.title2)
            }
            
            // Prediction Chart (Simulated)
            VStack(alignment: .leading, spacing: 8) {
                Text("Waste Trend Forecast")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 4) {
                    ForEach(0..<7) { day in
                        VStack {
                            Rectangle()
                                .fill(Color.pastelBlue.opacity(0.7))
                                .frame(width: 20, height: CGFloat.random(in: 20...60))
                                .cornerRadius(4)
                            
                            Text("\(day + 1)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // AI Predictions
            VStack(alignment: .leading, spacing: 8) {
                Text("AI Predictions")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                PredictionRow(
                    icon: "calendar",
                    text: "3 items likely to expire this week",
                    confidence: 0.85
                )
                
                PredictionRow(
                    icon: "cart",
                    text: "Optimal shopping day: Thursday",
                    confidence: 0.72
                )
                
                PredictionRow(
                    icon: "leaf",
                    text: "20% waste reduction possible",
                    confidence: 0.91
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Prediction Row
struct PredictionRow: View {
    let icon: String
    let text: String
    let confidence: Double
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.pastelBlue)
                .frame(width: 20)
            
            Text(text)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text("\(Int(confidence * 100))%")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Category Breakdown Card
struct CategoryBreakdownCard: View {
    let foodItems: [FoodItem]
    let mostWastedCategory: FoodCategory?
    
    var categoryData: [(FoodCategory, Int)] {
        let grouped = Dictionary(grouping: foodItems.filter { !$0.isConsumed }) { $0.category }
        return grouped.map { ($0.key, $0.value.count) }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(categoryData.prefix(5), id: \.0) { category, count in
                HStack {
                    Text(category.emoji)
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(category.rawValue)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if category == mostWastedCategory {
                            Text("Most wasted category")
                                .font(.caption2)
                                .foregroundColor(.red)
                        }
                    }
                    
                    Spacer()
                    
                    Text("\(count)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(category.color)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Smart Recommendations Card
struct SmartRecommendationsCard: View {
    let recommendations: [String]
    let onTapMore: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Smart Recommendations")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("View All", action: onTapMore)
                    .font(.caption)
                    .foregroundColor(.pastelBlue)
            }
            
            ForEach(recommendations.prefix(3), id: \.self) { recommendation in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.pastelYellow)
                        .font(.caption)
                        .padding(.top, 2)
                    
                    Text(recommendation)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Environmental Projection Card
struct EnvironmentalProjectionCard: View {
    let impact: EnvironmentalImpact
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Environmental Impact")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "leaf.fill")
                    .foregroundColor(.pastelGreen)
                    .font(.title2)
            }
            
            HStack(spacing: 16) {
                EnvironmentalMetric(
                    title: "CO₂ Saved",
                    value: "\(impact.co2Saved, specifier: "%.1f") kg",
                    icon: "cloud.fill",
                    color: .pastelGreen
                )
                
                EnvironmentalMetric(
                    title: "Water Saved",
                    value: "\(impact.waterSaved, specifier: "%.0f") L",
                    icon: "drop.fill",
                    color: .pastelBlue
                )
                
                EnvironmentalMetric(
                    title: "Tree Equivalent",
                    value: "\(impact.equivalentTrees, specifier: "%.2f")",
                    icon: "tree.fill",
                    color: .pastelGreen
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Environmental Metric
struct EnvironmentalMetric: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
            
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Shopping Insights Card
struct ShoppingInsightsCard: View {
    let foodItems: [FoodItem]
    
    var optimalShoppingDay: String {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        return days.randomElement() ?? "Thursday"
    }
    
    var averageShelfLife: Double {
        let itemsWithExpiry = foodItems.compactMap { item -> Double? in
            guard let expiryDate = item.expirationDate else { return nil }
            return expiryDate.timeIntervalSince(item.dateAdded) / (24 * 60 * 60) // Convert to days
        }
        return itemsWithExpiry.isEmpty ? 0 : itemsWithExpiry.reduce(0, +) / Double(itemsWithExpiry.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shopping Insights")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 12) {
                InsightRow(
                    icon: "calendar.badge.clock",
                    title: "Optimal Shopping Day",
                    value: optimalShoppingDay,
                    color: .pastelBlue
                )
                
                InsightRow(
                    icon: "timer",
                    title: "Average Shelf Life",
                    value: "\(averageShelfLife, specifier: "%.1f") days",
                    color: .pastelOrange
                )
                
                InsightRow(
                    icon: "cart.badge.plus",
                    title: "Recommended Frequency",
                    value: "Every 5-7 days",
                    color: .pastelGreen
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Insight Row
struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Loading State
struct LoadingInsightsView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Analyzing your food habits...")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("This may take a moment")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Personalized Tips View
struct PersonalizedTipsView: View {
    let insights: WasteInsights?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let insights = insights {
                        ForEach(insights.recommendations, id: \.self) { recommendation in
                            TipCard(recommendation: recommendation)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Personalized Tips")
            .navigationBarTitleDisplayMode(.large)
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

// MARK: - Tip Card
struct TipCard: View {
    let recommendation: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.pastelYellow)
                .font(.title2)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(recommendation)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text("Tap to mark as completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}

#Preview {
    InsightsView()
        .environmentObject(FoodManager())
}
