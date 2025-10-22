//
//  SettingsView.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showResetConfirmation = false
    @State private var showGame = false
    @State private var animate = false
    
    var body: some View {
        ZStack {
            LavaTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LavaTheme.paddingLarge) {
                    // Header
                    Text("Settings")
                        .font(LavaTheme.titleFont)
                        .foregroundColor(LavaTheme.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, LavaTheme.paddingLarge)
                        .padding(.top, LavaTheme.paddingLarge)
                        .opacity(animate ? 1 : 0)
                        .offset(y: animate ? 0 : -20)
                    
                    // Statistics Card
                    VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(LavaTheme.accent)
                            Text("Your Statistics")
                                .font(LavaTheme.headlineFont)
                                .foregroundColor(LavaTheme.text)
                        }
                        
                        Divider()
                            .background(LavaTheme.highlight.opacity(0.3))
                        
                        VStack(spacing: LavaTheme.paddingMedium) {
                            StatRow(
                                icon: "dollarsign.circle.fill",
                                title: "Total Saved",
                                value: formatCurrency(dataManager.statistics.totalSaved),
                                color: LavaTheme.accent
                            )
                            
                            StatRow(
                                icon: "flag.checkered.circle.fill",
                                title: "Goals Achieved",
                                value: "\(dataManager.statistics.goalsAchieved)",
                                color: LavaTheme.highlight
                            )
                            
                            StatRow(
                                icon: "flame.fill",
                                title: "Current Streak",
                                value: "\(dataManager.statistics.currentStreak) days",
                                color: LavaTheme.primaryButton
                            )
                            
                            StatRow(
                                icon: "target",
                                title: "Active Goals",
                                value: "\(dataManager.goals.count)",
                                color: LavaTheme.accent
                            )
                        }
                    }
                    .padding(LavaTheme.paddingLarge)
                    .lavaCard()
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    
                    // Data Management Card
                    VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                        HStack {
                            Image(systemName: "externaldrive.fill")
                                .foregroundColor(LavaTheme.primaryButton)
                            Text("Data Management")
                                .font(LavaTheme.headlineFont)
                                .foregroundColor(LavaTheme.text)
                        }
                        
                        Divider()
                            .background(LavaTheme.highlight.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: LavaTheme.paddingSmall) {
                            Text("All your data is stored locally on your device. You can reset all data at any time.")
                                .font(LavaTheme.bodyFont)
                                .foregroundColor(LavaTheme.text.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Button(action: { showResetConfirmation = true }) {
                            HStack {
                                Image(systemName: "trash.circle.fill")
                                Text("Reset All Data")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(LavaButtonStyle(isSecondary: true))
                    }
                    .padding(LavaTheme.paddingLarge)
                    .lavaCard()
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    
                    // App Info Card
                    VStack(alignment: .leading, spacing: LavaTheme.paddingMedium) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(LavaTheme.accent)
                            Text("About")
                                .font(LavaTheme.headlineFont)
                                .foregroundColor(LavaTheme.text)
                        }
                        
                        Divider()
                            .background(LavaTheme.highlight.opacity(0.3))
                        
                        VStack(alignment: .leading, spacing: LavaTheme.paddingSmall) {
                            Text("A powerful personal finance tool focused on savings tracking and smart accumulation planning.")
                                .font(LavaTheme.bodyFont)
                                .foregroundColor(LavaTheme.text.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Secret game button
                        Button(action: { showGame = true }) {
                            HStack {
                                Image(systemName: "gamecontroller.fill")
                                Text("Lava Shooter Game")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(LavaButtonStyle(isSecondary: true))
                    }
                    .padding(LavaTheme.paddingLarge)
                    .lavaCard()
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    
                    Spacer(minLength: 20)
                }
                .padding(.bottom, LavaTheme.paddingLarge)
            }
        }
        .alert("Reset All Data", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                withAnimation {
                    dataManager.resetAllData()
                }
            }
        } message: {
            Text("Are you sure you want to reset all data? This will delete all goals, transactions, and statistics. This action cannot be undone.")
        }
        .fullScreenCover(isPresented: $showGame) {
            LavaShooterGameView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animate = true
            }
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: LavaTheme.paddingMedium) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(LavaTheme.bodyFont)
                    .foregroundColor(LavaTheme.text.opacity(0.7))
                
                Text(value)
                    .font(LavaTheme.bodyFont.weight(.semibold))
                    .foregroundColor(LavaTheme.text)
            }
            
            Spacer()
        }
        .padding(.vertical, LavaTheme.paddingSmall)
    }
}

#Preview {
    SettingsView()
}

