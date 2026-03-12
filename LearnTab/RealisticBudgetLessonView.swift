import SwiftUI

struct RealisticBudgetLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore
    
    @State private var currentScreen = 1
    @State private var selectedQuizOption: Int? = nil
    @State private var showQuizFeedback = false
    
    // Budget Sliders State
    @State private var foodBudget: Double = 220
    @State private var eatingOutBudget: Double = 100
    @State private var transportBudget: Double = 80
    
    private let pastFoodSpending: Double = 240
    private let pastEatingOutSpending: Double = 120
    private let pastTransportSpending: Double = 80
    
    private let totalScreens = 10
    
    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress Bar
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                
                // Screen Content
                ZStack {
                    switch currentScreen {
                    case 1: screen1Hook
                    case 2: screen2Concept
                    case 3: screen3Visual
                    case 4: screen4Story
                    case 5: screen5Practice
                    case 6: screen6Summary
                    case 7: screen7Quiz
                    case 8: screen8Habit
                    case 9: screen9DailyProgress
                    case 10: screen10Reward
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
                // Bottom Navigation
                if currentScreen < 10 {
                    bottomNavigation
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(8)
                        .background(AppTheme.white.opacity(0.8))
                        .clipShape(Circle())
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(1...totalScreens, id: \.self) { index in
                Capsule()
                    .fill(index <= currentScreen ? AppTheme.cardTop : AppTheme.outline)
                    .frame(height: 6)
                    .animation(.spring(), value: currentScreen)
            }
        }
    }
    
    private var bottomNavigation: some View {
        VStack {
            Button {
                if currentScreen == 7 {
                    if selectedQuizOption == 0 {
                        withAnimation { currentScreen += 1 }
                    } else {
                        withAnimation { showQuizFeedback = true }
                    }
                } else {
                    withAnimation { currentScreen += 1 }
                }
            } label: {
                Text(currentScreen == 7 ? "Check Answer" : "Continue")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.cardTop)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: AppTheme.cardTop.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .disabled(currentScreen == 7 && selectedQuizOption == nil)
            .opacity(currentScreen == 7 && selectedQuizOption == nil ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Screens
    
    private var screen1Hook: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Level 3")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                Text("Realistic Budget")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        BlockItem(title: "Food", color: .orange)
                        BlockItem(title: "Bills", color: .blue)
                    }
                    HStack(spacing: 12) {
                        BlockItem(title: "Fun", color: .purple)
                        BlockItem(title: "Transport", color: .green)
                    }
                }
            }
            
            VStack(spacing: 12) {
                Text("Most budgets fail.")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Not because you're bad with money — because they start with unrealistic numbers.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 20)
            }
            
            Spacer()
        }
        .padding(.top, 40)
    }
    
    private var screen2Concept: some View {
        VStack(spacing: 30) {
            Text("Start from real life")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("A realistic budget starts with what you **already spend**.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                
                Text("Then you make **small changes** you can actually keep.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                
                VStack(spacing: 16) {
                    BudgetComparisonRow(title: "Fantasy Budget", from: 60, to: 20, isSuccess: false)
                    BudgetComparisonRow(title: "Real Budget", from: 60, to: 55, isSuccess: true)
                }
                .padding(20)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.positive)
                    Text("Small changes stick.")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
        .padding(.top, 30)
    }
    
    private var screen3Visual: some View {
        VStack(spacing: 30) {
            Text("Improve, don't punish")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Weekly food spending")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                    HStack {
                        Text("€60 average")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Image(systemName: "arrow.right")
                        Text("€55 suggested")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppTheme.cardTop)
                    }
                }
                .padding(20)
                .background(AppTheme.cardTop.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text("Reducing spending **10–20%** is much more sustainable than huge cuts.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textSecondary)
                
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 60))
                    .foregroundStyle(AppTheme.cardTop)
                    .lessonBounceEffect()
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
        .padding(.top, 30)
    }
    
    private var screen4Story: some View {
        VStack(spacing: 30) {
            Text("Daniel's mistake")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Daniel tried to fix his spending by making a strict budget.")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(alignment: .center, spacing: 10) {
                    Text("Food budget:")
                        .font(.system(size: 16, weight: .bold))
                    Text("€60 → €25")
                        .font(.system(size: 30, weight: .heavy))
                        .foregroundStyle(AppTheme.negative)
                    Text("❌ Too far from reality")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.negative)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.negative.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Text("After one week he gave up. A better version would be **€60 → €55**.")
                    .font(.system(size: 18, weight: .medium))
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
        .padding(.top, 30)
    }
    
    private var screen5Practice: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Build your first realistic budget")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("We used your past spending to suggest caps.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    BudgetEditCard(title: "Food", average: 240, budget: $foodBudget)
                    BudgetEditCard(title: "Eating Out", average: 120, budget: $eatingOutBudget)
                    BudgetEditCard(title: "Transport", average: 80, budget: $transportBudget)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
    
    private var screen6Summary: some View {
        VStack(spacing: 30) {
            Text("Your first realistic budget")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    SummaryRow(title: "Food", amount: foodBudget)
                    SummaryRow(title: "Eating Out", amount: eatingOutBudget)
                    SummaryRow(title: "Transport", amount: transportBudget)
                }
                .padding(20)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Divider()
                
                VStack(spacing: 8) {
                    HStack {
                        Text("Total Budget")
                        Spacer()
                        Text(String(format: "€%.0f", foodBudget + eatingOutBudget + transportBudget))
                            .font(.system(size: 20, weight: .heavy))
                    }
                    HStack {
                        Text("Previous Spending")
                            .foregroundStyle(AppTheme.textSecondary)
                        Spacer()
                        Text("€440")
                            .strikethrough()
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Potential monthly saving")
                            .font(.system(size: 14))
                        Text(String(format: "€%.0f", 440 - (foodBudget + eatingOutBudget + transportBudget)))
                            .font(.system(size: 24, weight: .heavy))
                            .foregroundStyle(AppTheme.positive)
                    }
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 30))
                        .foregroundStyle(AppTheme.positive)
                }
                .padding(20)
                .background(AppTheme.positive.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen7Quiz: some View {
        VStack(spacing: 30) {
            Text("Quick check.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 24) {
                Text("What is a safer first budget reduction?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                VStack(spacing: 12) {
                    QuizOptionView(title: "A. 10%", isSelected: selectedQuizOption == 0) {
                        selectedQuizOption = 0
                    }
                    QuizOptionView(title: "B. 60%", isSelected: selectedQuizOption == 1) {
                        selectedQuizOption = 1
                    }
                }
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            if showQuizFeedback {
                VStack(spacing: 12) {
                    Text(selectedQuizOption == 0 ? "✅ Correct!" : "❌ Try again")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(selectedQuizOption == 0 ? AppTheme.positive : AppTheme.negative)
                    Text("Small reductions are easier to maintain and more realistic.")
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen8Habit: some View {
        VStack(spacing: 30) {
            Text("Start your 7-Day Budget Test")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading, spacing: 20) {
                Text("This week is not about perfection. It's about testing your budget and learning what works.")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                
                VStack(spacing: 16) {
                    HabitFeatureRow(icon: "list.bullet.clipboard.fill", title: "Daily spending check")
                    HabitFeatureRow(icon: "chart.bar.fill", title: "Budget progress tracker")
                    HabitFeatureRow(icon: "calendar.badge.checkmark", title: "Weekly review")
                }
                
                HStack {
                    Text("Day 1 / 7")
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                    Spacer()
                    Image(systemName: "flame.fill")
                        .foregroundStyle(.orange)
                }
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 36))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen9DailyProgress: some View {
        VStack(spacing: 30) {
            Text("Today's budget progress")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Food budget")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text("€220 monthly")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    ProgressView(value: 7, total: 220)
                        .tint(AppTheme.cardTop)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Spent today").font(.system(size: 12))
                            Text("€7").font(.system(size: 18, weight: .bold))
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Remaining").font(.system(size: 12))
                            Text("€213").font(.system(size: 18, weight: .bold)).foregroundStyle(AppTheme.positive)
                        }
                    }
                }
                .padding(24)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                
                HStack(spacing: 15) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 30))
                        .foregroundStyle(AppTheme.cardTop.opacity(0.3))
                    Text("You're doing great — progress matters more than perfection.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .italic()
                }
                .padding(20)
                .background(AppTheme.cardTop.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen10Reward: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 250, height: 250)
                
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(AppTheme.cardTop)
                    .lessonBounceEffect()
            }
            
            VStack(spacing: 16) {
                Text("Level Complete!")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                Text("You created your first realistic budget.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                RewardRow(icon: "star.fill", title: "+70 XP", color: .orange)
                RewardRow(icon: "medal.fill", title: "Badge: Reality Builder", color: AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            Button {
                store.completeLesson("realistic-budget", earnedXP: 70)
                dismiss()
            } label: {
                Text("Finish Level 3")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.cardTop)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
    }
}

// MARK: - Subviews

struct BlockItem: View {
    let title: String
    let color: Color
    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BudgetComparisonRow: View {
    let title: String
    let from: Double
    let to: Double
    let isSuccess: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)
            HStack {
                Text(String(format: "€%.0f", from))
                Image(systemName: "arrow.right")
                Text(String(format: "€%.0f", to))
                    .foregroundStyle(isSuccess ? AppTheme.positive : AppTheme.negative)
                Spacer()
                Text(isSuccess ? "✅" : "❌")
            }
            .font(.system(size: 18, weight: .bold))
        }
    }
}

struct BudgetEditCard: View {
    let title: String
    let average: Double
    @Binding var budget: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Average").font(.system(size: 12))
                    Text(String(format: "€%.0f", average))
                        .font(.system(size: 20, weight: .bold))
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(AppTheme.outline)
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Budget").font(.system(size: 12))
                    Text(String(format: "€%.0f", budget))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppTheme.cardTop)
                }
            }
            
            Slider(value: $budget, in: (average * 0.5)...average, step: 5)
                .tint(AppTheme.cardTop)
        }
        .padding(20)
        .background(AppTheme.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct SummaryRow: View {
    let title: String
    let amount: Double
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(String(format: "€%.0f", amount))
                .font(.system(size: 16, weight: .bold))
        }
    }
}


#Preview {
    RealisticBudgetLessonView()
        .environmentObject(BudgetPlannerStore.preview)
}
