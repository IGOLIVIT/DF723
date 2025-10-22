//
//  OnboardingView.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var currentPage = 0
    @State private var showDashboard = false
    
    let pages = [
        OnboardingPage(
            icon: "flame.fill",
            title: "Track your savings with clarity.",
            description: "Visualize your financial journey with beautiful insights and powerful tracking."
        ),
        OnboardingPage(
            icon: "target",
            title: "Set goals and watch them grow.",
            description: "Create savings goals and track your progress with motivating visual indicators."
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Achieve financial balance with focus.",
            description: "Stay on track with detailed analytics and smart accumulation planning."
        )
    ]
    
    var body: some View {
        if showDashboard {
            MainTabView()
                .transition(.opacity.combined(with: .scale))
        } else {
            ZStack {
                LavaTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            OnboardingPageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    .animation(.easeInOut, value: currentPage)
                    
                    VStack(spacing: LavaTheme.paddingMedium) {
                        if currentPage == pages.count - 1 {
                            Button(action: {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    dataManager.completeOnboarding()
                                    showDashboard = true
                                }
                            }) {
                                HStack {
                                    Text("Start My Journey")
                                        .font(LavaTheme.headlineFont)
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .buttonStyle(LavaButtonStyle())
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(height: 100)
                    .padding(.bottom, LavaTheme.paddingLarge)
                }
            }
        }
    }
}

struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: LavaTheme.paddingXLarge) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LavaTheme.lavaGlow)
                    .frame(width: 120, height: 120)
                    .blur(radius: 30)
                    .opacity(animate ? 0.6 : 0.3)
                
                Image(systemName: page.icon)
                    .font(.system(size: 60, weight: .medium))
                    .foregroundColor(LavaTheme.text)
                    .scaleEffect(animate ? 1.0 : 0.8)
            }
            .padding(.bottom, LavaTheme.paddingLarge)
            
            VStack(spacing: LavaTheme.paddingMedium) {
                Text(page.title)
                    .font(LavaTheme.titleFont)
                    .foregroundColor(LavaTheme.text)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LavaTheme.paddingLarge)
                    .opacity(animate ? 1.0 : 0)
                
                Text(page.description)
                    .font(LavaTheme.bodyFont)
                    .foregroundColor(LavaTheme.text.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, LavaTheme.paddingXLarge)
                    .opacity(animate ? 1.0 : 0)
            }
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animate = true
            }
        }
    }
}

#Preview {
    OnboardingView()
}

