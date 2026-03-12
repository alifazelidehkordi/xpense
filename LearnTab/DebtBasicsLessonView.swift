import SwiftUI

struct DebtBasicsLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore
    
    @State private var currentScreen = 1
    @State private var selectedQuizOption: Int? = nil
    @State private var showQuizFeedback = false
    
    // Debt Entry State
    @State private var debtName: String = ""
    @State private var minPayment: String = ""
    @State private var dueDate: String = ""
    @State private var totalBalance: String = ""
    
    // Reminders State
    @State private var reminder3Days = true
    @State private var reminder1Day = true
    @State private var reminderOnDay = true
    
    // Strategy State
    @State private var selectedStrategy: String? = nil
    
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
                    case 5: screen5AddDebt
                    case 6: screen6DebtOverview
                    case 7: screen7Reminders
                    case 8: screen8Quiz
                    case 9: screen9Strategy
                    case 10: screen10Progress
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
                if currentScreen == 8 {
                    if selectedQuizOption == 1 {
                        withAnimation { currentScreen += 1 }
                    } else {
                        withAnimation { showQuizFeedback = true }
                    }
                } else {
                    withAnimation { currentScreen += 1 }
                }
            } label: {
                Text(currentScreen == 8 ? "Check Answer" : "Continue")
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
        if currentScreen == 5 && (debtName.isEmpty || minPayment.isEmpty || dueDate.isEmpty) { return true }
        if currentScreen == 8 && selectedQuizOption == nil { return true }
        if currentScreen == 9 && selectedStrategy == nil { return true }
        return false
    }
    
    // MARK: - Screens
    
    private var screen1Hook: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Level 9")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                Text("Credit & Debt")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 15) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(AppTheme.cardTop)
                    
                    Text("€ Debt")
                        .font(.system(size: 14, weight: .black))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(AppTheme.white)
                        .clipShape(Capsule())
                        .shadow(radius: 2)
                }
            }
            
            VStack(spacing: 12) {
                Text("Debt payments are part of your budget.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Even if you didn't choose them today, they affect your future spending.")
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
            Text("Debt squeezes future choices")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("When debt has due dates, minimum payments, and interest, it reduces how much freedom your next paycheck gives you.")
                    .font(.system(size: 18, weight: .medium))
                
                HStack {
                    Spacer()
                    VStack(spacing: 15) {
                        Text("Debt today")
                            .font(.system(size: 14, weight: .bold))
                        Image(systemName: "arrow.right")
                        Text("Less flexibility tomorrow")
                            .font(.system(size: 14, weight: .black))
                            .foregroundStyle(AppTheme.negative)
                    }
                    .padding()
                    .background(AppTheme.negative.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    Spacer()
                }
                
                HStack(spacing: 20) {
                    ZStack {
                        Circle().fill(AppTheme.outline).frame(width: 100, height: 100)
                        Circle().trim(from: 0, to: 0.25).stroke(AppTheme.cardTop, lineWidth: 20).frame(width: 80, height: 80).rotationEffect(.degrees(-90))
                    }
                    Text("Debt Payment Slice")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.cardTop)
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
            Text("Understanding a simple debt")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    HStack {
                        Text("Total balance:")
                        Spacer()
                        Text("€500").bold()
                    }
                    HStack {
                        Text("Minimum payment:")
                        Spacer()
                        Text("€25").bold()
                    }
                    Text("Interest applies each month").font(.system(size: 12)).foregroundStyle(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                HStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Min Payments").font(.system(size: 12, weight: .bold))
                        Text("• Longer time\n• Higher cost").font(.system(size: 10))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.negative.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Extra Payments").font(.system(size: 12, weight: .bold))
                        Text("• Faster payoff\n• Lower cost").font(.system(size: 10))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(AppTheme.positive.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                Text("Paying only the minimum often means paying longer and paying more.")
                    .font(.system(size: 14, weight: .medium))
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
            Text("David felt overwhelmed")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("David had a €500 credit balance. He ignored it because it felt stressful.")
                    .font(.system(size: 18, weight: .medium))
                
                Text("Once he added it to a simple repayment plan, the situation became clearer.")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(spacing: 12) {
                    Text("Debt feels scary when it’s unclear.")
                    Text("Plans reduce stress.").bold().foregroundStyle(AppTheme.positive)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppTheme.positive.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen5AddDebt: some View {
        VStack(spacing: 24) {
            Text("Add one debt item")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text("You only need to add one item to start.")
                .font(.system(size: 14))
                .foregroundStyle(AppTheme.textSecondary)
            
            VStack(spacing: 16) {
                DebtInputField(label: "Debt name", placeholder: "e.g. Credit card", text: $debtName)
                DebtInputField(label: "Minimum payment", placeholder: "€ 0", text: $minPayment).keyboardType(.numberPad)
                DebtInputField(label: "Due date", placeholder: "e.g. 18th", text: $dueDate)
                DebtInputField(label: "Total balance (optional)", placeholder: "€ 0", text: $totalBalance).keyboardType(.numberPad)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen6DebtOverview: some View {
        VStack(spacing: 30) {
            Text("Your debt overview")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Image(systemName: "creditcard.fill").foregroundStyle(AppTheme.cardTop)
                        Text(debtName.isEmpty ? "Credit card" : debtName).bold()
                    }
                    Divider()
                    HStack {
                        Text("Balance")
                        Spacer()
                        Text("€\(totalBalance.isEmpty ? "500" : totalBalance)").bold()
                    }
                    HStack {
                        Text("Minimum")
                        Spacer()
                        Text("€\(minPayment.isEmpty ? "25" : minPayment)").bold()
                    }
                    HStack {
                        Text("Due Date")
                        Spacer()
                        Text(dueDate.isEmpty ? "18th" : dueDate).bold()
                    }
                }
                .padding(24)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(AppTheme.positive)
                    Text("Monthly obligation added to budget")
                        .font(.system(size: 14, weight: .bold))
                }
                
                Text("Understanding your debt reduces uncertainty.")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen7Reminders: some View {
        VStack(spacing: 30) {
            Text("Enable payment reminders")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 16) {
                Toggle("3 days before due date", isOn: $reminder3Days)
                Toggle("1 day before due date", isOn: $reminder1Day)
                Toggle("On due date", isOn: $reminderOnDay)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .tint(AppTheme.cardTop)
            
            VStack(spacing: 12) {
                Text("+5 XP for enabling reminders")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                Image(systemName: "bell.badge.fill").foregroundStyle(.orange)
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen8Quiz: some View {
        VStack(spacing: 30) {
            Text("Quick check.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 24) {
                Text("What usually happens if you only pay the minimum?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                VStack(spacing: 12) {
                    QuizOptionView(title: "A. Debt ends quickly", isSelected: selectedQuizOption == 0) {
                        selectedQuizOption = 0
                    }
                    QuizOptionView(title: "B. You often pay longer and more in total", isSelected: selectedQuizOption == 1) {
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
                    Text("Minimum payments reduce the balance slowly, allowing interest to accumulate.")
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
    
    private var screen9Strategy: some View {
        VStack(spacing: 30) {
            Text("Choose your payoff style")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 16) {
                StrategyCard(title: "Snowball Method", subtitle: "Pay smallest balances first\nBuild motivation quickly", isSelected: selectedStrategy == "Snowball") {
                    selectedStrategy = "Snowball"
                }
                StrategyCard(title: "Avalanche Method", subtitle: "Pay highest interest first\nReduce total cost faster", isSelected: selectedStrategy == "Avalanche") {
                    selectedStrategy = "Avalanche"
                }
                
                HStack(spacing: 40) {
                    VStack {
                        Text("Snowball").font(.system(size: 10, weight: .bold))
                        Text("Motivation").font(.system(size: 12)).foregroundStyle(AppTheme.textSecondary)
                    }
                    VStack {
                        Text("Avalanche").font(.system(size: 10, weight: .bold))
                        Text("Efficiency").font(.system(size: 12)).foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen10Progress: some View {
        VStack(spacing: 30) {
            Text("Debt payoff progress")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    HStack {
                        Text("Balance €500")
                        Spacer()
                        Text("Paid €50").foregroundStyle(AppTheme.positive)
                    }
                    .font(.system(size: 14, weight: .bold))
                    
                    ProgressView(value: 50, total: 500)
                        .tint(AppTheme.positive)
                        .scaleEffect(x: 1, y: 3)
                    
                    Text("10% paid")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                
                ZStack {
                    Circle().stroke(AppTheme.outline, lineWidth: 2).frame(width: 120, height: 120)
                    VStack(spacing: 8) {
                        Image(systemName: "link.badge.plus").font(.system(size: 30)).foregroundStyle(AppTheme.cardTop)
                        Text("Break the chain").font(.system(size: 10, weight: .bold))
                    }
                }
                
                Text("Every payment reduces future pressure.")
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
                Text("Did your debt plan reduce stress or surprises this month?")
                    .font(.system(size: 18, weight: .bold))
                
                VStack(spacing: 12) {
                    ForEach(["Yes, a lot", "Somewhat", "Not yet", "Still setting things up"], id: \.self) { choice in
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
                Image(systemName: "creditcard.fill").font(.system(size: 100)).foregroundStyle(AppTheme.cardTop)
            }
            
            VStack(spacing: 16) {
                Text("Level Complete!")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                Text("You created your first debt plan.")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                RewardRow(icon: "star.fill", title: "+100 XP", color: .orange)
                RewardRow(icon: "medal.fill", title: "Badge: Debt Tamer", color: AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            Button {
                store.completeLesson("debt-basics", earnedXP: 100)
                dismiss()
            } label: {
                Text("Finish Level 9")
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

struct DebtInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.system(size: 14)).foregroundStyle(AppTheme.textSecondary)
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct StrategyCard: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title).font(.system(size: 18, weight: .bold))
                    Spacer()
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isSelected ? AppTheme.cardTop : AppTheme.outline)
                }
                Text(subtitle).font(.system(size: 14)).multilineTextAlignment(.leading).foregroundStyle(AppTheme.textSecondary)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? AppTheme.cardTop.opacity(0.05) : AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(isSelected ? AppTheme.cardTop : AppTheme.outline, lineWidth: 1))
        }
        .foregroundStyle(AppTheme.textPrimary)
    }
}

#Preview {
    DebtBasicsLessonView()
        .environmentObject(BudgetPlannerStore.preview)
}
