import SwiftUI

struct EmergencyBufferLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore
    
    @State private var currentScreen = 1
    @State private var selectedQuizOption: Int? = nil
    @State private var showQuizFeedback = false
    
    // Buffer Builder State
    @State private var selectedBufferTarget: Double = 100
    @State private var weeklyContribution: Double = 5
    
    // Reflection State
    @State private var selectedReflection: Int? = nil
    
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
                    case 5: screen5ChooseTarget
                    case 6: screen6WeeklyContribution
                    case 7: screen7Summary
                    case 8: screen8Quiz
                    case 9: screen9Habit
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
            .disabled(currentScreen == 8 && selectedQuizOption == nil)
            .opacity(currentScreen == 8 && selectedQuizOption == nil ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Screens
    
    private var screen1Hook: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Level 6")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                Text("Emergency Buffer")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                Image(systemName: "shield.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(AppTheme.cardTop)
                    .lessonBounceEffect()
            }
            
            VStack(spacing: 12) {
                Text("A small buffer prevents big panic decisions.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Even a small safety cushion can reduce stress and financial mistakes.")
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
            Text("Small protection matters")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("A buffer protects you from timing shocks and surprise costs. It helps you avoid panic, fees, and unnecessary debt.")
                    .font(.system(size: 18, weight: .medium))
                
                VStack(spacing: 16) {
                    HStack(spacing: 15) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 40))
                            .foregroundStyle(AppTheme.cardTop)
                        VStack(alignment: .leading) {
                            Text("Buffer ≠ Wealth")
                                .font(.system(size: 18, weight: .black))
                            Text("Buffer = Protection")
                                .font(.system(size: 18, weight: .black))
                                .foregroundStyle(AppTheme.cardTop)
                        }
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
            Text("Why even €80 matters")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack { Text("Rent due"); Spacer(); Text("€900").bold() }
                    HStack { Text("Account balance"); Spacer(); Text("€860").bold().foregroundStyle(AppTheme.negative) }
                }
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                
                HStack(spacing: 20) {
                    VStack(spacing: 10) {
                        Text("Without buffer")
                            .font(.system(size: 12, weight: .bold))
                        VStack(alignment: .leading, spacing: 5) {
                            Text("❌ Overdraft fee")
                            Text("❌ Stress")
                        }
                        .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.negative.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    
                    VStack(spacing: 10) {
                        Text("With buffer")
                            .font(.system(size: 12, weight: .bold))
                        VStack(alignment: .leading, spacing: 5) {
                            Text("✅ €80 buffer")
                            Text("✅ Problem solved")
                        }
                        .font(.system(size: 12))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.positive.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                Text("Small buffers can solve real-life timing problems.")
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
            Text("Marco’s stressful moment")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Marco’s electricity bill came earlier than expected. He had only €40 in his account.")
                    .font(.system(size: 18, weight: .medium))
                
                Text("Without a buffer, he had to borrow money.")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.negative)
                
                Text("Later he built a **€100 emergency buffer**. The next surprise bill? No panic.")
                    .font(.system(size: 18, weight: .medium))
                
                HStack {
                    Image(systemName: "shield.fill")
                    Text("Safety cushion: €100")
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
    
    private var screen5ChooseTarget: some View {
        VStack(spacing: 30) {
            Text("Choose your starter buffer")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 16) {
                ForEach([50.0, 100.0, 200.0], id: \.self) { amount in
                    Button {
                        selectedBufferTarget = amount
                    } label: {
                        HStack {
                            Text("€\(Int(amount))")
                                .font(.system(size: 24, weight: .heavy))
                            Spacer()
                            if selectedBufferTarget == amount {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.cardTop)
                            }
                        }
                        .padding(24)
                        .background(selectedBufferTarget == amount ? AppTheme.cardTop.opacity(0.1) : AppTheme.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(selectedBufferTarget == amount ? AppTheme.cardTop : AppTheme.outline, lineWidth: 2))
                    }
                    .foregroundStyle(AppTheme.textPrimary)
                }
                
                Text("Your buffer can grow later. Start small and build momentum.")
                    .font(.system(size: 14))
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen6WeeklyContribution: some View {
        VStack(spacing: 30) {
            Text("How much can you add weekly?")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    ForEach([3.0, 5.0, 10.0], id: \.self) { amount in
                        Button {
                            weeklyContribution = amount
                        } label: {
                            Text("€\(Int(amount))")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(weeklyContribution == amount ? AppTheme.cardTop : AppTheme.white)
                                .foregroundStyle(weeklyContribution == amount ? .white : AppTheme.textPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(AppTheme.outline, lineWidth: 1))
                        }
                    }
                }
                
                let weeks = Int(ceil(selectedBufferTarget / weeklyContribution))
                
                VStack(spacing: 15) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Contribution").font(.system(size: 12))
                            Text("€\(Int(weeklyContribution)) / week").font(.system(size: 18, weight: .bold))
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Estimated time").font(.system(size: 12))
                            Text("\(weeks) weeks").font(.system(size: 18, weight: .bold)).foregroundStyle(AppTheme.cardTop)
                        }
                    }
                    
                    Text("Even small contributions build protection over time.")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding()
                .background(AppTheme.cardTop.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen7Summary: some View {
        VStack(spacing: 30) {
            Text("Your buffer plan")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    HStack { Text("Target buffer"); Spacer(); Text("€\(Int(selectedBufferTarget))").bold() }
                    HStack { Text("Weekly contribution"); Spacer(); Text("€\(Int(weeklyContribution))").bold() }
                    HStack { Text("Estimated completion"); Spacer(); Text("\(Int(ceil(selectedBufferTarget/weeklyContribution))) weeks").bold().foregroundStyle(AppTheme.cardTop) }
                }
                .padding()
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                VStack(spacing: 8) {
                    Text("First contribution")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.textSecondary)
                    Text("€\(Int(weeklyContribution))")
                        .font(.system(size: 32, weight: .heavy))
                }
                
                HStack(spacing: 15) {
                    Image(systemName: "shield.fill")
                        .foregroundStyle(AppTheme.cardTop)
                    Text("Every small contribution increases your safety.")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding()
                .background(AppTheme.cardTop.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen8Quiz: some View {
        VStack(spacing: 30) {
            Text("Quick check.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Which situation is closer to a real emergency?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                VStack(spacing: 12) {
                    QuizOptionView(title: "A. Phone charger broke", isSelected: selectedQuizOption == 0) {
                        selectedQuizOption = 0
                    }
                    QuizOptionView(title: "B. Rent due and account short", isSelected: selectedQuizOption == 1) {
                        selectedQuizOption = 1
                    }
                    QuizOptionView(title: "C. Flash sale online", isSelected: selectedQuizOption == 2) {
                        selectedQuizOption = 2
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
                    Text("A real emergency threatens essential needs like housing or bills.")
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
    
    private var screen9Habit: some View {
        VStack(spacing: 30) {
            Text("Buffer Builder Quest")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                HabitFeatureRow(icon: "flame.fill", title: "Weekly saving streak")
                HabitFeatureRow(icon: "shield.fill", title: "Growing safety shield")
                HabitFeatureRow(icon: "flag.checkered", title: "Progress milestones")
                
                Divider()
                
                HStack {
                    Text("Week 1 started")
                        .font(.system(size: 18, weight: .bold))
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.positive)
                }
                .padding()
                .background(AppTheme.positive.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen10Progress: some View {
        VStack(spacing: 30) {
            Text("Your emergency buffer")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        Text("Buffer Progress")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text("€10 / €\(Int(selectedBufferTarget))")
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    
                    ProgressView(value: 10, total: selectedBufferTarget)
                        .tint(AppTheme.cardTop)
                    
                    HStack {
                        Text("10% complete").font(.system(size: 14, weight: .bold))
                        Spacer()
                        Text("First €\(Int(selectedBufferTarget/2)) milestone")
                            .font(.system(size: 10))
                            .padding(6)
                            .background(AppTheme.outline)
                            .clipShape(Capsule())
                    }
                }
                .padding(24)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                
                HStack(spacing: 15) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.orange)
                    Text("Your financial safety is growing.")
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
    
    private var screen11Reflection: some View {
        VStack(spacing: 30) {
            Text("Quick reflection")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 20) {
                Text("Did having even a small buffer change how confident you felt?")
                    .font(.system(size: 18, weight: .bold))
                
                VStack(spacing: 12) {
                    ForEach(["Yes, a lot", "A little", "Not yet", "Still building"].indices, id: \.self) { i in
                        Button {
                            selectedReflection = i
                        } label: {
                            Text(["Yes, a lot", "A little", "Not yet", "Still building"][i])
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
    
    private var screen12Reward: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle().fill(AppTheme.cardTop.opacity(0.1)).frame(width: 250, height: 250)
                Image(systemName: "shield.fill").font(.system(size: 100)).foregroundStyle(AppTheme.cardTop)
            }
            
            VStack(spacing: 16) {
                Text("Level Complete!")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                Text("You started building your emergency buffer.")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                RewardRow(icon: "star.fill", title: "+85 XP", color: .orange)
                RewardRow(icon: "medal.fill", title: "Badge: Shock Absorber", color: AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            Button {
                store.completeLesson("emergency-buffer", earnedXP: 85)
                dismiss()
            } label: {
                Text("Finish Level 6")
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

#Preview {
    EmergencyBufferLessonView()
        .environmentObject(BudgetPlannerStore.preview)
}
