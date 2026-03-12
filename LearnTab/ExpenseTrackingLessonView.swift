import SwiftUI

struct ExpenseTrackingLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore
    
    @State private var currentScreen = 1
    @State private var selectedQuizOption: Int? = nil
    @State private var showQuizFeedback = false
    
    // Practice Screen State
    @State private var practiceStep = 0
    @State private var practiceTransactions: [PracticeTransaction] = [
        PracticeTransaction(name: "Coffee", amount: 4.50, category: nil, isNeed: nil, isFixed: nil),
        PracticeTransaction(name: "Netflix", amount: 12.00, category: nil, isNeed: nil, isFixed: nil),
        PracticeTransaction(name: "Uber", amount: 18.50, category: nil, isNeed: nil, isFixed: nil)
    ]
    
    private let totalScreens = 9
    
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
                    case 3: screen3ThreeSystems
                    case 4: screen4MiniExample
                    case 5: screen5Practice
                    case 6: screen6Insight
                    case 7: screen7Quiz
                    case 8: screen8Habit
                    case 9: screen9Reward
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
                // Bottom Navigation
                if currentScreen < 9 && currentScreen != 5 {
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
                    if selectedQuizOption == 1 {
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
                Text("Level 2")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                Text("Expense Tracking")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 15) {
                    Image(systemName: "scope")
                        .font(.system(size: 80))
                        .foregroundStyle(AppTheme.cardTop)
                    
                    Text("🔍")
                        .font(.system(size: 40))
                        .offset(x: 40, y: -40)
                }
            }
            
            VStack(spacing: 12) {
                Text("Where does your money really go?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Most people guess wrong. Tracking your spending shows the truth.")
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
            Text("Give your spending names")
                .font(.system(size: 28, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("When every purchase is just “money gone,” it’s hard to improve.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                
                Text("Categories help you see patterns in your spending.")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    CategoryPill(icon: "fork.knife", title: "Food")
                    CategoryPill(icon: "bus", title: "Transport")
                    CategoryPill(icon: "house.fill", title: "Rent")
                    CategoryPill(icon: "play.circle.fill", title: "Fun")
                }
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 10)
            
            Spacer()
        }
        .padding(24)
        .padding(.top, 30)
    }
    
    private var screen3ThreeSystems: some View {
        VStack(spacing: 30) {
            Text("Three ways to understand spending")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 16) {
                InfoSystemCard(title: "Categorization", sub: "Food, Rent, Fun...", icon: "tag.fill", color: .blue)
                InfoSystemCard(title: "Need vs Want", sub: "Survival vs Joy", icon: "arrow.left.arrow.right", color: .purple)
                InfoSystemCard(title: "Fixed vs Variable", sub: "Stable vs Flexible", icon: "chart.bar.fill", color: .orange)
            }
            
            Spacer()
        }
        .padding(24)
        .padding(.top, 30)
    }
    
    private var screen4MiniExample: some View {
        VStack(spacing: 24) {
            Text("Example tagging")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            ScrollView {
                VStack(spacing: 16) {
                    ExampleTagRow(name: "Supermarket", amount: "€24", tags: ["Food", "Need", "Variable"])
                    ExampleTagRow(name: "Netflix", amount: "€12", tags: ["Entertain.", "Want", "Fixed"])
                    ExampleTagRow(name: "Taxi ride", amount: "€18", tags: ["Transport", "Want", "Variable"])
                }
            }
            
            Spacer()
        }
        .padding(24)
        .padding(.top, 30)
    }
    
    private var screen5Practice: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text("Tag your recent spending")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text("\(practiceStep + 1) / 3 completed")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            if practiceStep < practiceTransactions.count {
                let transaction = practiceTransactions[practiceStep]
                
                VStack(spacing: 30) {
                    // Transaction Card
                    VStack(spacing: 12) {
                        Text(transaction.name)
                            .font(.system(size: 24, weight: .bold))
                        Text(String(format: "€%.2f", transaction.amount))
                            .font(.system(size: 36, weight: .heavy, design: .rounded))
                            .foregroundStyle(AppTheme.cardTop)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(AppTheme.white)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    
                    // Interaction
                    VStack(spacing: 20) {
                        Text("Is this a Need or a Want?")
                            .font(.system(size: 18, weight: .bold))
                        
                        HStack(spacing: 20) {
                            Button {
                                nextPracticeStep(isNeed: false)
                            } label: {
                                VStack {
                                    Text("🎁")
                                        .font(.system(size: 40))
                                    Text("Want")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            
                            Button {
                                nextPracticeStep(isNeed: true)
                            } label: {
                                VStack {
                                    Text("🏠")
                                        .font(.system(size: 40))
                                    Text("Need")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.cardTop.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppTheme.cardTop, lineWidth: 2))
                            }
                        }
                    }
                }
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
            
            Spacer()
        }
        .padding(24)
        .padding(.top, 30)
    }
    
    private func nextPracticeStep(isNeed: Bool) {
        withAnimation {
            practiceTransactions[practiceStep].isNeed = isNeed
            if practiceStep < 2 {
                practiceStep += 1
            } else {
                currentScreen += 1
            }
        }
    }
    
    private var screen6Insight: some View {
        VStack(spacing: 30) {
            Text("Your first spending insight")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                HStack(spacing: 20) {
                    InsightStatCircle(value: "60%", label: "Needs", color: AppTheme.cardTop)
                    InsightStatCircle(value: "40%", label: "Wants", color: .purple.opacity(0.5))
                }
                
                VStack(spacing: 12) {
                    InsightBarRow(label: "Food", progress: 0.7, color: .orange)
                    InsightBarRow(label: "Entertainment", progress: 0.3, color: .purple)
                    InsightBarRow(label: "Transport", progress: 0.5, color: .blue)
                }
                .padding(24)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            
            Text("Now your money has a map.")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.cardTop)
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen7Quiz: some View {
        VStack(spacing: 30) {
            Text("Quick check.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Which type of spending is usually easier to reduce?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                VStack(spacing: 12) {
                    QuizOptionView(title: "A. Fixed expenses", isSelected: selectedQuizOption == 0) {
                        selectedQuizOption = 0
                    }
                    QuizOptionView(title: "B. Variable expenses", isSelected: selectedQuizOption == 1) {
                        selectedQuizOption = 1
                    }
                }
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            if showQuizFeedback {
                VStack(spacing: 12) {
                    Text(selectedQuizOption == 1 ? "✅ Correct!" : "❌ Try again")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(selectedQuizOption == 1 ? AppTheme.positive : AppTheme.negative)
                    Text("Variable spending can usually be adjusted more easily than fixed costs.")
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
        VStack(spacing: 40) {
            Text("Start your tracking habit")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
            
            VStack(spacing: 20) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.orange)
                
                Text("Day 1")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                
                Text("For the next 24 hours, log or confirm your spending to build awareness.")
                    .font(.system(size: 18, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 36))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen9Reward: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                Text("🎉")
                    .font(.system(size: 80))
            }
            
            VStack(spacing: 16) {
                Text("Level Complete!")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                Text("You gave your money a map.")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                RewardRow(icon: "star.fill", title: "+60 XP", color: .orange)
                RewardRow(icon: "scope", title: "Badge: Clarity Tracker", color: AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            Button {
                store.completeLesson("expense-tracking", earnedXP: 60)
                dismiss()
            } label: {
                Text("Finish Level 2")
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

struct CategoryPill: View {
    let icon: String
    let title: String
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 14, weight: .bold))
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppTheme.background)
        .clipShape(Capsule())
    }
}

struct InfoSystemCard: View {
    let title: String
    let sub: String
    let icon: String
    let color: Color
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 18, weight: .bold))
                Text(sub)
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            Spacer()
        }
        .padding()
        .background(AppTheme.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct ExampleTagRow: View {
    let name: String
    let amount: String
    let tags: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(name)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Text(amount)
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(AppTheme.cardTop)
            }
            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.cardTop.opacity(0.1))
                        .foregroundStyle(AppTheme.cardTop)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(AppTheme.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct InsightStatCircle: View {
    let value: String
    let label: String
    let color: Color
    var body: some View {
        VStack {
            ZStack {
                Circle().stroke(color.opacity(0.2), lineWidth: 8)
                Circle().trim(from: 0, to: 0.6).stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                Text(value).font(.system(size: 20, weight: .bold))
            }
            .frame(width: 100, height: 100)
            Text(label).font(.system(size: 14, weight: .bold))
        }
    }
}

struct InsightBarRow: View {
    let label: String
    let progress: Double
    let color: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label).font(.system(size: 14, weight: .bold))
                Spacer()
                Text("\(Int(progress * 100))%").font(.system(size: 12))
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.1)).frame(height: 8)
                    Capsule().fill(color).frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct PracticeTransaction {
    let name: String
    let amount: Double
    var category: String?
    var isNeed: Bool?
    var isFixed: Bool?
}

#Preview {
    ExpenseTrackingLessonView()
        .environmentObject(BudgetPlannerStore.preview)
}
