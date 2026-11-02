import SwiftUI

// MARK: - Reusable Minimalist Progress Bar
public struct MinimalProgressBar: View {
    public let progress: Double
    public let height: CGFloat
    public let foregroundColor: Color
    public let backgroundColor: Color
    
    public init(
        progress: Double,
        height: CGFloat = 8,
        foregroundColor: Color = AppTheme.textPrimary,
        backgroundColor: Color = AppTheme.surface
    ) {
        self.progress = max(0.0, min(1.0, progress))
        self.height = height
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(backgroundColor)
                    .frame(height: height)
                
                Capsule()
                    .fill(foregroundColor)
                    .frame(width: max(0, geo.size.width * CGFloat(progress)), height: height)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: height)
    }
}

// MARK: - Reusable Empty State View
public struct EmptyStateView: View {
    public let iconName: String
    public let title: String
    public let message: String
    
    public init(iconName: String, title: String, message: String) {
        self.iconName = iconName
        self.title = title
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 40, weight: .light))
                .foregroundColor(AppTheme.textSecondary)
            
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundColor(AppTheme.textPrimary)
            
            Text(message)
                .font(.system(.footnote, design: .rounded))
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .bentoCard()
    }
}

// MARK: - Reusable Spaced Repetition Review Stage Badge
public struct ReviewStageBadge: View {
    public let stage: Int
    
    public init(stage: Int) {
        self.stage = stage
    }
    
    public var body: some View {
        let isMastered = stage >= 5
        let label = isMastered ? "Stage 5 (Mastered)" : "Stage \(stage)"
        
        HStack(spacing: 4) {
            Image(systemName: isMastered ? "checkmark.circle.fill" : "arrow.triangle.2.circlepath")
                .font(.system(size: 9))
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(AppTheme.surface)
        .foregroundColor(isMastered ? Color.green : AppTheme.textPrimary)
        .clipShape(Capsule())
        .overlay(
            Capsule().stroke(AppTheme.border, lineWidth: 1)
        )
    }
}

// MARK: - Thread-Safe Cached Date Formatting Utilities
public enum AppFormatters {
    private static let dayAndMonthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d"
        return f
    }()
    
    private static let mediumDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()
    
    private static let longDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM d, yyyy"
        return f
    }()
    
    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f
    }()
    
    private static let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM yyyy"
        return f
    }()
    
    private static let dayAbbreviationFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "E"
        return f
    }()
    
    public static func dayAndMonth(_ date: Date = Date()) -> String {
        dayAndMonthFormatter.string(from: date)
    }
    
    public static func mediumDate(_ date: Date) -> String {
        mediumDateFormatter.string(from: date)
    }
    
    public static func longDate(_ date: Date) -> String {
        longDateFormatter.string(from: date)
    }
    
    public static func time(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }
    
    public static func monthYear(_ date: Date) -> String {
        monthYearFormatter.string(from: date)
    }
    
    public static func dayAbbreviation(_ date: Date) -> String {
        dayAbbreviationFormatter.string(from: date)
    }
    
    public static func groupHeaderDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today • \(mediumDate(date))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday • \(mediumDate(date))"
        } else {
            let year = calendar.component(.year, from: date)
            return "\(dayAndMonth(date)), \(year)"
        }
    }
}
