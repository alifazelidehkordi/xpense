import SwiftUI

struct GoalBasedSavingLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore
    
    @State private var currentScreen = 1
    @State private var selectedQuizOption: Int? = nil
    @State private var showQuizFeedback = false
    
    // Goal Creation State
    @State private var selectedGoalType: String? = nil
    @State private var targetAmount: String = ""
    @State private var targetDate = Date().addingTimeInterval(86400 * 30 * 3) // 3 months from now
    
    // Habit Builder State
    @State private var transferFrequency: String = "Weekly"
    
    // Reflection State
    @State private var selectedReflections: Set<String> = []
    
    private let totalScreens = 13
    
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
                    case 5: screen5ChooseGoal
                    case 6: screen6SetAmount
                    case 7: screen7SetTimeline
                    case 8: screen8GoalPlan
                    case 9: screen9Quiz
                    case 10: screen10Habit
                    case 11: screen11Progress
                    case 12: screen12Reflection
                    case 13: screen13Reward
                    default: EmptyView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                
                // Bottom Navigation
                if currentScreen < 13 {
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
                if currentScreen == 9 {
                    if selectedQuizOption == 1 {
                        withAnimation { currentScreen += 1 }
                    } else {
                        withAnimation { showQuizFeedback = true }
                    }
                } else {
                    withAnimation { currentScreen += 1 }
                }
            } label: {
                Text(currentScreen == 9 ? "Check Answer" : "Continue")
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
        if currentScreen == 5 && selectedGoalType == nil { return true }
        if currentScreen == 6 && targetAmount.isEmpty { return true }
        if currentScreen == 9 && selectedQuizOption == nil { return true }
        return false
    }
    
    // MARK: - Screens
    
    private var screen1Hook: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Level 5")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                Text("Goal-Based Saving")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 10) {
                    Image(systemName: "jar.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(AppTheme.cardTop)
                    Text("Dream Goal")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.white)
                        .clipShape(Capsule())
                }
            }
            
            VStack(spacing: 12) {
                Text("Saving works best when it’s a plan — not a leftover.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Goals turn saving from discipline into visible progress.")
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
            Text("Save for something specific")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("When your money has a job, it’s easier to protect it. Goals turn saving from abstract discipline into visible progress.")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(AppTheme.positive)
                        Text("Clear goal → Clear progress → Higher motivation")
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
            Text("Small steps, big goals")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    HStack {
                        Text("Goal Amount")
                        Spacer()
                        Text("€100").font(.system(size: 18, weight: .bold))
                    }
                    HStack {
                        Text("Time")
                        Spacer()
                        Text("8 weeks").font(.system(size: 18, weight: .bold))
                    }
                }
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                VStack(spacing: 8) {
                    Text("Weekly target")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("€12.50")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(AppTheme.cardTop)
                }
                
                Text("Breaking goals into weekly targets makes them feel achievable.")
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
            Text("Sofia's transformation")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Sofia wanted to save for travel. But she only saved “at the end of the month.”")
                    .font(.system(size: 18, weight: .medium))
                
                Text("Nothing was ever left.")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.negative)
                
                Text("When she set a specific goal and schedule, saving became automatic.")
                    .font(.system(size: 18, weight: .medium))
                
                HStack {
                    Image(systemName: "airplane")
                    Text("Trip fund: €15 / week")
                }
                .font(.system(size: 18, weight: .bold))
                .padding()
                .background(AppTheme.cardTop.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen5ChooseGoal: some View {
        VStack(spacing: 24) {
            Text("Choose your goal")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                GoalTypeCard(title: "Emergency fund", icon: "🛟", isSelected: selectedGoalType == "Emergency fund") { selectedGoalType = "Emergency fund" }
                GoalTypeCard(title: "Travel", icon: "✈️", isSelected: selectedGoalType == "Travel") { selectedGoalType = "Travel" }
                GoalTypeCard(title: "Bills", icon: "📄", isSelected: selectedGoalType == "Bills") { selectedGoalType = "Bills" }
                GoalTypeCard(title: "Gadget", icon: "📱", isSelected: selectedGoalType == "Gadget") { selectedGoalType = "Gadget" }
                GoalTypeCard(title: "Education", icon: "🎓", isSelected: selectedGoalType == "Education") { selectedGoalType = "Education" }
                GoalTypeCard(title: "Custom goal", icon: "✨", isSelected: selectedGoalType == "Custom goal") { selectedGoalType = "Custom goal" }
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen6SetAmount: some View {
        VStack(spacing: 30) {
            Text("How much do you want to save?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                TextField("€ 0", text: $targetAmount)
                    .keyboardType(.numberPad)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(AppTheme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                HStack(spacing: 12) {
                    SuggestionChip(label: "€100") { targetAmount = "100" }
                    SuggestionChip(label: "€300") { targetAmount = "300" }
                    SuggestionChip(label: "€500") { targetAmount = "500" }
                    SuggestionChip(label: "€1000") { targetAmount = "1000" }
                }
                
                Text("Your goal can always be adjusted later.")
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
    
    private var screen7SetTimeline: some View {
        VStack(spacing: 30) {
            Text("When do you want to reach this?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                DatePicker("Target date", selection: $targetDate, in: Date()..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(AppTheme.cardTop)
                
                let amount = Double(targetAmount) ?? 0
                let weeks = max(1, Calendar.current.dateComponents([.weekOfYear], from: Date(), to: targetDate).weekOfYear ?? 1)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("You need to save").font(.system(size: 14))
                        Text(String(format: "€%.2f / week", amount / Double(weeks)))
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundStyle(AppTheme.cardTop)
                    }
                    Spacer()
                    Image(systemName: "calendar")
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
    
    private var screen8GoalPlan: some View {
        VStack(spacing: 30) {
            Text("Your saving plan")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    HStack { Text("Goal"); Spacer(); Text(selectedGoalType ?? "Travel fund").bold() }
                    HStack { Text("Target"); Spacer(); Text("€\(targetAmount)").bold() }
                    HStack { Text("Timeline"); Spacer(); Text("12 weeks").bold() } // Mocked 12 weeks for visual consistency
                    HStack { Text("Weekly saving"); Spacer(); Text("€25").bold().foregroundStyle(AppTheme.cardTop) } // Mocked for visual consistency
                }
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 8) {
                    Text("Suggested first transfer")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("€25")
                        .font(.system(size: 32, weight: .heavy))
                }
                
                Text("Saving small amounts regularly builds powerful momentum.")
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
    
    private var screen9Quiz: some View {
        VStack(spacing: 30) {
            Text("Quick check.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 24) {
                Text("What makes saving more reliable?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                VStack(spacing: 12) {
                    QuizOptionView(title: "A. Saving what is left at the end", isSelected: selectedQuizOption == 0) {
                        selectedQuizOption = 0
                    }
                    QuizOptionView(title: "B. Scheduling the saving first", isSelected: selectedQuizOption == 1) {
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
                    Text("Saving first protects your goal before other spending happens.")
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
    
    private var screen10Habit: some View {
        VStack(spacing: 30) {
            Text("Create your transfer habit")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                Text("Schedule your saving so it happens automatically.")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AppTheme.textSecondary)
                
                Picker("Frequency", selection: $transferFrequency) {
                    Text("Weekly").tag("Weekly")
                    Text("Monthly").tag("Monthly")
                    Text("Manual").tag("Manual")
                }
                .pickerStyle(.segmented)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Frequency").font(.system(size: 12))
                        Text(transferFrequency).font(.system(size: 18, weight: .bold))
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Amount").font(.system(size: 12))
                        Text("€25").font(.system(size: 18, weight: .bold))
                    }
                }
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Recurring transfer starts tomorrow")
                }
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
    
    private var screen11Progress: some View {
        VStack(spacing: 30) {
            Text("Goal progress")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text(selectedGoalType ?? "Travel fund")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text("€25 / €\(targetAmount)")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    ProgressView(value: 25, total: 300)
                        .tint(AppTheme.cardTop)
                    
                    HStack {
                        Text("8% complete").font(.system(size: 14, weight: .bold))
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach([10, 25, 50, 75, 100], id: \.self) { milestone in
                                Text("\(milestone)%")
                                    .font(.system(size: 10))
                                    .padding(4)
                                    .background(AppTheme.outline)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(24)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                
                HStack(spacing: 15) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.orange)
                    Text("Every small step moves you closer to your goal.")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding()
                .background(AppTheme.cardTop.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen12Reflection: some View {
        VStack(spacing: 30) {
            Text("Quick reflection")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                Text("What did you say **no** to that helped your goal?")
                    .font(.system(size: 18, weight: .bold))
                
                VStack(spacing: 12) {
                    ReflectionChoiceRow(title: "Skipped food delivery", icon: "takeoutbag.and.cup.and.straw", isSelected: selectedReflections.contains("Skipped food delivery")) {
                        toggleReflection("Skipped food delivery")
                    }
                    ReflectionChoiceRow(title: "Cooked at home", icon: "stove", isSelected: selectedReflections.contains("Cooked at home")) {
                        toggleReflection("Cooked at home")
                    }
                    ReflectionChoiceRow(title: "Delayed an impulse buy", icon: "hand.raised.fill", isSelected: selectedReflections.contains("Delayed an impulse buy")) {
                        toggleReflection("Delayed an impulse buy")
                    }
                    ReflectionChoiceRow(title: "Nothing yet", icon: "clock", isSelected: selectedReflections.contains("Nothing yet")) {
                        toggleReflection("Nothing yet")
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
    
    private func toggleReflection(_ choice: String) {
        if selectedReflections.contains(choice) {
            selectedReflections.remove(choice)
        } else {
            selectedReflections.insert(choice)
        }
    }
    
    private var screen13Reward: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle().fill(AppTheme.cardTop.opacity(0.1)).frame(width: 250, height: 250)
                Image(systemName: "flag.checkered").font(.system(size: 100)).foregroundStyle(AppTheme.cardTop)
            }
            
            VStack(spacing: 16) {
                Text("Level Complete!")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                Text("You created your first saving goal.")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                RewardRow(icon: "star.fill", title: "+80 XP", color: .orange)
                RewardRow(icon: "medal.fill", title: "Badge: Pay Yourself First", color: AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            Button {
                store.completeLesson("goal-based-saving", earnedXP: 80)
                dismiss()
            } label: {
                Text("Finish Level 5")
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

struct GoalTypeCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(icon).font(.system(size: 40))
                Text(title).font(.system(size: 14, weight: .bold)).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .background(isSelected ? AppTheme.cardTop.opacity(0.1) : AppTheme.white)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? AppTheme.cardTop : AppTheme.outline, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .foregroundStyle(AppTheme.textPrimary)
    }
}

struct SuggestionChip: View {
    let label: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.background)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(AppTheme.outline, lineWidth: 1))
        }
        .foregroundStyle(AppTheme.textPrimary)
    }
}

struct ReflectionChoiceRow: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon).foregroundStyle(isSelected ? AppTheme.cardTop : AppTheme.textSecondary)
                Text(title).font(.system(size: 16, weight: .bold))
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? AppTheme.cardTop : AppTheme.outline)
            }
            .padding()
            .background(isSelected ? AppTheme.cardTop.opacity(0.05) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(isSelected ? AppTheme.cardTop : AppTheme.outline, lineWidth: 1))
        }
        .foregroundStyle(AppTheme.textPrimary)
    }
}

#Preview {
    GoalBasedSavingLessonView()
        .environmentObject(BudgetPlannerStore.preview)
}
