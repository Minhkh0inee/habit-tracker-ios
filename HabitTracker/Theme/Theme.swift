import SwiftUI

/// Minimalist Black & White Design System
public enum AppTheme {
    // MARK: - Colors
    public static var background: Color {
        Color(uiColor: .systemBackground)
    }
    
    public static var secondaryBackground: Color {
        Color(uiColor: .secondarySystemBackground)
    }
    
    public static var cardBackground: Color {
        Color(uiColor: .tertiarySystemBackground)
    }
    
    public static var surface: Color {
        Color(uiColor: .systemGray6)
    }
    
    public static var border: Color {
        Color.primary.opacity(0.12)
    }
    
    public static var textPrimary: Color {
        Color.primary
    }
    
    public static var textSecondary: Color {
        Color.secondary
    }
    
    public static var textTertiary: Color {
        Color(uiColor: .tertiaryLabel)
    }
    
    // Solid high-contrast colors
    public static var buttonForeground: Color {
        Color(uiColor: .systemBackground)
    }
    
    public static var buttonBackground: Color {
        Color.primary
    }
}

// MARK: - View Modifiers
public struct CardModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var bordered: Bool = true
    
    public func body(content: Content) -> some View {
        content
            .background(AppTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: bordered ? 1 : 0)
            )
    }
}

public struct PrimaryButtonModifier: ViewModifier {
    var fullWidth: Bool = true
    
    public func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded, weight: .semibold))
            .foregroundColor(AppTheme.buttonForeground)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(AppTheme.buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

public struct SecondaryButtonModifier: ViewModifier {
    var fullWidth: Bool = true
    
    public func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .rounded, weight: .medium))
            .foregroundColor(AppTheme.textPrimary)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
    }
}

public extension View {
    func bentoCard(cornerRadius: CGFloat = 16, bordered: Bool = true) -> some View {
        modifier(CardModifier(cornerRadius: cornerRadius, bordered: bordered))
    }
    
    func primaryButton(fullWidth: Bool = true) -> some View {
        modifier(PrimaryButtonModifier(fullWidth: fullWidth))
    }
    
    func secondaryButton(fullWidth: Bool = true) -> some View {
        modifier(SecondaryButtonModifier(fullWidth: fullWidth))
    }
}
