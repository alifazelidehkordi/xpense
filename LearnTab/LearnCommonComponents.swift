import SwiftUI

private struct LessonBounceEffectModifier: ViewModifier {
    @State private var trigger = 0
    private let repetitions: Int

    init(repetitions: Int = 3) {
        self.repetitions = repetitions
    }

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.symbolEffect(.bounce, options: .repeat(.periodic(repetitions)))
        } else {
            content
                .symbolEffect(.bounce, options: .repeat(repetitions), value: trigger)
                .onAppear {
                    trigger += 1
                }
        }
    }
}

extension View {
    func lessonBounceEffect(repetitions: Int = 3) -> some View {
        modifier(LessonBounceEffectModifier(repetitions: repetitions))
    }
}

struct QuizOptionView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                Spacer()
                Circle()
                    .stroke(isSelected ? AppTheme.cardTop : AppTheme.outline, lineWidth: 2)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .fill(isSelected ? AppTheme.cardTop : Color.clear)
                            .frame(width: 14, height: 14)
                    )
            }
            .padding(20)
            .background(isSelected ? AppTheme.cardTop.opacity(0.05) : AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AppTheme.cardTop : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

struct RewardRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(title)
                .font(.system(size: 16, weight: .bold))
            Spacer()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    var color: Color = AppTheme.textPrimary
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)
            Text(value)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(AppTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct StatLabel: View {
    let title: String
    let value: String
    var color: Color = AppTheme.textPrimary
    
    var body: some View {
        HStack {
            Text(title).font(.system(size: 12)).foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(value).font(.system(size: 16, weight: .black)).foregroundStyle(color)
        }
    }
}

struct HabitFeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundStyle(AppTheme.cardTop)
                .font(.system(size: 20))
                .frame(width: 40)
            
            Text(title)
                .font(.system(size: 16, weight: .medium))
            
            Spacer()
        }
    }
}

struct RewardRowDetailed: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(color.opacity(0.1)).frame(width: 40, height: 40)
                Image(systemName: icon).foregroundStyle(color)
            }
            Text(title).font(.system(size: 16, weight: .bold))
            Spacer()
        }
    }
}
