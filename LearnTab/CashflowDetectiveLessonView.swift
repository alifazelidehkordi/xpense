import SwiftUI

struct CashflowDetectiveLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore
    
    @State private var currentScreen = 1
    @State private var payday: Int = 28
    @State private var rentDue: Int = 1
    @State private var internetDue: Int = 3
    @State private var minBalanceRule: Double = 50
    @State private var selectedQuizOption: Int? = nil
    @State private var showQuizFeedback = false
    
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
                    case 3: screen3Visual
                    case 4: screen4Story
                    case 5: screen5Setup
                    case 6: screen6Map
                    case 7: screen7SafetyRule
                    case 8: screen8Quiz
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
                if currentScreen < 9 {
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
                    .shadow(color: AppTheme.cardTop.opacity(0.3), radius: 10, x: 0, y: 5)
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
                Text("Level 1")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                Text("Cashflow Basics")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            ZStack {
                Circle()
                    .fill(AppTheme.cardTop.opacity(0.1))
                    .frame(width: 200, height: 200)
                
                VStack(spacing: 15) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 60))
                        .foregroundStyle(AppTheme.cardTop)
                    
                    HStack(spacing: 20) {
                        Image(systemName: "banknote.fill")
                            .foregroundStyle(AppTheme.positive)
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(AppTheme.negative)
                    }
                    .font(.system(size: 30))
                }
            }
            
            VStack(spacing: 12) {
                Text("Why do you feel broke before payday?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textPrimary)
                
                Text("Even when you earn enough, bad timing can create money stress.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.horizontal, 20)
            }
            
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppTheme.cardTop)
                Text("+25 XP available")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(AppTheme.white.opacity(0.9))
            .clipShape(Capsule())
            
            Spacer()
        }
        .padding(.top, 40)
    }
    
    private var screen2Concept: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Concept")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.cardTop.opacity(0.1))
                    .clipShape(Capsule())
                
                Text("What is a Cashflow Gap?")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("A cashflow gap happens when money goes out **before new money comes in**.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text("Even if your income covers your expenses, the **timing** can still create stress.")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(24)
            .background(AppTheme.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 10)
            
            VStack(spacing: 20) {
                Text("The Timing Loop")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                
                HStack(spacing: 0) {
                    TimelineItem(icon: "banknote.fill", label: "Payday", color: AppTheme.positive)
                    TimelineLine()
                    TimelineItem(icon: "house.fill", label: "Bills", color: AppTheme.negative)
                    TimelineLine()
                    TimelineItem(icon: "cart.fill", label: "Grocery", color: AppTheme.cardTop)
                    TimelineLine()
                    TimelineItem(icon: "exclamationmark.circle.fill", label: "Empty", color: AppTheme.negative)
                }
                .padding(.horizontal, 10)
            }
            .padding(.top, 40)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 30)
    }
    
    private var screen3Visual: some View {
        VStack(spacing: 30) {
            Text("Visual Guide")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.cardTop)
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Example Timeline")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                VStack(spacing: 16) {
                    TimelineRow(date: "30th", title: "Payday", amount: "+€2000", color: AppTheme.positive)
                    
                    VStack(spacing: 0) {
                        TimelineRow(date: "1st", title: "Rent", amount: "-€900", color: AppTheme.negative)
                        TimelineRow(date: "2nd", title: "Internet", amount: "-€40", color: AppTheme.negative)
                        TimelineRow(date: "3rd", title: "Groceries", amount: "-€100", color: AppTheme.negative)
                    }
                    .padding(16)
                    .background(AppTheme.negative.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.negative.opacity(0.2), lineWidth: 1)
                    )
                    
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Stress window (Day 1-5)")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                        Spacer()
                    }
                    .foregroundStyle(AppTheme.negative)
                    .padding(.horizontal, 16)
                }
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            Text("This is where many people feel broke — even though their income is enough.")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppTheme.textSecondary)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 30)
    }
    
    private var screen4Story: some View {
        VStack(spacing: 30) {
            Text("Maria's Story")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.cardTop)
            
            VStack(spacing: 24) {
                Circle()
                    .fill(Color(hex: 0xFDE0E0))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("👤")
                            .font(.system(size: 50))
                    )
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Maria gets paid on the 30th.")
                    Text("Her rent leaves on the 1st,\nGroceries on the 2nd,\nInternet on the 3rd.")
                    Text("By the 5th she feels broke.")
                    
                    Text("But the real problem is **timing**, not income.")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.cardTop)
                }
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .multilineTextAlignment(.leading)
            }
            .padding(30)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 36))
            .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 30)
    }
    
    private var screen5Setup: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Let's map your money timing.")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    
                    Text("Enter your typical dates so we can see your stress window.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("1. When do you get paid?")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    Picker("Payday", selection: $payday) {
                        ForEach(1...31, id: \.self) { day in
                            Text("Day \(day)").tag(day)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.white)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("2. When are big bills due?")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    VStack(spacing: 12) {
                        HStack {
                            Text("Rent")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Picker("Rent", selection: $rentDue) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("Day \(day)").tag(day)
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        HStack {
                            Text("Internet")
                                .font(.system(size: 16, weight: .semibold))
                            Spacer()
                            Picker("Internet", selection: $internetDue) {
                                ForEach(1...31, id: \.self) { day in
                                    Text("Day \(day)").tag(day)
                                }
                            }
                        }
                        .padding()
                        .background(AppTheme.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                    }
                }
                
                Button {} label: {
                    Label("Add Another Bill", systemImage: "plus")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.cardTop)
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
    
    private var screen6Map: some View {
        VStack(spacing: 30) {
            Text("Your Cashflow Map")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "banknote.fill")
                            .foregroundStyle(AppTheme.positive)
                        Text("Payday: Day \(payday)")
                        Spacer()
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Upcoming Bills:")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(AppTheme.textSecondary)
                        
                        HStack {
                            Text("Day \(rentDue)")
                            Text("Rent")
                            Spacer()
                        }
                        HStack {
                            Text("Day \(internetDue)")
                            Text("Internet")
                            Spacer()
                        }
                    }
                    .padding()
                    .background(AppTheme.white.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .padding(24)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "timer")
                        Text("STRESS WINDOW")
                        Spacer()
                    }
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(AppTheme.negative)
                    
                    Text("Day \(min(rentDue, internetDue)) → Day 5")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    
                    Text("This is when your balance is most vulnerable.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .padding(24)
                .background(AppTheme.negative.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            
            Text("Protect this period by keeping a safety buffer.")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 30)
    }
    
    private var screen7SafetyRule: some View {
        VStack(spacing: 30) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Create your Payday Safety Rule.")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                
                Text("Keep a small minimum balance until your next income arrives to protect your stress window.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                ForEach([50, 100, 150], id: \.self) { amount in
                    Button {
                        minBalanceRule = Double(amount)
                    } label: {
                        HStack {
                            Text("€\(amount)")
                                .font(.system(size: 18, weight: .bold))
                            Spacer()
                            if minBalanceRule == Double(amount) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(AppTheme.positive)
                            }
                        }
                        .padding(20)
                        .background(AppTheme.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(minBalanceRule == Double(amount) ? AppTheme.cardTop : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Text("This protects you from falling into the cashflow gap.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.textSecondary)
            
            Spacer()
        }
        .padding(24)
    }
    
    private var screen8Quiz: some View {
        VStack(spacing: 30) {
            Text("Quick check.")
                .font(.system(size: 24, weight: .bold, design: .rounded))
            
            VStack(alignment: .leading, spacing: 24) {
                Text("If rent is due before payday, what risk happens?")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                
                VStack(spacing: 12) {
                    QuizOptionView(title: "A. You earn less money", isSelected: selectedQuizOption == 0) {
                        selectedQuizOption = 0
                    }
                    QuizOptionView(title: "B. A cashflow gap", isSelected: selectedQuizOption == 1) {
                        selectedQuizOption = 1
                    }
                    QuizOptionView(title: "C. Spending disappears", isSelected: selectedQuizOption == 2) {
                        selectedQuizOption = 2
                    }
                }
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            
            if showQuizFeedback {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: selectedQuizOption == 1 ? "checkmark.circle.fill" : "xmark.circle.fill")
                        Text(selectedQuizOption == 1 ? "Correct!" : "Try again")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundStyle(selectedQuizOption == 1 ? AppTheme.positive : AppTheme.negative)
                    
                    Text("A cashflow gap happens when expenses happen before income.")
                        .font(.system(size: 15, weight: .medium))
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .transition(.scale.combined(with: .opacity))
            }
            
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
                    .frame(width: 250, height: 250)
                
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(AppTheme.cardTop)
                    .lessonBounceEffect()
            }
            
            VStack(spacing: 16) {
                Text("Level Complete!")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                
                Text("You mapped your money timing.")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            
            VStack(spacing: 12) {
                RewardRow(icon: "star.fill", title: "+50 XP", color: .orange)
                RewardRow(icon: "medal.fill", title: "Badge: Cashflow Detective", color: AppTheme.cardTop)
            }
            .padding(24)
            .background(AppTheme.white)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            
            Spacer()
            
            Button {
                store.completeLesson("cashflow-detective", earnedXP: 50)
                dismiss()
            } label: {
                Text("Finish Level 1")
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
        .padding(.horizontal, 24)
    }
}

// MARK: - Helper Views

struct TimelineItem: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(Circle())
            
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

struct TimelineLine: View {
    var body: some View {
        Rectangle()
            .fill(AppTheme.outline)
            .frame(height: 2)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 20)
    }
}

struct TimelineRow: View {
    let date: String
    let title: String
    let amount: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(date)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 40)
            
            Text(title)
                .font(.system(size: 16, weight: .semibold))
            
            Spacer()
            
            Text(amount)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(color)
        }
        .padding(.vertical, 8)
    }
}


#Preview {
    CashflowDetectiveLessonView()
        .environmentObject(BudgetPlannerStore.preview)
}
