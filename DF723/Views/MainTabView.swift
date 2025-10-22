//
//  MainTabView.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
                .tag(0)
            
            GoalsView()
                .tabItem {
                    Label("Goals", systemImage: "target")
                }
                .tag(1)
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.xyaxis.line")
                }
                .tag(2)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .accentColor(LavaTheme.accent)
    }
}

#Preview {
    MainTabView()
}

