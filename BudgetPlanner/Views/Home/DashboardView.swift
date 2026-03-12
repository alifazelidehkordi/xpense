import AudioToolbox
import PhotosUI
import SwiftUI
import UIKit

private enum AppTab: Hashable {
    case home
    case logs
    case analytics
    case leaderboard
    case learn
}

private enum HomeDestination: String, Identifiable {
    case expense
    case income
    case profile

    var id: String { rawValue }
}

private enum LogsDestination: String, Identifiable {
    case category
    case period

    var id: String { rawValue }
}

private enum LeaderboardDestination: String, Identifiable {
    case chat

    var id: String { rawValue }
}

private enum LogPeriod: String, CaseIterable, Identifiable {
    case last7Days
    case last30Days
    case thisMonth
    case allTime

    var id: String { rawValue }

    var title: String {
        switch self {
        case .last7Days:
            return "Last 7 Days"
        case .last30Days:
            return "Last 30 Days"
        case .thisMonth:
            return "This Month"
        case .allTime:
            return "All Time"
        }
    }

    var subtitle: String {
        switch self {
        case .last7Days:
            return "Show the latest week of activity."
        case .last30Days:
            return "Show the latest 30 days of activity."
        case .thisMonth:
            return "Show entries from the current month."
        case .allTime:
            return "Show every saved log."
        }
    }
}

private enum AnalyticsChartMode: String, CaseIterable, Identifiable {
    case signals
    case daily

    var id: String { rawValue }

    var title: String {
        switch self {
        case .signals:
            return "Signals"
        case .daily:
            return "Daily"
        }
    }
}

private struct AnalyticsOverviewBubble: Identifiable {
    let id: String
    let title: String
    let iconName: String
    let amount: Double
    let share: Double
    let color: Color
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeRootView(
                openLearn: { selectedTab = .learn },
                openLogs: { selectedTab = .logs }
            )
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(AppTab.home)

            LogsRootView()
                .tabItem {
                    Label("Logs", systemImage: "list.bullet.rectangle.fill")
                }
                .tag(AppTab.logs)

            AnalyticsRootView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.xaxis")
                }
                .tag(AppTab.analytics)

            LeaderboardRootView()
                .tabItem {
                    Label("Leaderboard", systemImage: "trophy.fill")
                }
                .tag(AppTab.leaderboard)

            LearnRootView()
                .tabItem {
                    Label("Learn", systemImage: "brain.head.profile")
                }
                .tag(AppTab.learn)
        }
        .tint(AppTheme.cardTop)
    }
}

private struct HomeRootView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @State private var activeDestination: HomeDestination?

    let openLearn: () -> Void
    let openLogs: () -> Void

    var body: some View {
        NavigationStack {
            HomeView(
                openExpense: { activeDestination = .expense },
                openIncome: { activeDestination = .income },
                openLearn: openLearn,
                openLogs: openLogs,
                openProfile: { activeDestination = .profile }
            )
            .environmentObject(store)
            .navigationDestination(item: $activeDestination) { destination in
                switch destination {
                case .expense:
                    ExpenseEntryView()
                        .environmentObject(store)
                case .income:
                    IncomeEntryView()
                        .environmentObject(store)
                case .profile:
                    ProfileView()
                        .environmentObject(store)
                }
            }
            .toolbar(activeDestination == nil ? .hidden : .visible, for: .navigationBar)
        }
    }
}

private struct LogsRootView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @State private var activeDestination: LogsDestination?
    @State private var selectedCategory: ExpenseCategory?
    @State private var selectedPeriod: LogPeriod = .last7Days

    var body: some View {
        NavigationStack {
            LogsView(
                selectedCategory: $selectedCategory,
                selectedPeriod: $selectedPeriod,
                openCategoryPicker: { activeDestination = .category },
                openPeriodPicker: { activeDestination = .period }
            )
            .environmentObject(store)
            .navigationDestination(item: $activeDestination) { destination in
                switch destination {
                case .category:
                    LogCategoryPickerView(selectedCategory: $selectedCategory) {
                        activeDestination = nil
                    }
                    .environmentObject(store)
                case .period:
                    LogPeriodPickerView(selectedPeriod: $selectedPeriod) {
                        activeDestination = nil
                    }
                }
            }
            .toolbar(activeDestination == nil ? .hidden : .visible, for: .navigationBar)
        }
    }
}

private struct AnalyticsRootView: View {
    @EnvironmentObject private var store: BudgetPlannerStore

    var body: some View {
        NavigationStack {
            AnalyticsView()
                .environmentObject(store)
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct LeaderboardRootView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @State private var activeDestination: LeaderboardDestination?

    var body: some View {
        NavigationStack {
            LeaderboardTabView(openChat: { activeDestination = .chat })
                .environmentObject(store)
                .navigationDestination(item: $activeDestination) { destination in
                    switch destination {
                    case .chat:
                        LeaderboardChatView()
                            .environmentObject(store)
                    }
                }
                .toolbar(activeDestination == nil ? .hidden : .visible, for: .navigationBar)
        }
    }
}

private struct LearnRootView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @State private var lessonPath: [LearnLessonState] = []

    var body: some View {
        NavigationStack(path: $lessonPath) {
            LearnView(openLesson: { lessonPath.append($0) })
                .environmentObject(store)
                .navigationDestination(for: LearnLessonState.self) { lessonState in
                    richLessonView(for: lessonState)
                        .environmentObject(store)
                }
                .toolbar(lessonPath.isEmpty ? .hidden : .visible, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func richLessonView(for lessonState: LearnLessonState) -> some View {
        switch lessonState.id {
        case "cashflow-detective":
            CashflowDetectiveLessonView()
        case "expense-tracking":
            ExpenseTrackingLessonView()
        case "realistic-budget":
            RealisticBudgetLessonView()
        case "fixed-costs":
            FixedCostsLessonView()
        case "goal-based-saving":
            GoalBasedSavingLessonView()
        case "emergency-buffer":
            EmergencyBufferLessonView()
        case "trade-offs":
            OpportunityCostLessonView()
        case "impulse-spending":
            ImpulseSpendingLessonView()
        case "debt-basics":
            DebtBasicsLessonView()
        default:
            LearnLessonDetailView(
                lessonID: lessonState.id,
                openLesson: { lessonPath.append($0) }
            )
        }
    }
}

struct HomeView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @Environment(\.colorScheme) private var colorScheme
    @State private var showBudgetEditor = false

    let openExpense: () -> Void
    let openIncome: () -> Void
    let openLearn: () -> Void
    let openLogs: () -> Void
    let openProfile: () -> Void

    private var displayHeaderName: String {
        let firstName = store.profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        return firstName.isEmpty ? store.displayName : firstName
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                header
                budgetCard
                actionButtons
                recentExpensesSection
                continueLearningSection
                activeQuestsSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 120)
        }
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        AppTheme.background,
                        AppTheme.panel,
                        colorScheme == .dark ? AppTheme.deepPanel : AppTheme.lightLavender,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Circle()
                    .fill(colorScheme == .dark ? AppTheme.surface.opacity(0.32) : Color.white.opacity(0.44))
                    .frame(width: 280, height: 280)
                    .blur(radius: 36)
                    .offset(x: -130, y: 120)

                Circle()
                    .fill(AppTheme.glowPurple.opacity(colorScheme == .dark ? 0.18 : 0.24))
                    .frame(width: 300, height: 300)
                    .blur(radius: 54)
                    .offset(x: 180, y: -110)
            }
        }
        .sheet(isPresented: $showBudgetEditor) {
            BudgetEditorSheet(isPresented: $showBudgetEditor)
                .environmentObject(store)
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(store.greeting)
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(displayHeaderName)
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
            }

            Spacer()

            Button(action: openProfile) {
                ProfileAvatarView(
                    imageData: store.profile.profileImageData,
                    initials: store.initials,
                    size: 74,
                    backgroundColors: [AppTheme.cardTop.opacity(0.92), AppTheme.cardBottom]
                )
            }
            .buttonStyle(.plain)
            .shadow(color: AppTheme.glowPurple.opacity(0.42), radius: 15, x: 0, y: 0)
        }
        .padding(.top, 4)
    }

    private var budgetCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Monthly Budget")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(CurrencyFormatter.string(from: store.remainingBudget))
                            .font(.system(size: 56, weight: .heavy, design: .rounded))
                            .minimumScaleFactor(0.55)
                            .lineLimit(1)
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("/ \(CurrencyFormatter.string(from: store.availableFunds))")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Menu {
                    Button("Change monthly budget", systemImage: "pencil") {
                        showBudgetEditor = true
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
            }

            BudgetProgressBar(progress: store.spentRatio)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Remaining")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(CurrencyFormatter.string(from: store.remainingBudget))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(store.remainingBudget >= 0 ? AppTheme.budgetPositive : AppTheme.negative)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Spent today")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(CurrencyFormatter.string(from: store.spentToday))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.negative)
                }
            }
        }
        .padding(24)
        .frostedGlassCard(cornerRadius: 30)
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            GelActionButton(
                title: "Expense",
                symbolName: TransactionType.expense.symbolName,
                gradientColors: [Color(hex: 0x8E52FF), Color(hex: 0x6028DF)],
                action: openExpense
            )

            GelActionButton(
                title: "Income",
                symbolName: TransactionType.income.symbolName,
                gradientColors: [Color(hex: 0xA168FF), Color(hex: 0x6C32E8)],
                action: openIncome
            )
        }
    }

    @ViewBuilder
    private var continueLearningSection: some View {
        if let lessonState = store.continueLearningLesson {
            Button(action: openLearn) {
                HomeSectionCard(title: "Continue Your Learning Streak") {
                    LearningContinueRow(
                        lesson: lessonState.lesson,
                        streakLabel: store.learnStreakDays > 0 ? "\(store.learnStreakDays) day streak" : "Start today's streak",
                        progress: Double(store.learnCompletionPercentage) / 100
                    )
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var recentExpensesSection: some View {
        HomeSectionCard(title: "Recent Expenses") {
            if store.recentExpenses.isEmpty {
                HomeSectionEmptyRow(
                    title: "No expenses yet",
                    subtitle: "Your latest expense entries will appear here.",
                    iconName: "tray"
                )
            } else {
                ForEach(Array(store.recentExpenses.prefix(2))) { transaction in
                    HomeExpenseRow(transaction: transaction)
                }

                if store.recentExpenses.count > 2 {
                    HStack {
                        Spacer()

                        Button(action: openLogs) {
                            Text("view all")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 2)
                }
            }
        }
    }

    @ViewBuilder
    private var activeQuestsSection: some View {
        if !store.homeQuestStates.isEmpty {
            HomeSectionCard(title: "Active Quests") {
                ForEach(store.homeQuestStates) { quest in
                    HomeQuestRow(quest: quest)
                }
            }
        }
    }

}

private struct BudgetEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore

    @Binding var isPresented: Bool

    @State private var budgetDraft = ""
    @State private var validationMessage: String?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Adjust Monthly Budget")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Update the base monthly budget used on Home, Analytics, and alerts.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(3)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Monthly budget")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    TextField("0,00", text: $budgetDraft)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(AppTheme.white.opacity(0.96))
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(AppTheme.outline, lineWidth: 1)
                        )

                    Text("Current: \(CurrencyFormatter.string(from: store.profile.monthlyBudget))")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    if let validationMessage {
                        Text(validationMessage)
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.negative)
                    }
                }

                Spacer(minLength: 0)

                Button(action: saveBudget) {
                    Text("Save budget")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.cardTop, AppTheme.darkPurple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .padding(.bottom, 24)
            .background(AppTheme.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismissSheet()
                    }
                }
            }
            .onAppear {
                budgetDraft = CurrencyFormatter.inputString(from: store.profile.monthlyBudget)
            }
        }
        .presentationDetents([.height(340)])
        .presentationDragIndicator(.visible)
    }

    private func saveBudget() {
        guard store.updateMonthlyBudget(from: budgetDraft) else {
            validationMessage = "Enter a valid amount greater than zero."
            return
        }

        validationMessage = nil
        dismissSheet()
    }

    private func dismissSheet() {
        isPresented = false
        dismiss()
    }
}

private struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore

    @State private var showQRAlert = false
    @State private var selectedProfilePhoto: PhotosPickerItem?
    @State private var isLoadingProfilePhoto = false

    private let badgeColumns = Array(repeating: GridItem(.flexible(), spacing: 10), count: 5)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                profileHero
                statsRow
                badgesSection
                activeQuestsSection
                completedQuestsSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 32)
        }
        .background(AppTheme.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showQRAlert = true
                } label: {
                    Label("Share your QR", systemImage: "qrcode")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppTheme.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .alert("QR sharing coming soon", isPresented: $showQRAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Later this will let friends connect and compare XP on the leaderboard.")
        }
        .task(id: selectedProfilePhoto) {
            guard let selectedProfilePhoto else { return }
            isLoadingProfilePhoto = true
            defer { isLoadingProfilePhoto = false }

            if let data = try? await selectedProfilePhoto.loadTransferable(type: Data.self) {
                store.updateProfilePhoto(with: data)
            }
        }
    }

    private var profileHero: some View {
        let imageData = store.profile.profileImageData
        let initials = store.initials

        return VStack(spacing: 14) {
            PhotosPicker(selection: $selectedProfilePhoto, matching: .images, photoLibrary: .shared()) {
                ZStack(alignment: .bottomTrailing) {
                    ProfileAvatarView(
                        imageData: imageData,
                        initials: initials,
                        size: 116,
                        backgroundColors: [AppTheme.cardTop.opacity(0.92), AppTheme.cardBottom]
                    )

                    HStack(spacing: 6) {
                        Image(systemName: isLoadingProfilePhoto ? "hourglass" : "camera.fill")
                        Text(isLoadingProfilePhoto ? "Updating" : "Change")
                    }
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(AppTheme.cardTop)
                    .clipShape(Capsule())
                    .offset(x: 8, y: 8)
                }
            }
            .buttonStyle(.plain)

            VStack(spacing: 4) {
                Text(store.fullName.isEmpty ? store.displayName : store.fullName)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)

                Text(store.profileRankTitle)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Text("Level \(store.profileLevel)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.cardTop)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .frame(maxWidth: .infinity)
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            ProfileStatCard(
                iconName: "flame.fill",
                valueText: "\(store.learnStreakDays)",
                title: "Day Streak"
            )

            ProfileStatCard(
                iconName: "trophy.fill",
                valueText: "\(store.completedQuestCount)",
                title: "Completed"
            )

            ProfileStatCard(
                iconName: "sparkles",
                valueText: "\(store.activeQuestCount)",
                title: "Active Quests"
            )
        }
    }

    private var badgesSection: some View {
        HomeSectionCard(title: "Badges") {
            LazyVGrid(columns: badgeColumns, spacing: 10) {
                ForEach(store.badgeStates) { badge in
                    BadgePill(badge: badge)
                }
            }
        }
    }

    private var activeQuestsSection: some View {
        HomeSectionCard(title: "Your Quests") {
            HStack {
                Spacer()

                Text("+\(store.activeQuestXPAvailable) XP")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
            }

            ForEach(store.activeQuestStates) { quest in
                ProfileQuestRow(quest: quest, style: .active)
            }
        }
    }

    private var completedQuestsSection: some View {
        HomeSectionCard(title: "Completed") {
            if store.recentCompletedQuestStates.isEmpty {
                HomeSectionEmptyRow(
                    title: "No completed quests yet",
                    subtitle: "Finish an active quest and it will appear here."
                )
            } else {
                ForEach(Array(store.recentCompletedQuestStates.prefix(2))) { quest in
                    ProfileQuestRow(quest: quest, style: .completed)
                }
            }
        }
    }
}

private struct AnalyticsView: View {
    @EnvironmentObject private var store: BudgetPlannerStore

    @State private var selectedInsightID: String?
    @State private var selectedOverviewBubbleID: String?
    @State private var chartMode: AnalyticsChartMode = .signals

    private var insights: [AnalyticsInsight] {
        store.analyticsInsights
    }

    private var insightSignature: String {
        insights.map(\.id).joined(separator: "|")
    }

    private var selectedInsight: AnalyticsInsight? {
        if let selectedInsightID, let matchingInsight = insights.first(where: { $0.id == selectedInsightID }) {
            return matchingInsight
        }

        return insights.first
    }

    private var highlightedSignalID: String? {
        selectedInsight?.relatedSignalID
    }

    private var signalChartData: [AnalyticsSignalTrend] {
        Array(store.analyticsSignalTrends.prefix(5))
    }

    private var dailyChartData: [DailyExpensePoint] {
        store.analyticsDailyExpensePoints
    }

    private var alertData: [AnalyticsAlertState] {
        store.analyticsAlerts
    }

    private var currentMonthSpent: Double {
        store.transactions
            .filter { transaction in
                transaction.type == .expense &&
                Calendar.current.isDate(transaction.date, equalTo: .now, toGranularity: .month)
            }
            .map(\.amount)
            .reduce(0, +)
    }

    private var currentMonthLabel: String {
        Date.now.formatted(.dateTime.month(.wide))
    }

    private var overviewBubbles: [AnalyticsOverviewBubble] {
        let currentMonthExpenses = store.transactions.filter { transaction in
            transaction.type == .expense &&
            Calendar.current.isDate(transaction.date, equalTo: .now, toGranularity: .month)
        }

        let total = currentMonthExpenses.map(\.amount).reduce(0, +)
        guard total > 0 else { return [] }

        struct BubbleAccumulator {
            var title: String
            var iconName: String
            var amount: Double
        }

        var grouped: [String: BubbleAccumulator] = [:]

        for transaction in currentMonthExpenses {
            let title = transaction.category?.name ?? fallbackOverviewTitle(for: transaction)
            let iconName = transaction.category?.iconName ?? "tray.full.fill"
            let key = title.lowercased()

            var accumulator = grouped[key] ?? BubbleAccumulator(title: title, iconName: iconName, amount: 0)
            accumulator.amount += transaction.amount
            grouped[key] = accumulator
        }

        var sorted = grouped.values.sorted { $0.amount > $1.amount }

        if sorted.count > 6 {
            let remainingAmount = sorted.dropFirst(5).map(\.amount).reduce(0, +)
            sorted = Array(sorted.prefix(5))
            sorted.append(BubbleAccumulator(title: "Other", iconName: "square.grid.2x2.fill", amount: remainingAmount))
        }

        let palette = [
            AppTheme.chartLilac,
            AppTheme.chartMint,
            AppTheme.chartSky,
            AppTheme.chartBlush,
            AppTheme.chartButter,
            AppTheme.chartFog
        ]

        return sorted.enumerated().map { index, bubble in
            AnalyticsOverviewBubble(
                id: "overview-\(bubble.title.lowercased())",
                title: bubble.title,
                iconName: bubble.iconName,
                amount: bubble.amount,
                share: bubble.amount / total,
                color: palette[index % palette.count]
            )
        }
    }

    private var selectedOverviewBubble: AnalyticsOverviewBubble? {
        if let selectedOverviewBubbleID,
           let matchingBubble = overviewBubbles.first(where: { $0.id == selectedOverviewBubbleID }) {
            return matchingBubble
        }

        return overviewBubbles.first
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                analyticsHeader
                overviewSection

                if insights.isEmpty {
                    EmptyHomeCard(
                        title: "Analytics will appear after a few expenses",
                        subtitle: "Add expenses across this week and next week. The app will compare the same days week over week and surface up to four insights."
                    )
                } else {
                    alertsSection
                    insightsSection
                    chartModePicker
                    chartSection

                    if let selectedInsight {
                        AnalyticsInsightDetailCard(
                            insight: selectedInsight,
                            signal: store.analyticsSignal(for: selectedInsight),
                            comparisonDayCount: store.comparisonDayCount
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 36)
        }
        .background(AppTheme.background)
        .onAppear(perform: syncInsightSelection)
        .onChange(of: insightSignature) { _, _ in
            syncInsightSelection()
        }
        .onChange(of: selectedInsightID) { _, _ in
            syncChartModeForSelectedInsight()
        }
        .onChange(of: overviewBubbles.map(\.id).joined(separator: "|")) { _, _ in
            if selectedOverviewBubble == nil {
                selectedOverviewBubbleID = overviewBubbles.first?.id
            }
        }
    }

    private var analyticsHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Analytics")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.top, 8)
    }

    private var overviewSection: some View {
        AnalyticsOverviewCard(
            monthLabel: currentMonthLabel,
            totalSpent: currentMonthSpent,
            bubbles: overviewBubbles,
            selectedBubbleID: $selectedOverviewBubbleID
        )
    }

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Alerts")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            ForEach(alertData) { alert in
                AnalyticsAlertCard(alert: alert)
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Top 4 Insights")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            TabView(selection: $selectedInsightID) {
                ForEach(insights) { insight in
                    AnalyticsInsightCard(
                        insight: insight,
                        isSelected: selectedInsight?.id == insight.id
                    ) {
                        selectedInsightID = insight.id
                    }
                    .padding(.horizontal, 2)
                    .tag(insight.id as String?)
                }
            }
            .frame(height: 192)
            .tabViewStyle(.page(indexDisplayMode: .never))

            HStack(spacing: 8) {
                ForEach(insights) { insight in
                    Capsule()
                        .fill(selectedInsight?.id == insight.id ? AppTheme.cardTop : AppTheme.lightLavender)
                        .frame(width: selectedInsight?.id == insight.id ? 22 : 8, height: 8)
                        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: selectedInsight?.id)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var chartModePicker: some View {
        Picker("Chart Mode", selection: $chartMode) {
            ForEach(AnalyticsChartMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(6)
        .background(AppTheme.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var chartSection: some View {
        switch chartMode {
        case .signals:
            if signalChartData.isEmpty {
                EmptyHomeCard(
                    title: "No spending signals yet",
                    subtitle: "As soon as you add a few expenses, this comparison chart will show this week against last week."
                )
            } else {
                AnalyticsSignalChart(
                    signals: signalChartData,
                    highlightedSignalID: highlightedSignalID
                )
            }
        case .daily:
            if dailyChartData.isEmpty {
                EmptyHomeCard(
                    title: "No daily trend yet",
                    subtitle: "Log expenses on different days and this chart will show your weekly pace."
                )
            } else {
                AnalyticsDailyChart(points: dailyChartData)
            }
        }
    }

    private func syncInsightSelection() {
        if selectedInsight == nil {
            selectedInsightID = insights.first?.id
        }

        if selectedOverviewBubble == nil {
            selectedOverviewBubbleID = overviewBubbles.first?.id
        }

        syncChartModeForSelectedInsight()
    }

    private func syncChartModeForSelectedInsight() {
        guard let selectedInsight else { return }
        chartMode = selectedInsight.relatedSignalID == nil ? .daily : .signals
    }

    private func fallbackOverviewTitle(for transaction: Transaction) -> String {
        let trimmedNote = transaction.note.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedNote.isEmpty {
            return "Other"
        }

        return trimmedNote
    }
}

private struct LearnView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @Environment(\.colorScheme) private var colorScheme

    @State private var animatedActiveLevelIndex = 0
    @State private var professorHopOffset: CGFloat = 0
    @State private var professorTiltDegrees: Double = 0
    @State private var popupState: LearnTilePopupState?

    let openLesson: (LearnLessonState) -> Void
    private let mapAspectRatio: CGFloat = 3306.0 / 1184.0
    private let mapReferenceSize = CGSize(width: 1184, height: 3306)
    private let levelNodeDiameter: CGFloat = 52
    private let mapLevelAnchorCenters: [CGPoint] = [
        CGPoint(x: 594, y: 3192),
        CGPoint(x: 595, y: 2938),
        CGPoint(x: 781, y: 2784),
        CGPoint(x: 598, y: 2642),
        CGPoint(x: 378, y: 2496),
        CGPoint(x: 591, y: 2326),
        CGPoint(x: 815, y: 1989),
        CGPoint(x: 593, y: 1798),
        CGPoint(x: 597, y: 1473),
        CGPoint(x: 597, y: 1215),
        CGPoint(x: 591, y: 945),
        CGPoint(x: 590, y: 703),
        CGPoint(x: 301, y: 461),
        CGPoint(x: 590, y: 461),
    ]

    private var linearLessons: [LearnLessonState] {
        store.learnTopicStates.flatMap(\.lessons)
    }

    private var contiguousCompletedCount: Int {
        linearLessons.prefix { $0.isCompleted }.count
    }

    private var activeLevelIndex: Int {
        guard !linearLessons.isEmpty else { return 0 }
        if let firstUnlockedPendingIndex = linearLessons.firstIndex(where: { $0.isUnlocked && !$0.isCompleted }) {
            return firstUnlockedPendingIndex
        }
        if let lastCompletedIndex = linearLessons.lastIndex(where: { $0.isCompleted }) {
            return lastCompletedIndex
        }
        return min(contiguousCompletedCount, linearLessons.count - 1)
    }

    private var levelNodes: [LevelMapNode] {
        linearLessons.enumerated().map { index, lessonState in
            let status: LevelNodeStatus
            if lessonState.isCompleted {
                status = .completed
            } else if index == activeLevelIndex {
                status = .active
            } else {
                status = .locked
            }

            return LevelMapNode(
                id: lessonState.id,
                index: index,
                lessonState: lessonState,
                status: status,
                normalizedPosition: levelPosition(for: index, total: linearLessons.count)
            )
        }
    }

    private var knowledgeProgress: Double {
        min(max(Double(store.learnCompletionPercentage) / 100, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = max(proxy.safeAreaInsets.bottom, 12)
            let mapHeight = proxy.size.width * mapAspectRatio

            ZStack(alignment: .bottom) {
                ScrollViewReader { scrollProxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        ZStack(alignment: .top) {
                            mapBackground(width: proxy.size.width, height: mapHeight)

                            LevelMapView(
                                nodes: levelNodes,
                                professorHopOffset: professorHopOffset,
                                professorTiltDegrees: professorTiltDegrees,
                                onTap: showPopup(for:),
                                levelNodeDiameter: levelNodeDiameter
                            )
                            .frame(width: proxy.size.width, height: mapHeight)
                        }
                        .frame(width: proxy.size.width, height: mapHeight)
                        .padding(.top, safeTop + 86)
                        .padding(.bottom, 96 + safeBottom)
                    }
                    .onAppear {
                        scrollToActiveLevel(using: scrollProxy, animated: false)
                    }
                    .onChange(of: animatedActiveLevelIndex) { _, _ in
                        scrollToActiveLevel(using: scrollProxy, animated: true)
                    }
                }

                VStack(spacing: 0) {
                    headerHUD
                        .padding(.horizontal, 16)
                        .padding(.top, safeTop + 6)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                if let popupState {
                    LearnTileActionPopup(
                        popupState: popupState,
                        onClose: { self.popupState = nil },
                        onPrimaryAction: {
                            if let lessonState = popupState.lessonState {
                                openLesson(lessonState)
                            }
                            self.popupState = nil
                        }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 74 + safeBottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        AppTheme.background,
                        AppTheme.panel,
                        AppTheme.lightLavender,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            )
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(.spring(response: 0.36, dampingFraction: 0.86), value: popupState?.id)
        .onAppear {
            animatedActiveLevelIndex = activeLevelIndex
        }
        .onChange(of: store.completedLessonCount) { _, _ in
            animateProfessorHopToActiveLevel()
        }
    }

    private var headerHUD: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Knowledge")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.white.opacity(0.72))
                        .frame(height: 10)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0xA854F7), Color(hex: 0x8A58F5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: CGFloat(92 * knowledgeProgress), height: 10)
                }
                .frame(width: 92, height: 10)

                Text("\(store.learnCompletionPercentage)%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(AppTheme.white.opacity(0.45))
                .frame(width: 64, height: 64)
                .overlay(
                    ProfileAvatarView(
                        imageData: store.profile.profileImageData,
                        initials: store.initials,
                        size: 52,
                        backgroundColors: [AppTheme.cardTop.opacity(0.92), AppTheme.cardBottom]
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.glassEdge, lineWidth: 1)
                )
                .shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 6)

            VStack(alignment: .trailing, spacing: 8) {
                Text(store.profileRankTitle)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 6) {
                    Image(systemName: "star.circle.fill")
                        .foregroundStyle(AppTheme.glowPurple)
                    Text("L\(store.profileLevel) • \(compactNumber(store.totalXP)) XP")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(AppTheme.white.opacity(0.72))
                )
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(AppTheme.surface.opacity(colorScheme == .dark ? 0.58 : 0.62))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.glassEdge, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow.opacity(0.65), radius: 14, x: 0, y: 10)
    }

    private func mapBackground(width: CGFloat, height: CGFloat) -> some View {
        Image("MapBackground")
            .resizable()
            .frame(width: width, height: height)
            .clipped()
            .overlay(
                AppTheme.background
                    .opacity(colorScheme == .dark ? 0.42 : 0)
            )
            .overlay(
                LinearGradient(
                    colors: [AppTheme.white.opacity(0.12), Color.clear, Color.white.opacity(0.20)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
    }

    private func levelPosition(for index: Int, total: Int) -> CGPoint {
        let resolvedAnchors = resolvedLevelAnchors(for: total)

        guard let firstAnchor = resolvedAnchors.first else {
            return CGPoint(x: 0.5, y: 0.5)
        }

        let safeIndex = min(max(index, 0), resolvedAnchors.count - 1)
        return normalizedAnchorPosition(
            for: resolvedAnchors[safe: safeIndex] ?? firstAnchor
        )
    }

    private func resolvedLevelAnchors(for total: Int) -> [CGPoint] {
        guard total > 0 else { return [] }

        if total <= mapLevelAnchorCenters.count {
            return Array(mapLevelAnchorCenters.prefix(total))
        }

        guard mapLevelAnchorCenters.count > 1 else {
            return Array(repeating: mapLevelAnchorCenters.first ?? .zero, count: total)
        }

        return (0..<total).map { index in
            let progress = CGFloat(index) / CGFloat(max(total - 1, 1))
            let scaled = progress * CGFloat(mapLevelAnchorCenters.count - 1)
            let lowerIndex = Int(floor(scaled))
            let upperIndex = min(lowerIndex + 1, mapLevelAnchorCenters.count - 1)
            let segmentProgress = scaled - CGFloat(lowerIndex)
            let lowerPoint = mapLevelAnchorCenters[lowerIndex]
            let upperPoint = mapLevelAnchorCenters[upperIndex]

            return CGPoint(
                x: lowerPoint.x + (upperPoint.x - lowerPoint.x) * segmentProgress,
                y: lowerPoint.y + (upperPoint.y - lowerPoint.y) * segmentProgress
            )
        }
    }

    private func normalizedAnchorPosition(for point: CGPoint) -> CGPoint {
        CGPoint(
            x: point.x / mapReferenceSize.width,
            y: point.y / mapReferenceSize.height
        )
    }

    private func scrollToActiveLevel(using scrollProxy: ScrollViewProxy, animated: Bool) {
        guard let targetID = levelNodes[safe: animatedActiveLevelIndex]?.id else { return }
        let action = { scrollProxy.scrollTo(targetID, anchor: .center) }
        if animated {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                action()
            }
        } else {
            action()
        }
    }

    private func animateProfessorHopToActiveLevel() {
        guard !levelNodes.isEmpty else { return }
        let targetIndex = activeLevelIndex

        guard targetIndex != animatedActiveLevelIndex else {
            return
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            animatedActiveLevelIndex = targetIndex
            professorHopOffset = -14
            professorTiltDegrees = 10
        }

        Task {
            try? await Task.sleep(nanoseconds: 240_000_000)
            await MainActor.run {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    professorHopOffset = 0
                    professorTiltDegrees = 0
                }
            }
        }
    }

    private func showPopup(for node: LevelMapNode) {
        switch node.status {
        case .active:
            popupState = LearnTilePopupState(
                title: "Level \(node.index + 1)",
                lessonTitle: node.lessonState.lesson.title,
                message: "This level is active. Complete it to unlock Level \(node.index + 2).",
                economyText: "Reward: +\(node.lessonState.lesson.xp) XP",
                actionTitle: "Start Lesson",
                lessonState: node.lessonState
            )
        case .locked:
            popupState = LearnTilePopupState(
                title: "Level \(node.index + 1)",
                lessonTitle: node.lessonState.lesson.title,
                message: "This level is locked. Complete Level \(max(node.index, 1)) to unlock it.",
                economyText: "Reward waiting: +\(node.lessonState.lesson.xp) XP",
                actionTitle: nil,
                lessonState: nil
            )
        case .completed:
            popupState = LearnTilePopupState(
                title: "Level \(node.index + 1)",
                lessonTitle: node.lessonState.lesson.title,
                message: "Completed. You can replay this lesson anytime.",
                economyText: "XP earned: +\(node.lessonState.lesson.xp)",
                actionTitle: "Review Lesson",
                lessonState: node.lessonState
            )
        }
    }

    private func compactNumber(_ value: Int) -> String {
        if value >= 1_000 {
            let scaled = Double(value) / 1_000
            let text = String(format: scaled >= 10 ? "%.0fK" : "%.1fK", scaled)
            return text.replacingOccurrences(of: ".0K", with: "K")
        }
        return "\(value)"
    }
}

private struct LevelMapNode: Identifiable {
    let id: String
    let index: Int
    let lessonState: LearnLessonState
    let status: LevelNodeStatus
    let normalizedPosition: CGPoint
}

private enum LevelNodeStatus {
    case locked
    case active
    case completed
}

private struct LevelMapView: View {
    @EnvironmentObject private var store: BudgetPlannerStore

    let nodes: [LevelMapNode]
    let professorHopOffset: CGFloat
    let professorTiltDegrees: Double
    let onTap: (LevelMapNode) -> Void
    let levelNodeDiameter: CGFloat

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(nodes) { node in
                    Button {
                        onTap(node)
                    } label: {
                        ZStack(alignment: .top) {
                            LevelNodeIconView(status: node.status)
                                .frame(width: levelNodeDiameter, height: levelNodeDiameter)
                                .shadow(
                                    color: node.status == .active
                                        ? Color(hex: 0x8A58F5).opacity(0.45) : .clear,
                                    radius: 10,
                                    x: 0,
                                    y: 3
                                )
                                .zIndex(1)

                            if node.status == .active {
                                ProfileAvatarView(
                                    imageData: store.profile.profileImageData,
                                    initials: store.initials,
                                    size: 38,
                                    backgroundColors: [AppTheme.cardTop.opacity(0.92), AppTheme.cardBottom]
                                )
                                    .offset(y: -26 + professorHopOffset)
                                    .rotation3DEffect(
                                        .degrees(professorTiltDegrees),
                                        axis: (x: 1, y: 0, z: 0),
                                        perspective: 0.55
                                    )
                                    .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 10)
                                    .zIndex(2)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: node.normalizedPosition.x * proxy.size.width,
                        y: node.normalizedPosition.y * proxy.size.height
                    )
                    .id(node.id)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.82),
                        value: node.status
                    )
                }
            }
        }
    }
}

private struct LevelNodeIconView: View {
    let status: LevelNodeStatus

    var body: some View {
        Image(assetName)
            .resizable()
            .scaledToFit()
    }

    private var assetName: String {
        switch status {
        case .locked:
            return "LevelLocked"
        case .active:
            return "LevelActive"
        case .completed:
            return "LevelCompleted"
        }
    }
}

private struct LearnTilePopupState: Identifiable {
    let id = UUID()
    let title: String
    let lessonTitle: String
    let message: String
    let economyText: String
    let actionTitle: String?
    let lessonState: LearnLessonState?
}

private struct LearnTileActionPopup: View {
    @Environment(\.colorScheme) private var colorScheme

    let popupState: LearnTilePopupState
    let onClose: () -> Void
    let onPrimaryAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(popupState.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(width: 34, height: 34)
                        .background(AppTheme.white.opacity(colorScheme == .dark ? 0.28 : 0.72))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            Text(popupState.lessonTitle)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.gold)

            Text(popupState.message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(2)

            Text(popupState.economyText)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.positive)

            if let actionTitle = popupState.actionTitle {
                Button(actionTitle, action: onPrimaryAction)
                    .buttonStyle(.plain)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.cardTop, AppTheme.gelVioletBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .shadow(color: AppTheme.shadow, radius: 10, x: 0, y: 6)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.surface.opacity(colorScheme == .dark ? 0.92 : 0.88))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(AppTheme.glassEdge, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow.opacity(colorScheme == .dark ? 0.48 : 0.18), radius: 18, x: 0, y: 10)
    }
}

extension Collection {
    fileprivate subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private struct LearnBlueprintSectionCard<Content: View>: View {
    let indexTitle: String
    let title: String
    let content: Content

    init(indexTitle: String, title: String, @ViewBuilder content: () -> Content) {
        self.indexTitle = indexTitle
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("\(indexTitle)️⃣")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)

                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
            }

            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfaceStrong)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }
}

private struct LearnTreeBlock: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .monospaced))
            .foregroundStyle(AppTheme.textPrimary)
            .lineSpacing(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct LearnTopicModuleCard: View {
    let topicState: LearnTopicState
    let isExpanded: Bool
    let openLesson: (LearnLessonState) -> Void
    let toggleExpand: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: toggleExpand) {
                HStack(spacing: 12) {
                    Image(
                        systemName: topicState.isUnlocked ? topicState.topic.iconName : "lock.fill"
                    )
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(
                        topicState.isUnlocked ? AppTheme.cardTop : AppTheme.textSecondary
                    )
                    .frame(width: 32, height: 32)
                    .background(AppTheme.surfaceSoft)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(topicState.topic.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                        Text(topicState.topic.subtitle)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(2)
                    }

                    Spacer()

                    Text("\(topicState.completedLessons)/\(topicState.totalLessons)")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!topicState.isUnlocked)
            .opacity(topicState.isUnlocked ? 1 : 0.72)

            if isExpanded && topicState.isUnlocked {
                VStack(spacing: 8) {
                    ForEach(topicState.lessons) { lessonState in
                        LearnLessonActionRow(lessonState: lessonState) {
                            openLesson(lessonState)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }
}

private struct LearnLessonActionRow: View {
    let lessonState: LearnLessonState
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(lessonState.lesson.title)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(lessonState.lesson.subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Text("+\(lessonState.lesson.xp) XP")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.gold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(AppTheme.cardBottom.opacity(0.35))
                    .clipShape(Capsule())

                Text(statusLabel)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(statusForeground)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(statusBackground)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.surfaceSoft)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!lessonState.isUnlocked)
    }

    private var statusLabel: String {
        if lessonState.isCompleted { return "Done" }
        if lessonState.isUnlocked { return "Start" }
        return "Locked"
    }

    private var statusBackground: Color {
        if lessonState.isCompleted { return AppTheme.successSoft }
        if lessonState.isUnlocked { return AppTheme.cardTop }
        return AppTheme.white.opacity(0.4)
    }

    private var statusForeground: Color {
        if lessonState.isCompleted { return AppTheme.positive }
        if lessonState.isUnlocked { return .white }
        return AppTheme.textSecondary
    }
}

private struct LearnContinueBlueprintRow: View {
    let lessonState: LearnLessonState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(lessonState.lesson.title)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(lessonState.lesson.subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(AppTheme.cardTop)
            }
            .padding(14)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct LearnProgressCard: View {
    let completedLessons: Int
    let totalLessons: Int
    let completionPercentage: Int
    let totalXP: Int
    let dailyGoalText: String
    let streakDays: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "book.pages.fill")
                            .foregroundStyle(AppTheme.gold)

                        Text("Your Progress")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.cardTop)
                    }

                    Text("\(completedLessons) of \(totalLessons) lessons")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    HStack(spacing: 6) {
                        Image(systemName: "trophy")
                            .foregroundStyle(AppTheme.gold)
                            .symbolEffect(.bounce, value: totalXP)

                        Text("\(completionPercentage)%")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.gold)
                            .contentTransition(.numericText())
                    }

                    Text("\(totalXP) XP")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .contentTransition(.numericText())
                }
            }

            LearnProgressBar(
                progress: totalLessons == 0 ? 0 : Double(completedLessons) / Double(totalLessons))

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Goal")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.cardTop)

                    Text(
                        streakDays > 0
                            ? "Streak: \(streakDays) day\(streakDays == 1 ? "" : "s")"
                            : "Complete 1 lesson today to keep the streak!"
                    )
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
                }

                Spacer()

                Text(dailyGoalText)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.cardBottom.opacity(0.34))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(18)
        .background(AppTheme.surfaceStrong)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: totalXP)
    }
}

private struct LearnTopicCard: View {
    let topicState: LearnTopicState
    let isExpanded: Bool
    let openLesson: (LearnLessonState) -> Void
    let toggleExpand: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: toggleExpand) {
                HStack(spacing: 14) {
                    Image(
                        systemName: topicState.isUnlocked ? topicState.topic.iconName : "lock.fill"
                    )
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(topicState.isUnlocked ? AppTheme.gold : AppTheme.textSecondary)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text(topicState.topic.title)
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text(topicState.topic.subtitle)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()

                    Image(
                        systemName: topicState.isUnlocked
                            ? (isExpanded ? "chevron.up" : "play.fill") : "lock.fill"
                    )
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                }
            }
            .buttonStyle(.plain)

            LearnProgressBar(progress: topicState.progress)

            if isExpanded && topicState.isUnlocked {
                VStack(spacing: 10) {
                    ForEach(topicState.lessons) { lessonState in
                        LearnLessonRow(lessonState: lessonState) {
                            openLesson(lessonState)
                        }
                    }
                }
            }
        }
        .padding(18)
        .background(AppTheme.surfaceStrong)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(topicState.isUnlocked ? Color.clear : AppTheme.outline, lineWidth: 1)
        )
        .shadow(color: isExpanded ? AppTheme.shadow : .clear, radius: 18, x: 0, y: 10)
    }
}

private struct LearnLessonRow: View {
    let lessonState: LearnLessonState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: leadingIconName)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(leadingIconColor)
                    .frame(width: 28, height: 28)
                    .background(leadingBackgroundColor)
                    .clipShape(Circle())
                    .symbolEffect(.bounce, value: lessonState.isCompleted)

                VStack(alignment: .leading, spacing: 4) {
                    Text(lessonState.lesson.title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .multilineTextAlignment(.leading)

                    HStack(spacing: 4) {
                        Image(systemName: "star")
                            .font(.system(size: 11, weight: .bold))
                        Text("+\(lessonState.lesson.xp) XP")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(AppTheme.gold)
                }

                Spacer()

                Text(statusTitle)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(statusForeground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(statusBackground)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(rowBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .disabled(!lessonState.isUnlocked)
        .animation(.spring(response: 0.35, dampingFraction: 0.82), value: lessonState.isCompleted)
    }

    private var leadingIconName: String {
        if lessonState.isCompleted {
            return "checkmark.circle.fill"
        }

        return lessonState.isUnlocked ? lessonState.lesson.iconName : "lock.fill"
    }

    private var leadingIconColor: Color {
        if lessonState.isCompleted {
            return AppTheme.positive
        }

        return lessonState.isUnlocked ? AppTheme.cardTop : AppTheme.textSecondary
    }

    private var leadingBackgroundColor: Color {
        if lessonState.isCompleted {
            return AppTheme.successSoft
        }

        return lessonState.isUnlocked ? AppTheme.white.opacity(0.92) : AppTheme.white.opacity(0.5)
    }

    private var rowBackground: Color {
        if lessonState.isCompleted {
            return AppTheme.successSoft
        }

        return lessonState.isUnlocked ? AppTheme.cardBottom.opacity(0.55) : AppTheme.surfaceStrong
    }

    private var statusTitle: String {
        if lessonState.isCompleted {
            return "Done"
        }

        return lessonState.isUnlocked ? "Start" : "Locked"
    }

    private var statusBackground: Color {
        if lessonState.isCompleted {
            return AppTheme.positive
        }

        return lessonState.isUnlocked ? AppTheme.cardTop : AppTheme.white.opacity(0.45)
    }

    private var statusForeground: Color {
        lessonState.isUnlocked || lessonState.isCompleted ? .white : AppTheme.textSecondary
    }
}

private struct LearnLessonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore

    let lessonID: String
    let openLesson: (LearnLessonState) -> Void

    @State private var selectedPage = 0
    @State private var selectedOptionIndex: Int?
    @State private var feedbackMessage: String?
    @State private var answeredCorrectly = false
    @State private var shouldRetry = false
    @State private var showRewardPill = false

    private var lessonState: LearnLessonState? {
        store.learnLessonState(for: lessonID)
    }

    private var nextLessonState: LearnLessonState? {
        store.nextLearnLessonState(after: lessonID)
    }

    var body: some View {
        Group {
            if let lessonState {
                GeometryReader { geometry in
                    VStack(alignment: .leading, spacing: 10) {
                        lessonHeader(for: lessonState)
                        stageSwitcher

                        TabView(selection: $selectedPage) {
                            lessonPage(for: lessonState)
                                .tag(0)

                            quizPage(for: lessonState)
                                .tag(1)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 10)
                    .padding(.bottom, max(20, geometry.safeAreaInsets.bottom + 8))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
                .background(AppTheme.background)
                .overlay(alignment: .topTrailing) {
                    if showRewardPill {
                        XPRewardPill(xp: lessonState.lesson.xp)
                            .padding(.top, 12)
                            .padding(.trailing, 24)
                            .transition(.scale(scale: 0.85).combined(with: .opacity))
                    }
                }
                .navigationTitle("Lesson")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    syncViewState(for: lessonState)
                }
            } else {
                Text("Lesson not available.")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(AppTheme.background)
            }
        }
    }

    private var stageSwitcher: some View {
        HStack(spacing: 10) {
            LessonStageButton(
                title: "Lesson",
                symbolName: "doc.text.fill",
                isSelected: selectedPage == 0
            ) {
                withAnimation(.spring(duration: 0.3)) {
                    selectedPage = 0
                }
            }

            LessonStageButton(
                title: "Quiz",
                symbolName: "checklist",
                isSelected: selectedPage == 1
            ) {
                withAnimation(.spring(duration: 0.3)) {
                    selectedPage = 1
                }
            }
        }
    }

    private func lessonHeader(for lessonState: LearnLessonState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lessonState.lesson.title)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text(lessonState.lesson.subtitle)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(3)

            HStack(spacing: 10) {
                Label("+\(lessonState.lesson.xp) XP", systemImage: "star.fill")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(AppTheme.cardBottom.opacity(0.42))
                    .clipShape(Capsule())
                    .symbolEffect(.bounce, value: showRewardPill)

                if answeredCorrectly || lessonState.isCompleted {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppTheme.successSoft)
                        .clipShape(Capsule())
                }
            }
        }
    }

    private func lessonPage(for lessonState: LearnLessonState) -> some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Read the module")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Short lesson first, then a one-question quiz on the next page.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(3)
                    }

                    ForEach(Array(lessonState.lesson.contentSections.enumerated()), id: \.offset) {
                        index, section in
                        LessonSectionBlock(index: index + 1, text: section)
                    }

                    Spacer(minLength: 20)

                    Button {
                        LessonFeedback.selection()
                        withAnimation(.spring(duration: 0.3)) {
                            selectedPage = 1
                        }
                    } label: {
                        HStack {
                            Text("Continue to quiz")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 17)
                        .background(AppTheme.white.opacity(0.95))
                        .foregroundStyle(AppTheme.textPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(AppTheme.outline, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .frame(minHeight: max(geometry.size.height - 16, 0), alignment: .top)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func quizPage(for lessonState: LearnLessonState) -> some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Quick Check")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Get this question right to earn XP and unlock the next lesson.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(3)
                    }

                    Text(lessonState.lesson.quizQuestion)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    VStack(spacing: 10) {
                        ForEach(Array(lessonState.lesson.quizOptions.enumerated()), id: \.offset) {
                            index, option in
                            QuizOptionButton(
                                title: option,
                                isSelected: selectedOptionIndex == index,
                                isDisabled: answeredCorrectly || lessonState.isCompleted
                            ) {
                                LessonFeedback.selection()
                                selectedOptionIndex = index
                                feedbackMessage = nil
                            }
                        }
                    }

                    if let feedbackMessage {
                        Text(feedbackMessage)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(
                                answeredCorrectly ? AppTheme.positive : AppTheme.negative
                            )
                            .lineSpacing(3)
                    }

                    if answeredCorrectly || lessonState.isCompleted {
                        nextLessonCard
                    }

                    Spacer(minLength: 20)

                    Button {
                        handleQuizButtonTap(for: lessonState)
                    } label: {
                        Text(primaryButtonTitle)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(primaryButtonBackground)
                            .foregroundStyle(primaryButtonForeground)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .frame(minHeight: max(geometry.size.height - 16, 0), alignment: .top)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var nextLessonCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(nextLessonState == nil ? "Module complete" : "Next lesson unlocked")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.cardTop)

            Text(
                nextLessonState?.lesson.title
                    ?? "You finished the current learning path. Return to Learn to pick another topic."
            )
            .font(.system(size: 16, weight: .bold, design: .rounded))
            .foregroundStyle(AppTheme.textPrimary)

            if let nextLessonState {
                Text(nextLessonState.lesson.subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(3)
            }
        }
        .padding(16)
        .background(AppTheme.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }

    private var primaryButtonTitle: String {
        if answeredCorrectly || lessonState?.isCompleted == true {
            return nextLessonState == nil ? "Back to Learn" : "Next lesson"
        }

        return shouldRetry ? "Try again" : "Submit answer"
    }

    private var primaryButtonBackground: AnyShapeStyle {
        if answeredCorrectly || lessonState?.isCompleted == true {
            AnyShapeStyle(
                LinearGradient(
                    colors: [AppTheme.positive, AppTheme.positive.opacity(0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else if shouldRetry {
            AnyShapeStyle(
                LinearGradient(
                    colors: [AppTheme.negative, AppTheme.negative.opacity(0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        } else {
            AnyShapeStyle(
                LinearGradient(
                    colors: [AppTheme.cardTop, AppTheme.cardTop.opacity(0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private var primaryButtonForeground: Color {
        .white
    }

    private func handleQuizButtonTap(for lessonState: LearnLessonState) {
        if answeredCorrectly || lessonState.isCompleted {
            if let nextLessonState {
                LessonFeedback.selection()
                openLesson(nextLessonState)
            } else {
                LessonFeedback.selection()
                dismiss()
            }
            return
        }

        guard let selectedOptionIndex else {
            LessonFeedback.error()
            feedbackMessage = "Pick one answer before submitting."
            return
        }

        if store.submitLessonAnswer(
            lessonID: lessonState.id, selectedOptionIndex: selectedOptionIndex)
        {
            answeredCorrectly = true
            shouldRetry = false
            feedbackMessage = "Correct. You earned +\(lessonState.lesson.xp) XP."
            LessonFeedback.success()
            presentRewardPill()
        } else {
            answeredCorrectly = false
            shouldRetry = true
            feedbackMessage =
                "Not quite. Review the lesson or choose another option, then try again."
            LessonFeedback.error()
        }
    }

    private func syncViewState(for lessonState: LearnLessonState) {
        selectedPage = 0
        selectedOptionIndex = nil
        showRewardPill = false

        if lessonState.isCompleted {
            answeredCorrectly = true
            shouldRetry = false
            feedbackMessage =
                nextLessonState == nil
                ? "Lesson already completed. You can return to Learn."
                : "Lesson already completed. You can move to the next lesson."
        } else {
            answeredCorrectly = false
            shouldRetry = false
            feedbackMessage = nil
        }
    }

    private func presentRewardPill() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.72)) {
            showRewardPill = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            withAnimation(.easeOut(duration: 0.25)) {
                showRewardPill = false
            }
        }
    }
}

private struct LessonSectionBlock: View {
    let index: Int
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text("Part \(index)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.cardBottom.opacity(0.5))
                    .clipShape(Capsule())

                Rectangle()
                    .fill(AppTheme.outline)
                    .frame(height: 1)
            }

            Text(text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}

private struct QuizOptionButton: View {
    let title: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? AppTheme.cardTop : AppTheme.textSecondary)

                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(
                isSelected ? AppTheme.cardBottom.opacity(0.4) : AppTheme.background.opacity(0.75)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        isSelected ? AppTheme.cardTop : AppTheme.outline,
                        lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

private struct LessonStageButton: View {
    let title: String
    let symbolName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: symbolName)
                    .font(.system(size: 14, weight: .bold))

                Text(title)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .foregroundStyle(isSelected ? .white : AppTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [AppTheme.cardTop, AppTheme.cardTop.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    : AnyShapeStyle(AppTheme.white.opacity(0.9))
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.clear : AppTheme.outline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct XPRewardPill: View {
    let xp: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 14, weight: .bold))

            Text("+\(xp) XP")
                .font(.system(size: 14, weight: .bold, design: .rounded))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            LinearGradient(
                colors: [AppTheme.cardBottom, AppTheme.cardTop],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .foregroundStyle(.white)
        .clipShape(Capsule())
        .shadow(color: AppTheme.shadow, radius: 12, x: 0, y: 8)
    }
}

private enum LessonFeedback {
    private static let successSoundID: SystemSoundID = 1104

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            AudioServicesPlaySystemSound(successSoundID)
        }
    }

    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(.error)
    }
}

private struct LearnProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.white.opacity(0.9))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.barFill, AppTheme.cardTop],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * max(0, min(progress, 1)))
                    .animation(.spring(response: 0.45, dampingFraction: 0.82), value: progress)
            }
        }
        .frame(height: 8)
    }
}

private struct LogsView: View {
    @EnvironmentObject private var store: BudgetPlannerStore

    @Binding var selectedCategory: ExpenseCategory?
    @Binding var selectedPeriod: LogPeriod

    let openCategoryPicker: () -> Void
    let openPeriodPicker: () -> Void

    private var periodStartDate: Date? {
        let calendar = Calendar.current

        switch selectedPeriod {
        case .last7Days:
            return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -6, to: .now) ?? .now)
        case .last30Days:
            return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -29, to: .now) ?? .now)
        case .thisMonth:
            return calendar.date(from: calendar.dateComponents([.year, .month], from: .now))
        case .allTime:
            return nil
        }
    }

    private var filteredLogs: [Transaction] {
        store.transactions.filter { transaction in
            let matchesCategory: Bool
            if let selectedCategory {
                matchesCategory = transaction.type == .expense && transaction.category?.id == selectedCategory.id
            } else {
                matchesCategory = true
            }

            let matchesPeriod = periodStartDate.map { transaction.date >= $0 } ?? true
            return matchesCategory && matchesPeriod
        }
    }

    private var selectedCategoryWeekTotal: Double {
        guard let selectedCategory else { return 0 }
        return store.weeklyExpenseTotal(for: selectedCategory)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Logs")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Review income and expense activity with category and period filters.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(4)
                }
                .padding(.top, 8)

                filterControls

                if selectedCategory != nil {
                    selectedCategorySummary
                }

                logsSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 36)
        }
        .background(AppTheme.background)
    }

    private var filterControls: some View {
        HStack(spacing: 12) {
            FilterControlButton(
                title: "Select Category",
                value: selectedCategory?.name ?? "All Categories",
                symbolName: selectedCategory?.iconName ?? "line.3.horizontal.decrease.circle.fill",
                action: openCategoryPicker
            )

            FilterControlButton(
                title: "Select Period",
                value: selectedPeriod.title,
                symbolName: "calendar",
                action: openPeriodPicker
            )
        }
    }

    private var selectedCategorySummary: some View {
        HStack(spacing: 16) {
            Image(systemName: selectedCategory?.iconName ?? "tag.fill")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(AppTheme.cardTop)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(selectedCategory?.name ?? "Category")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Spent in the last week")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                Text(CurrencyFormatter.string(from: selectedCategoryWeekTotal))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.negative)
            }

            Spacer()
        }
        .padding(20)
        .background(AppTheme.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }

    private var logsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Recent Logs")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            if filteredLogs.isEmpty {
                EmptyHomeCard(
                    title: "No logs for this filter",
                    subtitle: selectedCategory == nil
                        ? "Try another period or add a new income or expense."
                        : "Try another period or choose a different category."
                )
            } else {
                VStack(spacing: 10) {
                    ForEach(filteredLogs) { transaction in
                        TransactionLogRow(transaction: transaction)
                    }
                }
            }
        }
    }
}

private struct FilterControlButton: View {
    let title: String
    let value: String
    let symbolName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: symbolName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppTheme.cardTop)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 118, alignment: .leading)
            .background(AppTheme.white.opacity(0.86))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(AppTheme.outline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct LogCategoryPickerView: View {
    @EnvironmentObject private var store: BudgetPlannerStore

    @Binding var selectedCategory: ExpenseCategory?
    let onSelect: () -> Void

    private let categoryColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose a category for the logs filter.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(3)

                LazyVGrid(columns: categoryColumns, spacing: 10) {
                    LogCategoryGridButton(
                        title: "All",
                        symbolName: "line.3.horizontal.decrease.circle.fill",
                        isSelected: selectedCategory == nil
                    ) {
                        selectedCategory = nil
                        onSelect()
                    }

                    ForEach(store.expenseCategories) { category in
                        LogCategoryGridButton(
                            title: category.name,
                            symbolName: category.iconName,
                            isSelected: selectedCategory?.id == category.id
                        ) {
                            selectedCategory = category
                            onSelect()
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 36)
        }
        .background(AppTheme.background)
        .navigationTitle("Select Category")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LogCategoryGridButton: View {
    let title: String
    let symbolName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: symbolName)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(isSelected ? .white : AppTheme.cardTop)
                    .frame(width: 42, height: 42)
                    .background(isSelected ? AppTheme.cardTop : AppTheme.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(title)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, minHeight: 94)
            .background(isSelected ? AppTheme.cardBottom.opacity(0.95) : AppTheme.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(isSelected ? AppTheme.cardTop : AppTheme.outline, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct LogPeriodPickerView: View {
    @Binding var selectedPeriod: LogPeriod
    let onSelect: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Pick the time range for the logs list.")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(3)

                ForEach(LogPeriod.allCases) { period in
                    FilterSelectionRow(
                        title: period.title,
                        subtitle: period.subtitle,
                        symbolName: "calendar",
                        isSelected: selectedPeriod == period
                    ) {
                        selectedPeriod = period
                        onSelect()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 36)
        }
        .background(AppTheme.background)
        .navigationTitle("Select Period")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FilterSelectionRow: View {
    let title: String
    let subtitle: String
    let symbolName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: symbolName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(isSelected ? .white : AppTheme.cardTop)
                    .frame(width: 48, height: 48)
                    .background(isSelected ? AppTheme.cardTop : AppTheme.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(2)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(AppTheme.positive)
                }
            }
            .padding(18)
            .background(AppTheme.white.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(isSelected ? AppTheme.cardTop : AppTheme.outline, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct AnalyticsOverviewCard: View {
    let monthLabel: String
    let totalSpent: Double
    let bubbles: [AnalyticsOverviewBubble]
    @Binding var selectedBubbleID: String?

    private let bubblePositions: [CGPoint] = [
        CGPoint(x: 0.22, y: 0.70),
        CGPoint(x: 0.60, y: 0.30),
        CGPoint(x: 0.80, y: 0.57),
        CGPoint(x: 0.56, y: 0.76),
        CGPoint(x: 0.18, y: 0.42),
        CGPoint(x: 0.82, y: 0.80)
    ]
    private let bubbleGap: CGFloat = 10

    private var selectedBubble: AnalyticsOverviewBubble? {
        if let selectedBubbleID,
           let matchingBubble = bubbles.first(where: { $0.id == selectedBubbleID }) {
            return matchingBubble
        }

        return bubbles.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Text("Overview")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Image(systemName: "circle.grid.2x2.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(AppTheme.cardTop)
                    .frame(width: 38, height: 38)
                    .background(AppTheme.white.opacity(0.88))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Spending in \(monthLabel)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                Text(CurrencyFormatter.string(from: totalSpent))
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
            }

            if bubbles.isEmpty {
                EmptyHomeCard(
                    title: "No monthly category mix yet",
                    subtitle: "Once you log a few expenses this month, this overview will turn into a category bubble chart."
                )
            } else {
                GeometryReader { geometry in
                    ZStack {
                        ForEach(Array(bubbles.enumerated()), id: \.element.id) { index, bubble in
                            let position = index < bubblePositions.count ? bubblePositions[index] : CGPoint(x: 0.5, y: 0.5)
                            let diameter = max(48, bubbleDiameter(for: bubble.share) - bubbleGap)

                            Button {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                    selectedBubbleID = bubble.id
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    Text("\(Int((bubble.share * 100).rounded()))%")
                                        .font(.system(size: diameter > 110 ? 24 : 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.textPrimary)

                                    Text(bubble.title)
                                        .font(.system(size: diameter > 110 ? 15 : 12, weight: .semibold, design: .rounded))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                                .frame(width: diameter, height: diameter)
                                .background(bubble.color)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(selectedBubble?.id == bubble.id ? AppTheme.primaryPurple.opacity(0.9) : AppTheme.white.opacity(0.35), lineWidth: selectedBubble?.id == bubble.id ? 3 : 1)
                                )
                                .shadow(color: selectedBubble?.id == bubble.id ? AppTheme.shadow.opacity(1) : .clear, radius: 18, x: 0, y: 10)
                                .scaleEffect(selectedBubble?.id == bubble.id ? 1.04 : 1)
                            }
                            .buttonStyle(.plain)
                            .position(
                                x: min(max(diameter / 2, geometry.size.width * position.x), geometry.size.width - diameter / 2),
                                y: min(max(diameter / 2, geometry.size.height * position.y), geometry.size.height - diameter / 2)
                            )
                        }
                    }
                }
                .frame(height: 280)

                if let selectedBubble {
                    HStack(spacing: 12) {
                        Image(systemName: selectedBubble.iconName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(AppTheme.cardTop)
                            .frame(width: 42, height: 42)
                            .background(AppTheme.white.opacity(0.88))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(selectedBubble.title)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)

                            Text("\(Int((selectedBubble.share * 100).rounded()))% of this month")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Spacer()

                        Text(CurrencyFormatter.string(from: selectedBubble.amount))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.darkPurple)
                    }
                    .padding(16)
                    .background(AppTheme.white.opacity(0.82))
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
        }
        .padding(22)
        .background(
            LinearGradient(
                colors: [AppTheme.white.opacity(0.92), AppTheme.lightLavender.opacity(0.94)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow, radius: 18, x: 0, y: 10)
    }

    private func bubbleDiameter(for share: Double) -> CGFloat {
        let clampedShare = min(max(share, 0.08), 0.48)
        return 56 + CGFloat(clampedShare * 180)
    }
}

private struct AnalyticsInsightCard: View {
    let insight: AnalyticsInsight
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: insight.iconName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(isSelected ? .white : insight.tone.accentColor)
                        .frame(width: 40, height: 40)
                        .background(isSelected ? Color.white.opacity(0.18) : AppTheme.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    Spacer()

                    Text(insight.valueText)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(isSelected ? .white : insight.tone.accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(isSelected ? Color.white.opacity(0.15) : insight.tone.accentColor.opacity(0.12))
                        .clipShape(Capsule())
                }

                Text(insight.title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(isSelected ? .white : AppTheme.textPrimary)
                    .lineLimit(2)

                Text(insight.summary)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white.opacity(0.85) : AppTheme.textSecondary)
                    .lineSpacing(3)
                    .lineLimit(4)
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 178, alignment: .topLeading)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(isSelected ? Color.clear : AppTheme.outline, lineWidth: 1)
            )
            .shadow(color: isSelected ? AppTheme.shadow : .clear, radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var cardBackground: some View {
        if isSelected {
            LinearGradient(
                colors: [AppTheme.cardTop, AppTheme.cardBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            AppTheme.surface
        }
    }
}

private struct AnalyticsInsightDetailCard: View {
    let insight: AnalyticsInsight
    let signal: AnalyticsSignalTrend?
    let comparisonDayCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: insight.iconName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(insight.tone.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Insight")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(insight.title)
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Spacer()
            }

            Text(insight.summary)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(4)

            if let signal {
                HStack(spacing: 12) {
                    AnalyticsStatChip(
                        title: "This Week",
                        value: CurrencyFormatter.string(from: signal.thisWeekAmount),
                        tint: AppTheme.cardTop
                    )

                    AnalyticsStatChip(
                        title: "Last Week",
                        value: CurrencyFormatter.string(from: signal.lastWeekAmount),
                        tint: AppTheme.cardBottom
                    )
                }
            } else {
                Text("Comparison window: \(comparisonDayCount) day\(comparisonDayCount == 1 ? "" : "s") this week versus the same days last week.")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }
}

private struct AnalyticsStatChip: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.16))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct AnalyticsSignalChart: View {
    let signals: [AnalyticsSignalTrend]
    let highlightedSignalID: String?

    private var maxAmount: Double {
        max(
            signals
                .flatMap { [$0.thisWeekAmount, $0.lastWeekAmount] }
                .max() ?? 0,
            1
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Signals Chart")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("This week versus the same point in last week for your strongest spending signals.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(3)

            VStack(spacing: 12) {
                ForEach(signals) { signal in
                    AnalyticsSignalRow(
                        signal: signal,
                        maxAmount: maxAmount,
                        isHighlighted: signal.id == highlightedSignalID
                    )
                }
            }
        }
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }
}

private struct AnalyticsSignalRow: View {
    let signal: AnalyticsSignalTrend
    let maxAmount: Double
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: signal.iconName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isHighlighted ? .white : AppTheme.cardTop)
                    .frame(width: 38, height: 38)
                    .background(isHighlighted ? AppTheme.cardTop : AppTheme.white)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                Text(signal.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Spacer()

                if let percentChange = signal.percentChange {
                    Text("\(percentChange >= 0 ? "+" : "-")\(formattedPercent(abs(percentChange)))")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(percentChange >= 0 ? AppTheme.negative : AppTheme.positive)
                }
            }

            AnalyticsComparisonBar(
                label: "This",
                amount: signal.thisWeekAmount,
                maxAmount: maxAmount,
                fill: isHighlighted ? AppTheme.cardTop : AppTheme.barFill,
                amountColor: AppTheme.textPrimary
            )

            AnalyticsComparisonBar(
                label: "Last",
                amount: signal.lastWeekAmount,
                maxAmount: maxAmount,
                fill: isHighlighted ? AppTheme.cardBottom : AppTheme.cardBottom.opacity(0.7),
                amountColor: AppTheme.textSecondary
            )
        }
        .padding(16)
        .background(isHighlighted ? AppTheme.primaryPurple.opacity(0.12) : AppTheme.lightLavender.opacity(0.36))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func formattedPercent(_ value: Double) -> String {
        if abs(value.rounded() - value) < 0.05 {
            return "\(Int(value.rounded()))%"
        }

        return String(format: "%.1f%%", value)
    }
}

private struct AnalyticsComparisonBar: View {
    let label: String
    let amount: Double
    let maxAmount: Double
    let fill: Color
    let amountColor: Color

    private var progress: CGFloat {
        guard maxAmount > 0 else { return 0 }
        return CGFloat(amount / maxAmount)
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 34, alignment: .leading)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.background)

                    Capsule()
                        .fill(fill)
                        .frame(width: max(10, geometry.size.width * progress))
                }
            }
            .frame(height: 12)

            Text(CurrencyFormatter.string(from: amount))
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(amountColor)
                .frame(width: 70, alignment: .trailing)
        }
    }
}

private struct AnalyticsDailyChart: View {
    let points: [DailyExpensePoint]

    private var maxAmount: Double {
        max(
            points
                .flatMap { [$0.thisWeekAmount, $0.lastWeekAmount] }
                .max() ?? 0,
            1
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Daily Pace")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Day-by-day comparison for the same days in last week.")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            GeometryReader { geometry in
                HStack(alignment: .bottom, spacing: 12) {
                    ForEach(points) { point in
                        VStack(spacing: 10) {
                            HStack(alignment: .bottom, spacing: 6) {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(AppTheme.cardBottom)
                                    .frame(
                                        width: max((geometry.size.width / CGFloat(max(points.count, 1)) - 16) / 2, 10),
                                        height: barHeight(for: point.lastWeekAmount, maxHeight: geometry.size.height - 44)
                                    )

                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(AppTheme.cardTop)
                                    .frame(
                                        width: max((geometry.size.width / CGFloat(max(points.count, 1)) - 16) / 2, 10),
                                        height: barHeight(for: point.thisWeekAmount, maxHeight: geometry.size.height - 44)
                                    )
                            }

                            Text(point.label)
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    }
                }
            }
            .frame(height: 220)

            HStack(spacing: 16) {
                AnalyticsLegendItem(title: "Last week", color: AppTheme.cardBottom)
                AnalyticsLegendItem(title: "This week", color: AppTheme.cardTop)
            }
        }
        .padding(20)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }

    private func barHeight(for amount: Double, maxHeight: CGFloat) -> CGFloat {
        guard maxAmount > 0 else { return 10 }
        return max(10, CGFloat(amount / maxAmount) * maxHeight)
    }
}

private struct AnalyticsLegendItem: View {
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)

            Text(title)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
        }
    }
}

private struct AnalyticsAlertCard: View {
    let alert: AnalyticsAlertState

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: alert.iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(alert.tone.accentColor)
                .frame(width: 42, height: 42)
                .background(alert.tone.backgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(alert.title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(alert.summary)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(2)
            }

            Spacer()

            Text(alert.valueText)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(alert.tone.accentColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(16)
        .background(AppTheme.white.opacity(0.88))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }
}

private struct GroupActionButton: View {
    enum Style {
        case filled
        case outline
    }

    let title: String
    let iconName: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                Text(title)
            }
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(style == .filled ? AnyShapeStyle(AppTheme.cardTop) : AnyShapeStyle(AppTheme.white.opacity(0.92)))
            .foregroundStyle(style == .filled ? .white : AppTheme.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(style == .filled ? Color.clear : AppTheme.outline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

private struct LeaderboardMemberRow: View {
    let rank: Int
    let member: LeaderboardMemberState

    var body: some View {
        HStack(spacing: 14) {
            Text("\(rank)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(rankColor)
                .frame(width: 30)

            ProfileAvatarView(
                imageData: member.imageData,
                initials: member.initials,
                size: 54,
                backgroundColors: member.isCurrentUser
                    ? [AppTheme.cardTop.opacity(0.92), AppTheme.cardBottom]
                    : [Color(hex: 0x7C8BD8), Color(hex: 0xC9D0F0)]
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(member.displayName)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    if member.isCurrentUser {
                        Text("You")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.cardTop)
                            .clipShape(Capsule())
                    }
                }

                Text("Level \(member.level)")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("\(member.xp) XP")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(rank == 1 ? Color(hex: 0xD59E1C) : AppTheme.cardTop)

                if rank <= 3 {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(rankColor)
                }
            }
        }
        .padding(16)
        .background(AppTheme.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(member.isCurrentUser ? AppTheme.cardTop.opacity(0.35) : AppTheme.outline, lineWidth: member.isCurrentUser ? 1.5 : 1)
        )
    }

    private var rankColor: Color {
        switch rank {
        case 1:
            return Color(hex: 0xD59E1C)
        case 2:
            return Color(hex: 0x7B89A7)
        case 3:
            return Color(hex: 0xC6864A)
        default:
            return AppTheme.textSecondary
        }
    }
}

private struct ChatPreviewBubble: View {
    let message: GroupChatPreviewMessage

    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer(minLength: 40)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(message.senderName)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(message.isCurrentUser ? .white.opacity(0.84) : AppTheme.cardTop)

                Text(message.body)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(message.isCurrentUser ? .white : AppTheme.textPrimary)
                    .lineSpacing(2)

                Text(message.sentAt.formatted(date: .omitted, time: .shortened))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(message.isCurrentUser ? .white.opacity(0.72) : AppTheme.textSecondary)
            }
            .padding(14)
            .background(message.isCurrentUser ? AppTheme.cardTop : AppTheme.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            if !message.isCurrentUser {
                Spacer(minLength: 40)
            }
        }
    }
}

private struct ProfileStatCard: View {
    let iconName: String
    let valueText: String
    let title: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(AppTheme.gold)

            Text(valueText)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(AppTheme.surfaceStrong)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct BadgePill: View {
    let badge: BadgeState

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: badge.iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(badge.isUnlocked ? Color(hex: 0xE3A321) : AppTheme.textSecondary)

            Text(badge.title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(badge.isUnlocked ? Color(hex: 0x5F71B7) : AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(badge.isUnlocked ? AppTheme.white.opacity(0.95) : AppTheme.surfaceStrong)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct HomeQuestRow: View {
    let quest: QuestState

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: quest.iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(hex: 0xE98E3B))
                .frame(width: 34, height: 34)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(quest.title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(quest.subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("+\(quest.xp) XP")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.positive)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frostedGlassCard(cornerRadius: 24)
    }
}

private enum ProfileQuestRowStyle {
    case active
    case completed
}

private struct ProfileQuestRow: View {
    let quest: QuestState
    let style: ProfileQuestRowStyle

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: style == .completed ? "checkmark.circle.fill" : quest.iconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(style == .completed ? Color(hex: 0x24B65A) : Color(hex: 0xE98E3B))
                .frame(width: 34, height: 34)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(quest.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(style == .completed ? "Quest completed" : quest.subtitle)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(style == .completed ? "\(quest.xp) XP" : "+\(quest.xp) XP")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.positive)

                if style == .active {
                    Text(quest.progressText)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                } else {
                    Text("Earned")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.positive)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frostedGlassCard(cornerRadius: 24)
    }
}

private struct HomeSectionCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            content
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frostedGlassCard(cornerRadius: 28)
    }
}

private struct HomeSectionEmptyRow: View {
    let title: String
    let subtitle: String
    var iconName: String = "tray"

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frostedGlassCard(cornerRadius: 24)
    }
}

private struct LearningContinueRow: View {
    let lesson: LearnLesson
    let streakLabel: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                Image(systemName: "book.pages")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(AppTheme.cardTop)
                    .frame(width: 36, height: 36)
                    .background(AppTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(lesson.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .lineLimit(1)

                    Text(lesson.subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(1)

                    Text(streakLabel)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.cardTop)
                }

                Spacer()
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.surfaceStrong)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: 0xAB73EF), Color(hex: 0xC79AF4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * max(0, min(progress, 1)))
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frostedGlassCard(cornerRadius: 24)
    }
}

private struct HomeExpenseRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: transaction.displayIconName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(width: 36, height: 36)
                .background(AppTheme.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.outline, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.displayTitle)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)
            }

            Spacer()

            Text(CurrencyFormatter.string(from: transaction.amount))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.negative)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .frostedGlassCard(cornerRadius: 24)
    }
}

private struct TransactionLogRow: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: transaction.displayIconName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(transaction.type == .income ? AppTheme.positive : AppTheme.cardTop)
                .frame(width: 46, height: 46)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.displayTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            Text(CurrencyFormatter.string(from: transaction.amount))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(transaction.type == .income ? AppTheme.positive : AppTheme.negative)
        }
        .padding(16)
        .frostedGlassCard(cornerRadius: 24)
    }
}

private extension AnalyticsInsightTone {
    var accentColor: Color {
        switch self {
        case .caution:
            return AppTheme.negative
        case .positive:
            return AppTheme.positive
        case .neutral:
            return AppTheme.cardTop
        }
    }
}

private extension AnalyticsAlertState.Tone {
    var accentColor: Color {
        switch self {
        case .caution:
            return AppTheme.negative
        case .positive:
            return AppTheme.positive
        case .neutral:
            return AppTheme.cardTop
        }
    }

    var backgroundColor: Color {
        switch self {
        case .caution:
            return AppTheme.chartBlush.opacity(0.85)
        case .positive:
            return AppTheme.chartMint.opacity(0.9)
        case .neutral:
            return AppTheme.chartSky.opacity(0.9)
        }
    }
}

private struct EmptyHomeCard: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 17, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text(subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frostedGlassCard(cornerRadius: 24)
    }
}

private struct BudgetProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(AppTheme.surfaceStrong.opacity(0.82))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.gelVioletTop.opacity(0.85), AppTheme.gelVioletBottom.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * max(0, min(progress, 1)))
            }
        }
        .frame(height: 16)
    }
}

private struct GelActionButton: View {
    let title: String
    let symbolName: String
    let gradientColors: [Color]
    let action: () -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 30, style: .continuous)
        let topColor = gradientColors.first ?? AppTheme.gelVioletTop
        let bottomColor = gradientColors.last ?? AppTheme.gelVioletBottom

        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: symbolName)
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 32, height: 32)
                    .background(AppTheme.white.opacity(0.26))
                    .clipShape(Circle())

                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 78)
            .background(
                shape
                    .fill(
                        LinearGradient(
                            colors: [topColor, bottomColor],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                shape
                    .inset(by: 1)
                    .stroke(
                        LinearGradient(
                            colors: [AppTheme.white.opacity(0.72), AppTheme.white.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .overlay(
                        LinearGradient(
                            colors: [Color.white.opacity(0.55), Color.white.opacity(0.18), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottom
                        )
                        .clipShape(shape)
                    )
                    .overlay(
                        shape
                            .inset(by: 1)
                            .stroke(AppTheme.gelShadow.opacity(0.72), lineWidth: 2)
                            .offset(x: 1, y: 1)
                            .mask(shape)
                    )
                    .overlay(
                        shape
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: AppTheme.gelShadow.opacity(0.45), radius: 14, x: 0, y: 10)
            )
            .clipShape(shape)
            .contentShape(shape)
        }
        .buttonStyle(.plain)
    }
}

private struct FrostedGlassCardModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .background {
                ZStack {
                    shape
                        .fill(.ultraThinMaterial)
                    shape
                        .fill(colorScheme == .dark ? AppTheme.surface.opacity(0.84) : AppTheme.glassFill)
                }
            }
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(AppTheme.glassEdge, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow.opacity(colorScheme == .dark ? 0.45 : 0.16), radius: 18, x: 0, y: 10)
    }
}

private extension View {
    func frostedGlassCard(cornerRadius: CGFloat) -> some View {
        modifier(FrostedGlassCardModifier(cornerRadius: cornerRadius))
    }
}
