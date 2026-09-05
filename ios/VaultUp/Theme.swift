import SwiftUI
import UIKit

// MARK: - App Theme Mode
enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var id: String { rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var icon: String {
        switch self {
        case .system: return "circle.righthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.stars.fill"
        }
    }
}

// MARK: - Adaptive Color Tokens
extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
    
    // Backgrounds
    static let vuBackgroundTop = adaptive(
        light: Color(red: 0.96, green: 0.97, blue: 1.00),
        dark: Color(red: 0.05, green: 0.03, blue: 0.14)
    )
    static let vuBackgroundBottom = adaptive(
        light: Color(red: 0.91, green: 0.93, blue: 0.98),
        dark: Color(red: 0.02, green: 0.02, blue: 0.07)
    )
    
    // Cards & Surfaces
    static let vuCard = adaptive(
        light: Color.white,
        dark: Color(red: 0.10, green: 0.08, blue: 0.20)
    )
    static let vuCardElevated = adaptive(
        light: Color(red: 0.96, green: 0.97, blue: 1.00),
        dark: Color(red: 0.14, green: 0.12, blue: 0.26)
    )
    static let vuCardInset = adaptive(
        light: Color(red: 0.91, green: 0.93, blue: 0.97),
        dark: Color(red: 0.18, green: 0.15, blue: 0.30)
    )
    
    // Typography
    static let vuTextPrimary = adaptive(
        light: Color(red: 0.07, green: 0.09, blue: 0.18),
        dark: Color.white
    )
    static let vuTextSecondary = adaptive(
        light: Color(red: 0.40, green: 0.44, blue: 0.56),
        dark: Color.white.opacity(0.68)
    )
    static let vuTextMuted = adaptive(
        light: Color(red: 0.58, green: 0.62, blue: 0.72),
        dark: Color.white.opacity(0.45)
    )
    
    // Dividers & Specular Borders
    static let vuDivider = adaptive(
        light: Color.black.opacity(0.07),
        dark: Color.white.opacity(0.10)
    )
    static let vuBorder = adaptive(
        light: Color.black.opacity(0.06),
        dark: Color.white.opacity(0.09)
    )
    static let vuBorderStrong = adaptive(
        light: Color.black.opacity(0.12),
        dark: Color.white.opacity(0.16)
    )
    
    // Vibrant Brand Accents
    static let vuAccent = Color(red: 0.38, green: 0.36, blue: 0.96)       // Electric Indigo
    static let vuAccentPurple = Color(red: 0.58, green: 0.30, blue: 0.98) // Vibrant Purple
    static let vuCyan = Color(red: 0.05, green: 0.76, blue: 0.88)         // Cyan
    static let vuSuccess = Color(red: 0.10, green: 0.78, blue: 0.52)      // Mint Emerald
    static let vuDanger = Color(red: 0.95, green: 0.28, blue: 0.38)       // Coral Red
    static let vuWarning = Color(red: 1.00, green: 0.65, blue: 0.15)      // Golden Amber
    static let vuMuted = adaptive(
        light: Color.black.opacity(0.50),
        dark: Color.white.opacity(0.65)
    )
}

// MARK: - Dynamic Ambient Background
struct VUBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.vuBackgroundTop, .vuBackgroundBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Atmospheric subtle neon orbs
            GeometryReader { proxy in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [Color.vuAccent.opacity(0.22), Color.clear]
                                : [Color.vuAccent.opacity(0.08), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: proxy.size.width * 0.85)
                    .blur(radius: 65)
                    .offset(x: -proxy.size.width * 0.25, y: -proxy.size.height * 0.15)
                
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colorScheme == .dark
                                ? [Color.vuCyan.opacity(0.15), Color.clear]
                                : [Color.vuCyan.opacity(0.06), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: proxy.size.width * 0.75)
                    .blur(radius: 60)
                    .offset(x: proxy.size.width * 0.45, y: proxy.size.height * 0.40)
            }
            .allowsHitTesting(false)
        }
        .ignoresSafeArea()
    }
}

// MARK: - Card Modifiers
struct VUCard: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    var fill: Color = .vuCard
    var radius: CGFloat = 18
    var hasBorder: Bool = true
    
    func body(content: Content) -> some View {
        content
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                if hasBorder {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(Color.vuBorder, lineWidth: 1)
                }
            }
            .shadow(
                color: colorScheme == .dark ? Color.black.opacity(0.35) : Color.black.opacity(0.06),
                radius: colorScheme == .dark ? 14 : 10,
                x: 0,
                y: colorScheme == .dark ? 6 : 4
            )
    }
}

extension View {
    func vuCard(fill: Color = .vuCard, radius: CGFloat = 18, hasBorder: Bool = true) -> some View {
        modifier(VUCard(fill: fill, radius: radius, hasBorder: hasBorder))
    }
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let progress: Double
    var colors: [Color] = [.vuCyan, .vuAccent]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.vuDivider)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * min(max(CGFloat(progress / 100), 0), 1))
                    .shadow(color: colors.last?.opacity(0.4) ?? .clear, radius: 4, x: 0, y: 1)
            }
        }
        .frame(height: 8)
    }
}

// MARK: - Action Button Style
struct VUActionButtonStyle: ButtonStyle {
    var color: Color = .vuAccent
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(
                LinearGradient(
                    colors: [color, color.opacity(0.85)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .opacity(configuration.isPressed ? 0.75 : 1.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            }
            .shadow(color: color.opacity(configuration.isPressed ? 0.2 : 0.4), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
