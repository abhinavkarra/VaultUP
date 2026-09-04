import SwiftUI

extension Color {
    static let vuBackgroundTop = Color(red: 0.05, green: 0.02, blue: 0.12)
    static let vuBackgroundBottom = Color(red: 0.02, green: 0.02, blue: 0.08)
    static let vuCard = Color(red: 0.1, green: 0.08, blue: 0.18)
    static let vuCardElevated = Color(red: 0.14, green: 0.12, blue: 0.24)
    static let vuCardInset = Color(red: 0.18, green: 0.16, blue: 0.28)
    static let vuDivider = Color.white.opacity(0.12)
    static let vuSuccess = Color(red: 0.15, green: 0.85, blue: 0.60)
    static let vuDanger = Color(red: 0.95, green: 0.30, blue: 0.40)
    static let vuMuted = Color.white.opacity(0.65)
}

struct VUBackground: View {
    var body: some View {
        LinearGradient(
            colors: [.vuBackgroundTop, .vuBackgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct VUCard: ViewModifier {
    var fill: Color = .vuCard
    var radius: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .background(fill)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
            }
            .shadow(color: .black.opacity(0.24), radius: 12, y: 6)
    }
}

extension View {
    func vuCard(fill: Color = .vuCard, radius: CGFloat = 16) -> some View {
        modifier(VUCard(fill: fill, radius: radius))
    }
}

struct ProgressBar: View {
    let progress: Double
    var colors: [Color] = [.cyan, .blue]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.vuDivider)
                Capsule()
                    .fill(LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing))
                    .frame(width: geometry.size.width * min(max(progress / 100, 0), 1))
            }
        }
        .frame(height: 7)
    }
}

struct VUActionButtonStyle: ButtonStyle {
    var color: Color = .indigo

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(color.opacity(configuration.isPressed ? 0.72 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
