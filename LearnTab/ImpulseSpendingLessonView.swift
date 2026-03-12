import SwiftUI

struct ImpulseSpendingLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore
    
    @State private var currentScreen = 1
    @State private var selectedQuizOption: Int? = nil
    @State private var showQuizFeedback = false
    
    // Trigger State
    @State private var selectedTrigger: String? = nil
    
    // If-Then Plan State
    @State private var ifThenPart1: String = ""
    @State private var ifThenPart2: String = ""
    
    // Recovery State
    @State private var showRecoveryChallenge = false
    
    // Reflection State
    @State private var reflectionTrigger: String? = nil
    
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
                    case 5: screen5IdentifyTrigger
                    case 6: screen6BuildPlan
                    case 7: screen7Quiz
                    case 8: screen8ActionPrompt
                    case 9: screen9TriggerLog
                    case 10: screen10Recovery
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
        if currentScreen == 5 && selectedTrigger == nil { return true }
        if currentScreen == 6 && (ifThenPart1.isEmpty || ifThenPart2.isEmpty) { return true }
        if currentScreen == 7 && selectedQuizOption == nil { return true }
        return false
    }
    
    // MARK: - Screens
    
    private var screen1Hook: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Level 8")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                Text("Impulse Spending")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                HStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.textSecondary)
                        Text("Instant Buy")
                            .font(.system(size: 10, weight: .bold))
                    }
                    
                    VStack(spacing: 8) {
                        Image(systemName: "hourglass")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.positive)
                        Text("Pause & Think")
                            .font(.system(size: 10, weight: .bold))
                    }
                }
            }
            
            VStack(spacing: 12) {
                Text("Impulse isn’t lack of willpower.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("It’s usually a trigger plus a habit pattern.")
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
            Text("Spot the trigger, interrupt the loop")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Impulse spending often follows emotional or situational triggers. When you name the trigger, you can redesign the pattern.")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(spacing: 16) {
                    HStack {
                        VStack(spacing: 4) {
                            Text("Trigger")
                            Image(systemName: "bolt.fill").foregroundStyle(.orange)
                        }
                        Image(systemName: "arrow.right")
                        VStack(spacing: 4) {
                            Text("Urge")
                            Image(systemName: "brain.head.profile").foregroundStyle(AppTheme.cardTop)
                        }
                        Image(systemName: "arrow.right")
                        VStack(spacing: 4) {
                            Text("Purchase")
                            Image(systemName: "cart.fill").foregroundStyle(AppTheme.textPrimary)
                        }
                    }
                    .font(.system(size: 12, weight: .bold))
                    .padding()
                    .background(AppTheme.cardTop.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                Text("Common triggers: Stress, Boredom, Social pressure, Convenience, Ads.")
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
    
    private var screen3Example: some View {
        VStack(spacing: 30) {
            Text("A common spending pattern")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Late-night stress").bold()
                    HStack {
                        Image(systemName: "arrow.right")
                        Text("Food delivery").foregroundStyle(AppTheme.negative)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Better plan (If–Then):").font(.system(size: 14, weight: .bold))
                    Text("**If** I want to order after 10pm").font(.system(size: 16))
                    Text("**Then** I wait 15 minutes and check food options at home").font(.system(size: 16)).foregroundStyle(AppTheme.positive)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.positive.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                Text("Planning the interruption before the urge happens makes it easier.")
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
            Text("Alex’s online shopping habit")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Alex often bought things late at night while scrolling.")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Trigger:").bold()
                    Text("Boredom + phone browsing")
                        .foregroundStyle(AppTheme.negative)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Solution:").bold()
                    Text("“If I want to buy something late at night, then I save it and check tomorrow.”")
                        .foregroundStyle(AppTheme.positive)
                }
                
                Text("Result: Impulse purchases dropped significantly.")
                    .font(.system(size: 18, weight: .bold))
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen5IdentifyTrigger: some View {
        VStack(spacing: 24) {
            Text("What triggers your impulse spending?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            let triggers = ["Stress", "Boredom", "Friends going out", "Online ads", "Payday excitement", "Convenience", "Late-night tiredness"]
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(triggers, id: \.self) { trigger in
                        TriggerCard(title: trigger, isSelected: selectedTrigger == trigger) {
                            selectedTrigger = trigger
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen6BuildPlan: some View {
        VStack(spacing: 30) {
            Text("Create your If–Then plan")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("IF I feel...").font(.system(size: 14, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                    TextField(selectedTrigger ?? "e.g. bored", text: $ifThenPart1)
                        .padding()
                        .background(AppTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("THEN I will...").font(.system(size: 14, weight: .bold)).foregroundStyle(AppTheme.textSecondary)
                    TextField("e.g. wait 10 mins", text: $ifThenPart2)
                        .padding()
                        .background(AppTheme.background)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Example:").font(.system(size: 12, weight: .bold))
                    Text("“If I feel bored at night, then I will save the item for tomorrow.”").font(.system(size: 14)).italic()
                }
                .padding()
                .background(AppTheme.cardTop.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 10))
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
                Text("Which strategy usually works better?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                VStack(spacing: 12) {
                    QuizOptionView(title: "A. “I’ll just try harder”", isSelected: selectedQuizOption == 0) {
                        selectedQuizOption = 0
                    }
                    QuizOptionView(title: "B. A specific If–Then plan", isSelected: selectedQuizOption == 1) {
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
                    Text("Specific plans work because they prepare your brain before the trigger happens.")
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
            Text("Start your Pause Before Checkout streak")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                Text("Practice pausing before buying for 7 days.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                
                VStack(alignment: .leading, spacing: 15) {
                    ActionBullet(icon: "timer", title: "Pause timer")
                    ActionBullet(icon: "bolt.fill", title: "Trigger tracking")
                    ActionBullet(icon: "star.fill", title: "Urge-resist rewards")
                }
                
                HStack {
                    Text("Day 1 of 7")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    ProgressView(value: 1, total: 7).frame(width: 100).tint(AppTheme.cardTop)
                }
                .padding()
                .background(AppTheme.cardTop.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen9TriggerLog: some View {
        VStack(spacing: 30) {
            Text("Your trigger log")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    TriggerLogRow(trigger: "Stress", action: "Paused purchase")
                    TriggerLogRow(trigger: "Online ad", action: "Ignored")
                    TriggerLogRow(trigger: "Social pressure", action: "Checked budget")
                }
                
                Divider()
                
                HStack(spacing: 20) {
                    StatCard(title: "Urges", value: "5")
                    StatCard(title: "Paused", value: "3")
                    StatCard(title: "Skipped", value: "2", color: AppTheme.positive)
                }
                
                Text("Recognizing triggers is a powerful skill.")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen10Recovery: some View {
        VStack(spacing: 30) {
            Text("Missed a pause? That's okay")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                Text("One missed moment doesn’t erase progress. Financial habits are built over time, not in one perfect day.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textSecondary)
                
                Button {
                    showRecoveryChallenge = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Start Recovery Challenge")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.cardTop.opacity(0.1))
                    .clipShape(Capsule())
                }
                .foregroundStyle(AppTheme.cardTop)
                
                Text("Comeback XP available")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
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
                Text("What trigger showed up most often?")
                    .font(.system(size: 18, weight: .bold))
                
                VStack(spacing: 12) {
                    ForEach(["Stress", "Boredom", "Social pressure", "Convenience"], id: \.self) { choice in
                        Button {
                            reflectionTrigger = choice
                        } label: {
                            Text(choice)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(reflectionTrigger == choice ? .white : AppTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(reflectionTrigger == choice ? AppTheme.cardTop : AppTheme.white)
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
                Image(systemName: "bolt.fill").font(.system(size: 100)).foregroundStyle(AppTheme.cardTop)
            }
            
            VStack(spacing: 16) {
                Text("Level Complete!")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                Text("You redesigned your spending pattern.")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                RewardRow(icon: "star.fill", title: "+95 XP", color: .orange)
                RewardRow(icon: "medal.fill", title: "Badge: Pattern Breaker", color: AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            Button {
                store.completeLesson("impulse-spending", earnedXP: 95)
                dismiss()
            } label: {
                Text("Finish Level 8")
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

struct TriggerCard: View {
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

struct ActionBullet: View {
    let icon: String
    let title: String
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(AppTheme.cardTop)
            Text(title).font(.system(size: 16, weight: .medium))
        }
    }
}

struct TriggerLogRow: View {
    let trigger: String
    let action: String
    var body: some View {
        HStack {
            Text(trigger).font(.system(size: 14)).foregroundStyle(AppTheme.textSecondary)
            Spacer()
            Text(action).font(.system(size: 14, weight: .bold))
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ImpulseSpendingLessonView()
        .environmentObject(BudgetPlannerStore.preview)
}
