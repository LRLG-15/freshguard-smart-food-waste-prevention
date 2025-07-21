//
//  FreshGuardApp.swift
//  FreshGuard - Food Waste Prevention App
//
//  Main app entry point and configuration
//

import SwiftUI

@main
struct FreshGuardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Request notification permissions on app launch
        NotificationManager.shared.requestPermission()
        
        // Configure app appearance
        configureAppearance()
        
        // Initialize game manager
        _ = GameManager.shared
        
        print("🍎 FreshGuard App Launched Successfully!")
    }
    
    private func configureAppearance() {
        // Define custom pastel colors
        let pastelBlue = UIColor(red: 0.7, green: 0.85, blue: 1.0, alpha: 1.0)
        let pastelBackground = UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0)
        
        // Customize navigation bar appearance with pastel theme
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = pastelBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.shadowColor = UIColor.clear
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Customize tab bar appearance with pastel theme
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = pastelBackground
        tabBarAppearance.shadowColor = UIColor.clear
        
        // Customize tab bar item colors
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = pastelBlue
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: pastelBlue]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.systemGray
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        
        // Set accent color to pastel blue
        UIView.appearance().tintColor = pastelBlue
        
        // Customize other UI elements
        UITableView.appearance().backgroundColor = UIColor.systemGroupedBackground
        UICollectionView.appearance().backgroundColor = UIColor.systemGroupedBackground
    }
}
