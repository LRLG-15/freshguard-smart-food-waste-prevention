//
//  Views.swift
//  FreshGuard - Food Waste Prevention App
//
//  Additional views for the core functionality
//

import SwiftUI

// MARK: - Login View
struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Welcome to FreshGuard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 40)
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                if showError {
                    Text("Invalid username or password")
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: login) {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.pastelBlue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(username.isEmpty || password.isEmpty)
                
                Spacer()
            }
            .navigationTitle("Login")
        }
    }
    
    private func login() {
        // Simple mock login validation
        if username.lowercased() == "user" && password == "password" {
            isLoggedIn = true
        } else {
            showError = true
        }
    }
}

// MARK: - Main App Entry Point with Login Flow
struct MainAppView: View {
    @State private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                PlaygroundDemoView()
                    .transition(.opacity)
            } else {
                LoginView(isLoggedIn: $isLoggedIn)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isLoggedIn)
    }
}

// MARK: - Preview
#Preview {
    MainAppView()
}

// MARK: - Fridge View
struct FridgeView: View {
    @EnvironmentObject var foodManager: FoodManager
    @State private var searchText = ""
    @State private var selectedCategory: FoodCategory? = nil
    @State private var showingExpiredOnly = false
    
    var filteredItems: [FoodItem] {
        var items = foodManager.foodItems.filter { !$0.isConsumed }
        
        if !searchText.isEmpty {
            items = items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if showingExpiredOnly {
            items = items.filter { $0.daysUntilExpiration < 0 }
        }
        
        return items.sorted { $0.daysUntilExpiration < $1.daysUntilExpiration }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Filter Controls
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        
                        ForEach(FoodCategory.allCases, id: \.self) { category in
                            FilterChip(
                                title: "\(category.emoji) \(category.rawValue)",
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                        
                        FilterChip(title: "⚠️ Expired", isSelected: showingExpiredOnly) {
                            showingExpiredOnly.toggle()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                
                // Food Items List
                if filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "refrigerator")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No items found")
                            .font(.title2)
                            .fontWeight(.medium)
                        
                        Text("Add some food to your fridge!")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            FoodItemRow(item: item)
                                .environmentObject(foodManager)
                        }
                        .onDelete(perform: deleteItems)
                    }
                }
            }
            .navigationTitle("My Fridge")
            .searchable(text: $searchText, prompt: "Search food items...")
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            let item = filteredItems[index]
            foodManager.deleteFoodItem(item)
        }
    }
}

// MARK: - Food Item Row
struct FoodItemRow: View {
    let item: FoodItem
    @EnvironmentObject var foodManager: FoodManager
    @State private var showingDetails = false
    
    var body: some View {
        HStack {
            Text(item.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                
                HStack {
                    Text(item.category.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(item.category.color.opacity(0.2))
                        .cornerRadius(8)
                    
                    Spacer()
                    
                    if let expirationDate = item.expirationDate {
                        VStack(alignment: .trailing) {
                            Text(expirationDate, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(expirationStatusText(for: item))
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(item.statusColor)
                        }
                    } else {
                        Text("No expiry")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: { foodManager.markAsConsumed(item) }) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetails = true
        }
        .sheet(isPresented: $showingDetails) {
            FoodItemDetailView(item: item)
                .environmentObject(foodManager)
        }
    }
    
    private func expirationStatusText(for item: FoodItem) -> String {
        let days = item.daysUntilExpiration
        if days < 0 {
            return "Expired \(abs(days)) day\(abs(days) == 1 ? "" : "s") ago"
        } else if days == 0 {
            return "Expires today"
        } else if days == 1 {
            return "Expires tomorrow"
        } else {
            return "Expires in \(days) days"
        }
    }
}

// MARK: - Food Item Detail View
struct FoodItemDetailView: View {
    let item: FoodItem
    @EnvironmentObject var foodManager: FoodManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Item Header
                VStack(spacing: 16) {
                    Text(item.emoji)
                        .font(.system(size: 80))
                    
                    Text(item.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(item.category.rawValue)
                        .font(.subheadline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(item.category.color.opacity(0.2))
                        .cornerRadius(12)
                }
                
                // Expiration Info
                if let expirationDate = item.expirationDate {
                    VStack(spacing: 8) {
                        Text("Expiration")
                            .font(.headline)
                        
                        Text(expirationDate, style: .date)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(expirationStatusText(for: item))
                            .font(.subheadline)
                            .foregroundColor(item.statusColor)
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Notes
                if !item.notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(item.notes)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        foodManager.markAsConsumed(item)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Mark as Used")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .fontWeight(.semibold)
                    }
                    
                    Button(action: {
                        foodManager.deleteFoodItem(item)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash.fill")
                            Text("Remove from Fridge")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .fontWeight(.semibold)
                    }
                }
            }
            .padding()
            .navigationTitle("Food Details")
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
    
    private func expirationStatusText(for item: FoodItem) -> String {
        let days = item.daysUntilExpiration
        if days < 0 {
            return "Expired \(abs(days)) day\(abs(days) == 1 ? "" : "s") ago"
        } else if days == 0 {
            return "Expires today!"
        } else if days == 1 {
            return "Expires tomorrow"
        } else {
            return "Expires in \(days) days"
        }
    }
}

// MARK: - Recipes View
struct RecipesView: View {
    @EnvironmentObject var foodManager: FoodManager
    @StateObject private var recipeManager = RecipeManager()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Recipe Type", selection: $selectedTab) {
                    Text("Suggested").tag(0)
                    Text("All Recipes").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                if selectedTab == 0 {
                    SuggestedRecipesView()
                        .environmentObject(recipeManager)
                        .environmentObject(foodManager)
                } else {
                    AllRecipesView()
                        .environmentObject(recipeManager)
                }
            }
            .navigationTitle("Recipes")
            .onAppear {
                recipeManager.getSuggestedRecipes(for: foodManager.foodItems)
            }
        }
    }
}

// MARK: - Suggested Recipes View
struct SuggestedRecipesView: View {
    @EnvironmentObject var recipeManager: RecipeManager
    @EnvironmentObject var foodManager: FoodManager
    
    var body: some View {
        if recipeManager.isLoading {
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                Text("Finding recipes for you...")
                    .padding(.top)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if recipeManager.suggestedRecipes.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "book.closed")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("No recipes found")
                    .font(.title2)
                    .fontWeight(.medium)
                
                Text("Add more ingredients to get recipe suggestions!")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button("Refresh Suggestions") {
                    recipeManager.getSuggestedRecipes(for: foodManager.foodItems)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List(recipeManager.suggestedRecipes) { recipe in
                RecipeRow(recipe: recipe, isHighlighted: true)
            }
        }
    }
}

// MARK: - All Recipes View
struct AllRecipesView: View {
    @EnvironmentObject var recipeManager: RecipeManager
    
    var body: some View {
        List(recipeManager.recipes) { recipe in
            RecipeRow(recipe: recipe, isHighlighted: false)
        }
    }
}

// MARK: - Recipe Row
struct RecipeRow: View {
    let recipe: Recipe
    let isHighlighted: Bool
    @State private var showingDetail = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.headline)
                    .foregroundColor(isHighlighted ? .blue : .primary)
                
                Text(recipe.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Label("\(recipe.prepTime) min", systemImage: "clock")
                    Label(recipe.difficulty.rawValue, systemImage: "star.fill")
                    Label(recipe.category.rawValue, systemImage: "tag")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isHighlighted {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            RecipeDetailView(recipe: recipe)
        }
    }
}

// MARK: - Recipe Detail View
struct RecipeDetailView: View {
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text(recipe.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Label("\(recipe.prepTime) min", systemImage: "clock")
                            Label(recipe.difficulty.rawValue, systemImage: "star.fill")
                            Label(recipe.category.rawValue, systemImage: "tag")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack {
                                Image(systemName: "circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.blue)
                                Text(ingredient)
                            }
                        }
                    }
                    
                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, instruction in
                            HStack(alignment: .top) {
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 20, height: 20)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                
                                Text(instruction)
                                    .font(.body)
                            }
                        }
                    }
                    
                    // Try Recipe Button
                    Button(action: {
                        GameManager.shared.incrementRecipesTried()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("I Made This Recipe!")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .fontWeight(.semibold)
                    }
                }
                .padding()
            }
            .navigationTitle("Recipe")
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

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        Text("Food Waste Warrior")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Level \(gameManager.totalPoints / 100 + 1)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Stats Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        StatCard(title: "Total Points", value: "\(gameManager.totalPoints)", icon: "star.fill", color: .yellow)
                        StatCard(title: "Current Streak", value: "\(gameManager.currentStreak) days", icon: "flame.fill", color: .orange)
                        StatCard(title: "Items Saved", value: "\(gameManager.itemsSaved)", icon: "leaf.fill", color: .green)
                        StatCard(title: "Money Saved", value: "$\(gameManager.moneySaved, specifier: "%.0f")", icon: "dollarsign.circle.fill", color: .blue)
                    }
                    
                    // Environmental Impact
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Environmental Impact")
                            .font(.headline)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .foregroundColor(.green)
                                Text("CO₂ Saved: \(gameManager.userStats.co2Saved, specifier: "%.1f") kg")
                                Spacer()
                            }
                            
                            HStack {
                                Image(systemName: "drop.fill")
                                    .foregroundColor(.blue)
                                Text("Water Saved: \(gameManager.userStats.waterSaved, specifier: "%.0f") L")
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Achievements
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Achievements")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(gameManager.achievements.prefix(6)) { achievement in
                                VStack {
                                    Text(achievement.emoji)
                                        .font(.title)
                                        .opacity(achievement.isUnlocked ? 1.0 : 0.3)
                                    
                                    Text(achievement.title)
                                        .font(.caption2)
                                        .multilineTextAlignment(.center)
                                        .opacity(achievement.isUnlocked ? 1.0 : 0.5)
                                }
                                .padding(8)
                                .background(achievement.isUnlocked ? Color.yellow.opacity(0.2) : Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Helper Views
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImageSelected: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImageSelected(image)
            }
            picker.dismiss(animated: true)
        }
    }
}

// MARK: - Image Analysis View
struct ImageAnalysisView: View {
    let analysis: FoodImageAnalysis
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: analysis.isFresh ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(analysis.isFresh ? .green : .orange)
                
                Text(analysis.analysisMessage)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                
                if !analysis.detectedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Detected Items:")
                            .font(.headline)
                        
                        ForEach(analysis.detectedItems, id: \.self) { item in
                            Text("• \(item)")
                                .font(.body)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recommendations:")
                        .font(.headline)
                    
                    ForEach(analysis.recommendations, id: \.self) { recommendation in
                        Text("• \(recommendation)")
                            .font(.body)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("AI Analysis")
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

#Preview {
    ContentView()
}
