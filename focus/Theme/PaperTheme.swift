//
//  PaperTheme.swift
//  focus
//
//  Created on 2025-12-29.
//

import SwiftUI

/// Paper theme colors that adapt to light/dark mode
struct PaperTheme {
    
    // MARK: - Backgrounds
    
    /// Main background color - cream in light, dark charcoal in dark
    static var background: Color {
        Color(light: Color(red: 0.99, green: 0.98, blue: 0.95),
              dark: Color(red: 0.12, green: 0.11, blue: 0.10))
    }
    
    /// Texture overlay - subtle paper texture
    static var textureOverlay: Color {
        Color(light: Color(red: 0.96, green: 0.95, blue: 0.92),
              dark: Color(red: 0.15, green: 0.14, blue: 0.13))
    }
    
    /// Card background - slightly darker/lighter than main
    static var cardBackground: Color {
        Color(light: Color(red: 0.97, green: 0.96, blue: 0.93),
              dark: Color(red: 0.18, green: 0.17, blue: 0.16))
    }
    
    // MARK: - Text Colors
    
    /// Primary text - dark brown in light, cream in dark
    static var textPrimary: Color {
        Color(light: Color(red: 0.2, green: 0.15, blue: 0.1),
              dark: Color(red: 0.95, green: 0.94, blue: 0.91))
    }
    
    /// Secondary text - medium brown
    static var textSecondary: Color {
        Color(light: Color(red: 0.4, green: 0.35, blue: 0.3),
              dark: Color(red: 0.7, green: 0.68, blue: 0.65))
    }
    
    /// Tertiary text - lighter brown
    static var textTertiary: Color {
        Color(light: Color(red: 0.5, green: 0.45, blue: 0.4),
              dark: Color(red: 0.55, green: 0.53, blue: 0.50))
    }
    
    // MARK: - Accent Colors (Muted Earthy Tones)
    
    /// Blue accent - dusty blue
    static var accentBlue: Color {
        Color(light: Color(red: 0.4, green: 0.5, blue: 0.6),
              dark: Color(red: 0.5, green: 0.6, blue: 0.7))
    }
    
    /// Green accent - sage green
    static var accentGreen: Color {
        Color(light: Color(red: 0.5, green: 0.6, blue: 0.45),
              dark: Color(red: 0.6, green: 0.7, blue: 0.55))
    }
    
    /// Orange accent - terracotta
    static var accentOrange: Color {
        Color(light: Color(red: 0.7, green: 0.5, blue: 0.3),
              dark: Color(red: 0.8, green: 0.6, blue: 0.4))
    }
    
    /// Purple accent - dusty purple
    static var accentPurple: Color {
        Color(light: Color(red: 0.6, green: 0.45, blue: 0.6),
              dark: Color(red: 0.7, green: 0.55, blue: 0.7))
    }
    
    /// Red accent - warm reddish-brown
    static var accentRed: Color {
        Color(light: Color(red: 0.6, green: 0.3, blue: 0.25),
              dark: Color(red: 0.7, green: 0.4, blue: 0.35))
    }
    
    // MARK: - Borders & Shadows
    
    /// Border color for cards
    static var border: Color {
        Color(light: Color(red: 0.85, green: 0.83, blue: 0.78),
              dark: Color(red: 0.25, green: 0.24, blue: 0.23))
    }
    
    /// Shadow color
    static var shadow: Color {
        Color.black.opacity(0.15)
    }
    
    // MARK: - Buttons
    
    /// Primary button background
    static var buttonPrimary: Color {
        Color(light: Color(red: 0.3, green: 0.25, blue: 0.2),
              dark: Color(red: 0.4, green: 0.35, blue: 0.3))
    }
    
    /// Primary button text
    static var buttonPrimaryText: Color {
        Color(light: Color(red: 0.95, green: 0.94, blue: 0.91),
              dark: Color(red: 0.95, green: 0.94, blue: 0.91))
    }
    
    /// Secondary button background
    static var buttonSecondary: Color {
        cardBackground
    }
    
    /// Secondary button text
    static var buttonSecondaryText: Color {
        textPrimary
    }
}

// MARK: - Color Extension for Dynamic Colors

extension Color {
    /// Creates a color that adapts to light/dark mode
    init(light: Color, dark: Color) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(dark)
            default:
                return UIColor(light)
            }
        })
    }
}

