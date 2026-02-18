//
//  ThemeManager.swift
//  JARVIS
//
//  JARVIS design system: colors, fonts, animations, and glassmorphism styles.
//  Dark mode base with neon accents — "JARVIS hologram" aesthetic.
//

import SwiftUI

// MARK: - JARVIS Colors

/// Core color palette for the JARVIS interface.
enum JARVISColors {
    static let background = Color.black
    static let cardBackground = Color(white: 0.1)
    static let cardBackgroundLight = Color(white: 0.15)
    static let primaryAccent = Color.cyan
    static let secondaryAccent = Color.purple
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.7)
    static let textTertiary = Color(white: 0.5)
    static let divider = Color(white: 0.2)
    static let inputBackground = Color(white: 0.08)
    
    /// Parse a hex color string (e.g., "#00FFFF") into a SwiftUI Color.
    static func fromHex(_ hex: String?) -> Color? {
        guard let hex = hex?.trimmingCharacters(in: CharacterSet(charactersIn: "#")) else {
            return nil
        }
        
        guard hex.count == 6, let hexNumber = UInt64(hex, radix: 16) else {
            return nil
        }
        
        let r = Double((hexNumber & 0xFF0000) >> 16) / 255.0
        let g = Double((hexNumber & 0x00FF00) >> 8) / 255.0
        let b = Double(hexNumber & 0x0000FF) / 255.0
        
        return Color(red: r, green: g, blue: b)
    }
}

// MARK: - JARVIS Fonts

/// Typography system for the JARVIS interface.
enum JARVISFonts {
    static func headline(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .default)
    }
    
    static func title(_ size: CGFloat = 22) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    static func body(_ size: CGFloat = 16) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func caption(_ size: CGFloat = 13) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    static func mono(_ size: CGFloat = 14) -> Font {
        .system(size: size, weight: .medium, design: .monospaced)
    }
    
    static func stat(_ size: CGFloat = 32) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
}

// MARK: - Glassmorphism Modifier

/// Applies a glassmorphism effect — translucent background with blur.
struct GlassMorphism: ViewModifier {
    var cornerRadius: CGFloat = 16
    var opacity: Double = 0.15
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .opacity(opacity)
            )
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(JARVISColors.cardBackground.opacity(0.8))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

extension View {
    /// Applies glassmorphism effect to any view.
    func glassMorphism(cornerRadius: CGFloat = 16, opacity: Double = 0.15) -> some View {
        modifier(GlassMorphism(cornerRadius: cornerRadius, opacity: opacity))
    }
}

// MARK: - Glow Effect

/// Adds a neon glow shadow effect.
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.3), radius: radius * 2, x: 0, y: 0)
    }
}

extension View {
    /// Adds a glowing neon shadow effect.
    func glowEffect(color: Color = JARVISColors.primaryAccent, radius: CGFloat = 8) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Blueprint Animation Support

extension View {
    /// Applies the appropriate transition based on a BlueprintAnimation.
    @ViewBuilder
    func blueprintTransition(_ animation: BlueprintAnimation) -> some View {
        switch animation {
        case .fade:
            self.transition(.opacity)
        case .slideUp:
            self.transition(.move(edge: .bottom).combined(with: .opacity))
        case .scale:
            self.transition(.scale.combined(with: .opacity))
        case .fadeSlideUp:
            self.transition(.opacity.combined(with: .move(edge: .bottom)))
        case .none:
            self
        }
    }
}

// MARK: - Floating Card Effect

/// Subtle floating card animation.
struct FloatingEffect: ViewModifier {
    @State private var isFloating = false
    let amplitude: CGFloat
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .offset(y: isFloating ? -amplitude : amplitude)
            .animation(
                .easeInOut(duration: duration).repeatForever(autoreverses: true),
                value: isFloating
            )
            .onAppear { isFloating = true }
    }
}

extension View {
    /// Adds a subtle floating animation.
    func floating(amplitude: CGFloat = 3, duration: Double = 2.5) -> some View {
        modifier(FloatingEffect(amplitude: amplitude, duration: duration))
    }
}

// MARK: - Animated Appearance

/// Animates a view's appearance with scale + opacity.
struct AnimatedAppearance: ViewModifier {
    @State private var isVisible = false
    let delay: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.9)
            .offset(y: isVisible ? 0 : 20)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8).delay(delay),
                value: isVisible
            )
            .onAppear {
                isVisible = true
            }
    }
}

extension View {
    /// Animates a view's entrance with a spring effect.
    func animatedAppearance(delay: Double = 0) -> some View {
        modifier(AnimatedAppearance(delay: delay))
    }
}

// MARK: - Pulse Animation

/// Subtle pulse animation for active/online indicators.
struct PulseAnimation: ViewModifier {
    @State private var isPulsing = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.1 : 1.0)
            .opacity(isPulsing ? 0.8 : 1.0)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

extension View {
    /// Adds a pulse animation (useful for status indicators).
    func pulse() -> some View {
        modifier(PulseAnimation())
    }
}

