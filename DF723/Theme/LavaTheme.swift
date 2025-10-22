//
//  LavaTheme.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import SwiftUI

struct LavaTheme {
    // MARK: - Colors
    static let background = Color(hex: "#0B0C10")
    static let backgroundGradientStart = Color(hex: "#0B0C10")
    static let backgroundGradientEnd = Color(hex: "#430000")
    
    static let primaryButton = Color(hex: "#FF3B30")
    static let accent = Color(hex: "#FFA500")
    static let text = Color(hex: "#F5F5F5")
    static let cardBackground = Color(hex: "#1C1C1E").opacity(0.8)
    static let highlight = Color(hex: "#FF6F00")
    
    // MARK: - Gradients
    static let backgroundGradient = LinearGradient(
        colors: [backgroundGradientStart, backgroundGradientEnd],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let lavaGlow = LinearGradient(
        colors: [primaryButton, accent],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [cardBackground, cardBackground.opacity(0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Typography
    static let titleFont = Font.system(size: 28, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let bodyFont = Font.system(size: 16, weight: .regular, design: .rounded)
    static let captionFont = Font.system(size: 14, weight: .medium, design: .rounded)
    static let smallFont = Font.system(size: 12, weight: .regular, design: .rounded)
    
    // MARK: - Spacing
    static let paddingSmall: CGFloat = 12
    static let paddingMedium: CGFloat = 16
    static let paddingLarge: CGFloat = 20
    static let paddingXLarge: CGFloat = 24
    
    // MARK: - Corner Radius
    static let cornerRadiusSmall: CGFloat = 12
    static let cornerRadiusMedium: CGFloat = 16
    static let cornerRadiusLarge: CGFloat = 20
    
    // MARK: - Shadow
    static let cardShadow = Color.black.opacity(0.3)
    static let glowShadow = primaryButton.opacity(0.4)
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - View Modifiers
struct LavaCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusMedium)
                    .fill(LavaTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusMedium)
                            .stroke(LavaTheme.highlight.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: LavaTheme.cardShadow, radius: 10, x: 0, y: 5)
    }
}

struct LavaButtonStyle: ButtonStyle {
    var isSecondary: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(LavaTheme.bodyFont)
            .foregroundColor(LavaTheme.text)
            .padding(.horizontal, LavaTheme.paddingLarge)
            .padding(.vertical, LavaTheme.paddingMedium)
            .background(
                Group {
                    if isSecondary {
                        RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusMedium)
                            .fill(LavaTheme.cardBackground)
                    } else {
                        RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusMedium)
                            .fill(LavaTheme.lavaGlow)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: LavaTheme.cornerRadiusMedium)
                    .stroke(isSecondary ? LavaTheme.highlight.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .shadow(color: isSecondary ? Color.clear : LavaTheme.glowShadow, radius: 15, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct GlowingProgressBar: View {
    var progress: Double
    var height: CGFloat = 8
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(LavaTheme.cardBackground)
                    .frame(height: height)
                
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(LavaTheme.lavaGlow)
                    .frame(width: geometry.size.width * CGFloat(progress), height: height)
                    .shadow(color: LavaTheme.primaryButton.opacity(0.6), radius: 8, x: 0, y: 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: height)
    }
}

extension View {
    func lavaCard() -> some View {
        self.modifier(LavaCardModifier())
    }
}

