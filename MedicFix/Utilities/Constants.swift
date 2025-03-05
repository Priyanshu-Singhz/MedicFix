//
//  Constants.swift
//  MedicFix
//
//  Created by Priyanshu Singh on 19/02/25.
//

import Foundation
import SwiftUI

struct AppTheme {
    // MARK: - Color Palette
    struct Colors {
        // Primary brand colors
        static let primary = Color(hex: "4361EE")
        static let primaryDark = Color(hex: "3A56D4")
        static let primaryLight = Color(hex: "7B92FF")
        
        // Secondary colors
        static let accent = Color(hex: "F72585")
        static let accentLight = Color(hex: "FF619A")
        
        // Background colors
        static let background = Color(hex: "F9FAFC")
        static let cardBackground = Color.white
        static let secondaryBackground = Color(hex: "EEF2FF")
        
        // Status colors
        static let success = Color(hex: "4CC9B0")
        static let warning = Color(hex: "FFB347")
        static let error = Color(hex: "FF6B6B")
        
        // Text colors
        static let textPrimary = Color(hex: "2B2D42")
        static let textSecondary = Color(hex: "6C757D")
        static let textTertiary = Color(hex: "ADB5BD")
    }
    
    // MARK: - Typography
    struct Typography {
        // Standard fonts
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let subtitle = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .medium, design: .rounded)
        static let callout = Font.system(size: 14, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
        static let captionLight = Font.system(size: 12, weight: .regular, design: .rounded)
    }
    
    // MARK: - Shadows
    struct Shadows {
        static let small = Shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        static let medium = Shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        static let large = Shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 8)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Radius
    struct Radius {
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let circular: CGFloat = 999
    }
}

// MARK: - Custom Color Extension
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
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Custom Shadow Struct
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Reusable ViewModifiers
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(AppTheme.Spacing.md)
            .background(AppTheme.Colors.cardBackground)
            .cornerRadius(AppTheme.Radius.md)
            .shadow(
                color: AppTheme.Shadows.small.color,
                radius: AppTheme.Shadows.small.radius,
                x: AppTheme.Shadows.small.x,
                y: AppTheme.Shadows.small.y
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.subheadline)
            .padding(.vertical, AppTheme.Spacing.sm)
            .padding(.horizontal, AppTheme.Spacing.md)
            .foregroundColor(.white)
            .background(
                isEnabled
                ? configuration.isPressed
                    ? AppTheme.Colors.primaryDark
                    : AppTheme.Colors.primary
                : AppTheme.Colors.textTertiary
            )
            .cornerRadius(AppTheme.Radius.md)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppTheme.Typography.subheadline)
            .padding(.vertical, AppTheme.Spacing.sm)
            .padding(.horizontal, AppTheme.Spacing.md)
            .foregroundColor(AppTheme.Colors.primary)
            .background(
                configuration.isPressed
                ? AppTheme.Colors.secondaryBackground
                : Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md)
                    .stroke(AppTheme.Colors.primary, lineWidth: 1.5)
            )
            .cornerRadius(AppTheme.Radius.md)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self.modifier(CardStyle())
    }
}
