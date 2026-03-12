import SwiftUI

struct FixedCostsLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore
    
    @State private var currentScreen = 1
    @State private var selectedQuizOption: Int? = nil
    @State private var showQuizFeedback = false
    
    // Practice Screen State
    @State private var subReviews: [String: String] = [:]
    private let subscriptions = [
        ("Netflix", 12.0), ("Spotify", 10.0), ("iCloud", 3.0), ("Gym", 30.0)
    ]
    
    // Reminders State
    @State private var remindersEnabled = true
    
    // Reflection State
    @State private var selectedReflection: Int? = nil
    
    private let totalScreens = 11
    
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
                    case 5: screen5Practice
                    case 6: screen6Insight
                    case 7: screen7Quiz
                    case 8: screen8Action
                    case 9: screen9Reminders
                    case 10: screen10Reflection
                    case 11: screen11Reward
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
                // Bottom Navigation
                if currentScreen < 11 {
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
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            .disabled(currentScreen == 7 && selectedQuizOption == nil)
            .disabled(currentScreen == 5 && subReviews.count < subscriptions.count)
            .opacity((currentScreen == 7 && selectedQuizOption == nil) || (currentScreen == 5 && subReviews.count < subscriptions.count) ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Screens
    
    private var screen1Hook: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Level 4")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                Text("Fixed Costs & Subscriptions")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "apps.iphone")
                    .font(.system(size: 80))
                    .foregroundStyle(AppTheme.cardTop)
                
                ForEach(0..<6) { i in
                    Image(systemName: "eurosign.circle.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(AppTheme.cardTop.opacity(0.5))
                        .offset(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -100...100))
                }
            }
            
            VStack(spacing: 12) {
                Text("Subscriptions are the spending you stop noticing.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Small recurring costs can quietly reduce your freedom.")
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
            Text("Fixed costs squeeze your choices")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Recurring bills and subscriptions reduce flexibility because they happen whether you think about them or not.")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 30))
                        Text("Fixed costs repeat. They take space in every future paycheck.")
                            .font(.system(size: 16, weight: .bold))
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
            Text("Small charges, big total")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 12) {
                SubscriptionMiniRow(name: "Music app", amount: "€10")
                SubscriptionMiniRow(name: "Video app", amount: "€12")
                SubscriptionMiniRow(name: "Storage app", amount: "€3")
                SubscriptionMiniRow(name: "Gym", amount: "€30")
                SubscriptionMiniRow(name: "Other app", amount: "€8")
                
                Divider().padding(.vertical, 8)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Total per month").font(.system(size: 14))
                        Text("€63").font(.system(size: 24, weight: .heavy))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Total per year").font(.system(size: 14))
                        Text("€756").font(.system(size: 24, weight: .heavy)).foregroundStyle(AppTheme.negative)
                    }
                }
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
    
    private var screen4Story: some View {
        VStack(spacing: 30) {
            Text("Lina's insight")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Lina felt like she was overspending every month. But her recurring costs were the quiet culprit:")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• €12 video app").font(.system(size: 16, weight: .bold))
                    Text("• €10 music app").font(.system(size: 16, weight: .bold))
                    Text("• €8 forgotten tool").font(.system(size: 16, weight: .bold))
                    Text("• €30 gym (barely used)").font(.system(size: 16, weight: .bold))
                }
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Text("**€60 gone** every month before she even started spending freely.")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.cardTop)
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen5Practice: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Review your payments")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text("Mark each one based on its value to you.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(spacing: 16) {
                    ForEach(subscriptions, id: \.0) { sub in
                        SubscriptionReviewCard(name: sub.0, amount: sub.1, selection: Binding(
                            get: { subReviews[sub.0] ?? "" },
                            set: { subReviews[sub.0] = $0 }
                        ))
                    }
                }
            }
            .padding(24)
        }
    }
    
    private var screen6Insight: some View {
        VStack(spacing: 30) {
            Text("Your recurring cost snapshot")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                HStack(spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Monthly Total").font(.system(size: 12))
                        Text("€55").font(.system(size: 24, weight: .heavy))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Yearly Total").font(.system(size: 12))
                        Text("€660").font(.system(size: 24, weight: .heavy))
                    }
                }
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Freedom recovered potential").font(.system(size: 14))
                        Text("€18 / month").font(.system(size: 24, weight: .heavy)).foregroundStyle(AppTheme.positive)
                    }
                    Spacer()
                    Image(systemName: "bolt.fill").foregroundStyle(AppTheme.positive)
                }
                .padding()
                .background(AppTheme.positive.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Text("Even one small review can create more room in your budget.")
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
    
    private var screen7Quiz: some View {
        VStack(spacing: 30) {
            Text("Quick check.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Which is usually harder to reduce quickly?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                VStack(spacing: 12) {
                    QuizOptionView(title: "A. Fixed costs", isSelected: selectedQuizOption == 0) {
                        selectedQuizOption = 0
                    }
                    QuizOptionView(title: "B. Variable costs", isSelected: selectedQuizOption == 1) {
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
                    Text("Fixed costs often require canceling or waiting for renewal periods.")
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
    
    private var screen8Action: some View {
        VStack(spacing: 30) {
            Text("Subscription Reset Quest")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 16) {
                ActionCardItem(title: "Review a subscription", icon: "magnifyingglass")
                ActionCardItem(title: "Pause a subscription", icon: "pause.fill")
                ActionCardItem(title: "Cancel a low-value charge", icon: "xmark.circle.fill")
                ActionCardItem(title: "Keep one intentionally", icon: "checkmark.circle.fill")
            }
            
            Text("Keeping a subscription is okay. What matters is intentionality.")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen9Reminders: some View {
        VStack(spacing: 30) {
            Text("Set renewal reminders")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                Toggle(isOn: $remindersEnabled) {
                    VStack(alignment: .leading) {
                        Text("Enable Reminders").font(.system(size: 18, weight: .bold))
                        Text("Get notified before renewal").font(.system(size: 14)).foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .tint(AppTheme.cardTop)
                .padding()
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 12) {
                    ReminderRowItem(name: "Gym", days: 5)
                    ReminderRowItem(name: "Video app", days: 8)
                }
                .opacity(remindersEnabled ? 1 : 0.5)
                
                HStack {
                    Image(systemName: "sparkles")
                    Text("+5 XP for each reminder set")
                }
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.orange)
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen10Reflection: some View {
        VStack(spacing: 30) {
            Text("Quick reflection")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                Text("Did reviewing or canceling anything reduce stress?")
                    .font(.system(size: 18, weight: .bold))
                
                VStack(spacing: 12) {
                    ForEach(["Yes, a lot", "A little", "Not yet", "I just feel clearer"].indices, id: \.self) { i in
                        Button {
                            selectedReflection = i
                        } label: {
                            Text(["Yes, a lot", "A little", "Not yet", "I just feel clearer"][i])
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(selectedReflection == i ? .white : AppTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedReflection == i ? AppTheme.cardTop : AppTheme.white)
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
    
    private var screen11Reward: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle().fill(AppTheme.cardTop.opacity(0.1)).frame(width: 250, height: 250)
                Image(systemName: "apps.iphone").font(.system(size: 100)).foregroundStyle(AppTheme.cardTop)
            }
            
            VStack(spacing: 16) {
                Text("Level Complete!")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                Text("You reviewed your recurring costs.")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                RewardRow(icon: "star.fill", title: "+75 XP", color: .orange)
                RewardRow(icon: "medal.fill", title: "Badge: Leak Plugger", color: AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            Button {
                store.completeLesson("fixed-costs", earnedXP: 75)
                dismiss()
            } label: {
                Text("Finish Level 4")
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

struct SubscriptionMiniRow: View {
    let name: String
    let amount: String
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text(amount).font(.system(size: 16, weight: .bold))
        }
    }
}

struct SubscriptionReviewCard: View {
    let name: String
    let amount: Double
    @Binding var selection: String
    
    private let options = [
        ("Essential", Color.blue), ("Useful", Color.gray), ("Low value", Color.orange), ("Forgot", Color.red)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(name).font(.system(size: 18, weight: .bold))
                Spacer()
                Text(String(format: "€%.0f", amount)).font(.system(size: 18, weight: .heavy))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(options, id: \.0) { option in
                        Button {
                            selection = option.0
                        } label: {
                            Text(option.0)
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selection == option.0 ? option.1 : AppTheme.white)
                                .foregroundStyle(selection == option.0 ? .white : AppTheme.textSecondary)
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(AppTheme.outline, lineWidth: 1))
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct ActionCardItem: View {
    let title: String
    let icon: String
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundStyle(AppTheme.cardTop)
            Text(title).font(.system(size: 16, weight: .bold))
            Spacer()
            Image(systemName: "chevron.right").font(.system(size: 12)).foregroundStyle(AppTheme.outline)
        }
        .padding()
        .background(AppTheme.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

struct ReminderRowItem: View {
    let name: String
    let days: Int
    var body: some View {
        HStack {
            Text(name)
            Spacer()
            Text("in \(days) days").font(.system(size: 14)).foregroundStyle(AppTheme.textSecondary)
            Image(systemName: "bell.badge.fill").foregroundStyle(.orange)
        }
        .padding()
        .background(AppTheme.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    FixedCostsLessonView()
        .environmentObject(BudgetPlannerStore.preview)
}
