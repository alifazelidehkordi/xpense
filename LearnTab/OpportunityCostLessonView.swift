import SwiftUI

struct OpportunityCostLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore
    
    @State private var currentScreen = 1
    @State private var selectedQuizOption: Int? = nil
    @State private var showQuizFeedback = false
    
    // Priorities State
    @State private var selectedPriorities: Set<String> = []
    
    // Pause Rule State
    @State private var pauseThreshold: String = "20"
    @State private var isPauseRuleEnabled = false
    
    // Reflection State
    @State private var selectedReflection: String? = nil
    
    private let totalScreens = 12
    
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
                    case 3: screen3Example
                    case 4: screen4Story
                    case 5: screen5ChoosePriorities
                    case 6: screen6ComparePurchases
                    case 7: screen7Quiz
                    case 8: screen8ActionPrompt
                    case 9: screen9PauseTimer
                    case 10: screen10MatchScore
                    case 11: screen11Reflection
                    case 12: screen12Reward
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
                // Bottom Navigation
                if currentScreen < 12 {
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
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .disabled(isNextDisabled)
            .opacity(isNextDisabled ? 0.6 : 1.0)
        }
    }
    
    private var isNextDisabled: Bool {
        if currentScreen == 5 && selectedPriorities.count < 2 { return true }
        if currentScreen == 7 && selectedQuizOption == nil { return true }
        return false
    }
    
    // MARK: - Screens
    
    private var screen1Hook: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Level 7")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                Text("Smart Spending Decisions")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "box.truck.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("Delivery")
                            .font(.system(size: 10, weight: .bold))
                    }
                    
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppTheme.cardTop)
                    
                    VStack(spacing: 8) {
                        Image(systemName: "airplane")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.positive)
                        Text("Travel")
                            .font(.system(size: 10, weight: .bold))
                    }
                }
            }
            
            VStack(spacing: 12) {
                Text("Every yes is a no to something else.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Every purchase has a hidden trade-off.")
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
            Text("Hidden trade-offs")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("When you spend money on one thing, you give up the chance to use it somewhere else. That hidden alternative is called **opportunity cost**.")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Spend €")
                            .font(.system(size: 24, weight: .black))
                        Image(systemName: "arrow.right")
                        Text("Something else disappears")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(AppTheme.cardTop.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen3Example: some View {
        VStack(spacing: 30) {
            Text("A simple trade-off")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    VStack(spacing: 15) {
                        Text("🍔")
                            .font(.system(size: 40))
                        Text("Food delivery")
                            .font(.system(size: 14, weight: .bold))
                        Text("€15")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Text("VS")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(AppTheme.cardTop)
                    
                    VStack(spacing: 15) {
                        Text("🥦")
                            .font(.system(size: 40))
                        Text("2 days of groceries")
                            .font(.system(size: 12, weight: .bold))
                            .multilineTextAlignment(.center)
                        Text("€15")
                            .font(.system(size: 20, weight: .black))
                            .foregroundStyle(AppTheme.positive)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.positive.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                
                Text("Opportunity cost helps you see the real trade-off.")
                    .font(.system(size: 16, weight: .medium))
                    .multilineTextAlignment(.center)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen4Story: some View {
        VStack(spacing: 30) {
            Text("Sara's weekend choice")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Sara ordered food delivery three times last week. Each order cost €18.")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(spacing: 8) {
                    Text("€54 total")
                        .font(.system(size: 24, weight: .black))
                        .foregroundStyle(AppTheme.negative)
                    Text("= half of her travel savings goal")
                        .font(.system(size: 14, weight: .bold))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.negative.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Text("Once she started thinking about trade-offs, she made better choices.")
                    .font(.system(size: 18, weight: .medium))
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen5ChoosePriorities: some View {
        VStack(spacing: 24) {
            Text("Choose your top priorities")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text("Pick 2 things that matter most right now.")
                .font(.system(size: 16))
                .foregroundStyle(AppTheme.textSecondary)
            
            let priorities = ["Peace of mind", "Paying bills on time", "Travel", "Reducing debt", "Social life", "Health", "Convenience"]
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(priorities, id: \.self) { priority in
                        PriorityCard(title: priority, isSelected: selectedPriorities.contains(priority)) {
                            if selectedPriorities.contains(priority) {
                                selectedPriorities.remove(priority)
                            } else if selectedPriorities.count < 2 {
                                selectedPriorities.insert(priority)
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen6ComparePurchases: some View {
        VStack(spacing: 30) {
            Text("Does this match your priorities?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("Online shopping")
                        .font(.system(size: 18, weight: .bold))
                    Text("€25")
                        .font(.system(size: 32, weight: .black))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Priorities:").font(.system(size: 14, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                    ForEach(Array(selectedPriorities), id: \.self) { priority in
                        HStack {
                            Image(systemName: "star.fill").foregroundStyle(.orange)
                            Text(priority).font(.system(size: 16, weight: .bold))
                        }
                    }
                }
                
                Text("This purchase may delay your \(selectedPriorities.contains("Travel") ? "Travel" : "savings") goal.")
                    .font(.system(size: 14, weight: .medium))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.negative)
                    .padding()
                    .background(AppTheme.negative.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
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
                Text("Opportunity cost means:")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                VStack(spacing: 12) {
                    QuizOptionView(title: "A. A hidden fee", isSelected: selectedQuizOption == 0) {
                        selectedQuizOption = 0
                    }
                    QuizOptionView(title: "B. What you give up when you choose something", isSelected: selectedQuizOption == 1) {
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
                    Text("When you choose one purchase, you give up the chance to spend that money elsewhere.")
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
    
    private var screen8ActionPrompt: some View {
        VStack(spacing: 30) {
            Text("Create your pause rule")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                Text("Pause before purchases above a certain amount. Waiting even a few minutes helps prevent impulse decisions.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                
                HStack(spacing: 15) {
                    Text("Pause over")
                    TextField("€ 20", text: $pauseThreshold)
                        .keyboardType(.numberPad)
                        .font(.system(size: 24, weight: .black))
                        .multilineTextAlignment(.center)
                        .frame(width: 80)
                        .padding(8)
                        .background(AppTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Toggle("Enable pause rule", isOn: $isPauseRuleEnabled)
                    .padding()
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .tint(AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen9PauseTimer: some View {
        VStack(spacing: 30) {
            Text("Pause before purchase")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Purchase detected")
                    Text("€28").font(.system(size: 32, weight: .black))
                }
                
                ZStack {
                    Circle()
                        .stroke(AppTheme.outline, lineWidth: 10)
                        .frame(width: 150, height: 150)
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(AppTheme.cardTop, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("10:00")
                            .font(.system(size: 32, weight: .black, design: .monospaced))
                        Text("minutes")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Button("Wait") {}.frame(maxWidth: .infinity).padding().background(AppTheme.background).clipShape(Capsule())
                    Button("Skip purchase") {}.frame(maxWidth: .infinity).padding().background(AppTheme.negative.opacity(0.1)).foregroundStyle(AppTheme.negative).clipShape(Capsule())
                }
                .font(.system(size: 14, weight: .bold))
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Text("+5 XP for mindful decisions")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppTheme.cardTop)
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen10MatchScore: some View {
        VStack(spacing: 30) {
            Text("Priority Match Score")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                HStack(spacing: 30) {
                    ZStack {
                        Circle()
                            .stroke(AppTheme.outline, lineWidth: 8)
                        Circle()
                            .trim(from: 0, to: 0.67)
                            .stroke(AppTheme.positive, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        Text("67%")
                            .font(.system(size: 24, weight: .black))
                    }
                    .frame(width: 100, height: 100)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        StatLabel(title: "Reviewed", value: "12")
                        StatLabel(title: "Matches", value: "8", color: AppTheme.positive)
                        StatLabel(title: "Regrets", value: "2", color: AppTheme.negative)
                    }
                }
                
                Text("Your spending is becoming more intentional.")
                    .font(.system(size: 16, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            .padding(32)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen11Reflection: some View {
        VStack(spacing: 30) {
            Text("Quick reflection")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                Text("Which spending gave value, and which gave regret this week?")
                    .font(.system(size: 18, weight: .bold))
                
                VStack(spacing: 12) {
                    ForEach(["Great value purchases", "Some regrets", "Mostly aligned", "Still learning"], id: \.self) { choice in
                        Button {
                            selectedReflection = choice
                        } label: {
                            Text(choice)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(selectedReflection == choice ? .white : AppTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedReflection == choice ? AppTheme.cardTop : AppTheme.white)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(AppTheme.outline, lineWidth: 1))
                        }
                    }
                }
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen12Reward: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle().fill(AppTheme.cardTop.opacity(0.1)).frame(width: 250, height: 250)
                Image(systemName: "arrow.left.and.right").font(.system(size: 100)).foregroundStyle(AppTheme.cardTop)
            }
            
            VStack(spacing: 16) {
                Text("Level Complete!")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                Text("You learned to design smarter choices.")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                RewardRow(icon: "star.fill", title: "+90 XP", color: .orange)
                RewardRow(icon: "medal.fill", title: "Badge: Choice Architect", color: AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            Button {
                store.completeLesson("trade-offs", earnedXP: 90)
                dismiss()
            } label: {
                Text("Finish Level 7")
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

struct PriorityCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? AppTheme.cardTop : AppTheme.outline)
            }
            .padding()
            .background(isSelected ? AppTheme.cardTop.opacity(0.05) : AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(isSelected ? AppTheme.cardTop : AppTheme.outline, lineWidth: 1))
        }
        .foregroundStyle(AppTheme.textPrimary)
    }
}


#Preview {
    OpportunityCostLessonView()
        .environmentObject(BudgetPlannerStore.preview)
}
