import SwiftUI

public struct CircularProgressView: View {
    public let progress: Double
    public let timeString: String
    public let habitTitle: String?
    public let isRunning: Bool
    
    public init(
        progress: Double,
        timeString: String,
        habitTitle: String? = nil,
        isRunning: Bool = false
    ) {
        self.progress = progress
        self.timeString = timeString
        self.habitTitle = habitTitle
        self.isRunning = isRunning
    }
    
    public var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(
                    AppTheme.border,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
            
            // Progress ring
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AppTheme.textPrimary,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            // Inner Content
            VStack(spacing: 8) {
                if let habitTitle = habitTitle, !habitTitle.isEmpty {
                    Text(habitTitle)
                        .font(.system(.subheadline, design: .rounded, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineLimit(1)
                        .padding(.horizontal, 24)
                }
                
                Text(timeString)
                    .font(.system(size: 54, weight: .light, design: .monospaced))
                    .foregroundColor(AppTheme.textPrimary)
                    .monospacedDigit()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(isRunning ? Color.green : AppTheme.textTertiary)
                        .frame(width: 8, height: 8)
                    
                    Text(isRunning ? "Focusing" : "Paused")
                        .font(.system(.caption, design: .rounded, weight: .medium))
                        .foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .padding(20)
        .aspectRatio(1, contentMode: .fit)
    }
}
