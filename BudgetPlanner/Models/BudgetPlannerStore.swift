import AuthenticationServices
import Foundation

enum OnboardingStep: String, Codable {
    case welcome
    case signUp
    case budget
    case photo
    case home
}

struct UserProfile: Codable, Hashable {
    var firstName = ""
    var lastName = ""
    var university = ""
    var birthDate: Date?
    var monthlyBudget: Double = 0
    var profileImageData: Data?
}

enum AnalyticsInsightTone: Hashable {
    case caution
    case positive
    case neutral
}

struct AnalyticsSignalTrend: Identifiable, Hashable {
    let id: String
    let title: String
    let iconName: String
    let thisWeekAmount: Double
    let lastWeekAmount: Double
    let transactionCount: Int

    var deltaAmount: Double {
        thisWeekAmount - lastWeekAmount
    }

    var percentChange: Double? {
        guard lastWeekAmount > 0 else { return nil }
        return (deltaAmount / lastWeekAmount) * 100
    }

    var combinedAmount: Double {
        thisWeekAmount + lastWeekAmount
    }
}

struct DailyExpensePoint: Identifiable, Hashable {
    let id: String
    let label: String
    let thisWeekAmount: Double
    let lastWeekAmount: Double
}

struct AnalyticsInsight: Identifiable, Hashable {
    enum Kind: Hashable {
        case risingSignal
        case overallPace
        case topSignal
        case dailyAverage
    }

    let id: String
    let kind: Kind
    let title: String
    let summary: String
    let valueText: String
    let iconName: String
    let tone: AnalyticsInsightTone
    let relatedSignalID: String?
}

struct LearnLesson: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let xp: Int
    let iconName: String
    let contentSections: [String]
    let quizQuestion: String
    let quizOptions: [String]
    let correctOptionIndex: Int
}

struct LearnTopic: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let lessons: [LearnLesson]
}

struct LearnLessonProgress: Codable, Hashable {
    var isCompleted: Bool
    var completedAt: Date?
    var earnedXP: Int

    init(isCompleted: Bool = false, completedAt: Date? = nil, earnedXP: Int = 0) {
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.earnedXP = earnedXP
    }
}

struct LearnLessonState: Identifiable, Hashable {
    let topicIndex: Int
    let lessonIndex: Int
    let lesson: LearnLesson
    let isUnlocked: Bool
    let isCompleted: Bool

    var id: String { lesson.id }
}

struct LearnTopicState: Identifiable, Hashable {
    let topicIndex: Int
    let topic: LearnTopic
    let isUnlocked: Bool
    let completedLessons: Int
    let lessons: [LearnLessonState]

    var id: String { topic.id }

    var totalLessons: Int {
        topic.lessons.count
    }

    var progress: Double {
        guard totalLessons > 0 else { return 0 }
        return Double(completedLessons) / Double(totalLessons)
    }
}

struct QuestProgress: Codable, Hashable {
    var isCompleted: Bool
    var completedAt: Date?
    var earnedXP: Int

    init(isCompleted: Bool = false, completedAt: Date? = nil, earnedXP: Int = 0) {
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.earnedXP = earnedXP
    }
}

struct QuestState: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let xp: Int
    let progressText: String
    let progressValue: Double
    let isCompleted: Bool
    let completedAt: Date?
}

struct BadgeState: Identifiable, Hashable {
    let id: String
    let title: String
    let iconName: String
    let isUnlocked: Bool
}

struct LeaderboardGroupState: Identifiable, Hashable {
    let id: String
    let name: String
    let inviteCode: String
    let memberCount: Int
}

struct LeaderboardMemberState: Identifiable, Hashable {
    let id: String
    let displayName: String
    let xp: Int
    let level: Int
    let isCurrentUser: Bool
    let imageData: Data?
    let initials: String
}

struct GroupChatPreviewMessage: Identifiable, Hashable {
    let id: String
    let senderName: String
    let body: String
    let sentAt: Date
    let isCurrentUser: Bool
}

struct GroupChatMessageState: Identifiable, Hashable {
    let id: String
    let senderName: String
    let senderInitials: String
    let body: String
    let sentAt: Date
    let isCurrentUser: Bool
}

struct SocialAlertState: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
}

struct AnalyticsAlertState: Identifiable, Hashable {
    enum Tone: Hashable {
        case caution
        case positive
        case neutral
    }

    let id: String
    let title: String
    let summary: String
    let valueText: String
    let iconName: String
    let tone: Tone
}

private struct PersistedAppState: Codable {
    var profile: UserProfile
    var currentStep: OnboardingStep
    var transactions: [Transaction]
    var expenseCategories: [ExpenseCategory]
    var learnProgress: [String: LearnLessonProgress]
    var questProgress: [String: QuestProgress]
    var groupChatReadAt: [String: Date]

    init(
        profile: UserProfile,
        currentStep: OnboardingStep,
        transactions: [Transaction],
        expenseCategories: [ExpenseCategory],
        learnProgress: [String: LearnLessonProgress],
        questProgress: [String: QuestProgress],
        groupChatReadAt: [String: Date]
    ) {
        self.profile = profile
        self.currentStep = currentStep
        self.transactions = transactions
        self.expenseCategories = expenseCategories
        self.learnProgress = learnProgress
        self.questProgress = questProgress
        self.groupChatReadAt = groupChatReadAt
    }

    private enum CodingKeys: String, CodingKey {
        case profile
        case currentStep
        case transactions
        case expenseCategories
        case learnProgress
        case questProgress
        case groupChatReadAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profile = try container.decode(UserProfile.self, forKey: .profile)
        currentStep = try container.decode(OnboardingStep.self, forKey: .currentStep)
        transactions = try container.decode([Transaction].self, forKey: .transactions)
        expenseCategories = try container.decode([ExpenseCategory].self, forKey: .expenseCategories)
        learnProgress = try container.decode([String: LearnLessonProgress].self, forKey: .learnProgress)
        questProgress = try container.decodeIfPresent([String: QuestProgress].self, forKey: .questProgress) ?? [:]
        groupChatReadAt = try container.decodeIfPresent([String: Date].self, forKey: .groupChatReadAt) ?? [:]
    }
}

@MainActor
final class BudgetPlannerStore: ObservableObject {
    @Published var profile = UserProfile()
    @Published var currentStep: OnboardingStep = .welcome
    @Published var transactions: [Transaction] = []
    @Published var expenseCategories = ExpenseCategory.predefined
    @Published var learnProgress: [String: LearnLessonProgress] = [:]
    @Published var questProgress: [String: QuestProgress] = [:]
    @Published private(set) var socialSession: SocialSessionState?
    @Published private var socialGroupRecord: SocialGroupRecord?
    @Published private(set) var socialLeaderboardMembers: [LeaderboardMemberState] = []
    @Published private(set) var socialChatMessages: [GroupChatMessageState] = []
    @Published private(set) var isSocialActionInProgress = false
    @Published var socialAlert: SocialAlertState?
    @Published private var groupChatReadAt: [String: Date] = [:]

    private let persistenceEnabled: Bool
    private let socialService: FirebaseSocialService
    private static let persistedStateKey = "BudgetPlanner.persistedState"

    init(loadPersistedState shouldLoadPersistedState: Bool = true) {
        self.persistenceEnabled = shouldLoadPersistedState
        self.socialService = FirebaseSocialService()

        if shouldLoadPersistedState {
            loadPersistedState()
        }

        configureSocialBindings()
        Task { [weak self] in
            guard let self else { return }
            await self.socialService.refreshState()
        }
    }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<18:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }

    var fullName: String {
        [profile.firstName, profile.lastName]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    var displayName: String {
        profile.firstName.isEmpty ? "Student" : profile.firstName
    }

    var initials: String {
        let first = profile.firstName.first.map(String.init) ?? "S"
        let last = profile.lastName.first.map(String.init) ?? "B"
        return (first + last).uppercased()
    }

    var totalIncome: Double {
        transactions
            .filter { $0.type == .income }
            .map(\.amount)
            .reduce(0, +)
    }

    var totalExpenses: Double {
        transactions
            .filter { $0.type == .expense }
            .map(\.amount)
            .reduce(0, +)
    }

    var availableFunds: Double {
        profile.monthlyBudget + totalIncome
    }

    var remainingBudget: Double {
        availableFunds - totalExpenses
    }

    var spentToday: Double {
        transactions
            .filter { $0.type == .expense && Calendar.current.isDateInToday($0.date) }
            .map(\.amount)
            .reduce(0, +)
    }

    var spentRatio: Double {
        guard availableFunds > 0 else { return 0 }
        return min(max(totalExpenses / availableFunds, 0), 1)
    }

    var recentExpenses: [Transaction] {
        Array(
            transactions
                .filter { $0.type == .expense }
                .prefix(3)
        )
    }

    var recentLogs: [Transaction] {
        Array(transactions.prefix(8))
    }

    var customExpenseCategories: [ExpenseCategory] {
        expenseCategories.filter(\.isCustom)
    }

    var comparisonDayCount: Int {
        let dayDifference = calendar.dateComponents([.day], from: currentWeekInterval.start, to: .now).day ?? 0
        return min(max(dayDifference + 1, 1), 7)
    }

    var analyticsSignalTrends: [AnalyticsSignalTrend] {
        struct Accumulator {
            var title: String
            var iconName: String
            var thisWeekAmount: Double = 0
            var lastWeekAmount: Double = 0
            var transactionCount: Int = 0
        }

        var grouped: [String: Accumulator] = [:]

        for transaction in transactions where transaction.type == .expense {
            let isThisWeek = currentWeekComparisonInterval.contains(transaction.date)
            let isLastWeek = previousWeekComparisonInterval.contains(transaction.date)
            guard isThisWeek || isLastWeek else { continue }
            guard let signal = analyticsSignalDescriptor(for: transaction) else { continue }

            var accumulator = grouped[signal.id] ?? Accumulator(
                title: signal.title,
                iconName: signal.iconName
            )

            if isThisWeek {
                accumulator.thisWeekAmount += transaction.amount
            } else {
                accumulator.lastWeekAmount += transaction.amount
            }

            accumulator.transactionCount += 1
            grouped[signal.id] = accumulator
        }

        return grouped.map { entry in
            AnalyticsSignalTrend(
                id: entry.key,
                title: entry.value.title,
                iconName: entry.value.iconName,
                thisWeekAmount: entry.value.thisWeekAmount,
                lastWeekAmount: entry.value.lastWeekAmount,
                transactionCount: entry.value.transactionCount
            )
        }
        .sorted { lhs, rhs in
            if lhs.combinedAmount == rhs.combinedAmount {
                return lhs.title < rhs.title
            }
            return lhs.combinedAmount > rhs.combinedAmount
        }
    }

    var analyticsDailyExpensePoints: [DailyExpensePoint] {
        (0..<comparisonDayCount).compactMap { offset in
            guard
                let thisDayStart = calendar.date(byAdding: .day, value: offset, to: currentWeekInterval.start),
                let thisDayEnd = calendar.date(byAdding: .day, value: 1, to: thisDayStart),
                let lastDayStart = calendar.date(byAdding: .day, value: offset, to: previousWeekInterval.start),
                let lastDayEnd = calendar.date(byAdding: .day, value: 1, to: lastDayStart)
            else {
                return nil
            }

            let label = thisDayStart.formatted(.dateTime.weekday(.abbreviated))
            return DailyExpensePoint(
                id: label,
                label: label,
                thisWeekAmount: expenseTotal(from: thisDayStart, to: thisDayEnd),
                lastWeekAmount: expenseTotal(from: lastDayStart, to: lastDayEnd)
            )
        }
    }

    var analyticsInsights: [AnalyticsInsight] {
        let currentTotal = expenseTotal(in: currentWeekComparisonInterval)
        let previousTotal = expenseTotal(in: previousWeekComparisonInterval)
        let dailyCurrentAverage = currentTotal / Double(comparisonDayCount)
        let dailyPreviousAverage = previousTotal / Double(comparisonDayCount)
        let signals = analyticsSignalTrends

        var insights: [AnalyticsInsight] = []

        if let risingSignal = bestRisingSignal(from: signals) {
            if let change = risingSignal.percentChange {
                insights.append(
                    AnalyticsInsight(
                        id: "rising-\(risingSignal.id)",
                        kind: .risingSignal,
                        title: "\(risingSignal.title) is rising",
                        summary: "\(risingSignal.title) spending is up \(formattedPercent(abs(change))) versus the same point last week.",
                        valueText: "+\(formattedPercent(abs(change)))",
                        iconName: risingSignal.iconName,
                        tone: .caution,
                        relatedSignalID: risingSignal.id
                    )
                )
            } else {
                insights.append(
                    AnalyticsInsight(
                        id: "rising-\(risingSignal.id)",
                        kind: .risingSignal,
                        title: "New \(risingSignal.title) spend",
                        summary: "You started spending on \(risingSignal.title) this week. Keep an eye on whether it becomes a new habit.",
                        valueText: CurrencyFormatter.string(from: risingSignal.thisWeekAmount),
                        iconName: risingSignal.iconName,
                        tone: .caution,
                        relatedSignalID: risingSignal.id
                    )
                )
            }
        }

        if currentTotal > 0 || previousTotal > 0 {
            let delta = currentTotal - previousTotal
            let tone: AnalyticsInsightTone = delta > 0 ? .caution : (delta < 0 ? .positive : .neutral)
            let summary: String
            let valueText: String

            if let percent = percentChange(from: previousTotal, to: currentTotal) {
                let direction = delta >= 0 ? "up" : "down"
                summary = "Overall spending pace is \(direction) \(formattedPercent(abs(percent))) compared with the same days last week."
                valueText = "\(delta >= 0 ? "+" : "-")\(formattedPercent(abs(percent)))"
            } else {
                summary = "You have logged \(CurrencyFormatter.string(from: currentTotal)) so far this week."
                valueText = CurrencyFormatter.string(from: currentTotal)
            }

            insights.append(
                AnalyticsInsight(
                    id: "overall-pace",
                    kind: .overallPace,
                    title: "Weekly spending pace",
                    summary: summary,
                    valueText: valueText,
                    iconName: "speedometer",
                    tone: tone,
                    relatedSignalID: nil
                )
            )
        }

        if
            let topSignal = signals
                .filter({ $0.thisWeekAmount > 0 })
                .max(by: { lhs, rhs in lhs.thisWeekAmount < rhs.thisWeekAmount })
        {
            let share = currentTotal > 0 ? (topSignal.thisWeekAmount / currentTotal) * 100 : 0
            insights.append(
                AnalyticsInsight(
                    id: "top-\(topSignal.id)",
                    kind: .topSignal,
                    title: "\(topSignal.title) leads this week",
                    summary: "\(topSignal.title) accounts for \(formattedPercent(share)) of your spending so far this week.",
                    valueText: CurrencyFormatter.string(from: topSignal.thisWeekAmount),
                    iconName: topSignal.iconName,
                    tone: .neutral,
                    relatedSignalID: topSignal.id
                )
            )
        }

        if dailyCurrentAverage > 0 || dailyPreviousAverage > 0 {
            let delta = dailyCurrentAverage - dailyPreviousAverage
            let tone: AnalyticsInsightTone = delta > 0 ? .caution : (delta < 0 ? .positive : .neutral)
            let summary: String

            if let percent = percentChange(from: dailyPreviousAverage, to: dailyCurrentAverage) {
                let direction = delta >= 0 ? "higher" : "lower"
                summary = "Your daily average is \(direction) by \(formattedPercent(abs(percent))) compared with last week."
            } else {
                summary = "Your average daily spend this week is \(CurrencyFormatter.string(from: dailyCurrentAverage))."
            }

            insights.append(
                AnalyticsInsight(
                    id: "daily-average",
                    kind: .dailyAverage,
                    title: "Average per day",
                    summary: summary,
                    valueText: "\(CurrencyFormatter.string(from: dailyCurrentAverage))/day",
                    iconName: "calendar.badge.clock",
                    tone: tone,
                    relatedSignalID: nil
                )
            )
        }

        return Array(insights.prefix(4))
    }

    var learnTopics: [LearnTopic] {
        Self.learnTopicsCatalog
    }

    var learnTopicStates: [LearnTopicState] {
        Self.learnTopicsCatalog.enumerated().map { topicIndex, topic in
            let topicUnlocked = topicIndex == 0 || previousTopicCompleted(before: topicIndex)

            let lessonStates = topic.lessons.enumerated().map { lessonIndex, lesson in
                LearnLessonState(
                    topicIndex: topicIndex,
                    lessonIndex: lessonIndex,
                    lesson: lesson,
                    isUnlocked: topicUnlocked && lessonUnlocked(topicIndex: topicIndex, lessonIndex: lessonIndex),
                    isCompleted: lessonCompleted(lesson.id)
                )
            }

            return LearnTopicState(
                topicIndex: topicIndex,
                topic: topic,
                isUnlocked: topicUnlocked,
                completedLessons: lessonStates.filter(\.isCompleted).count,
                lessons: lessonStates
            )
        }
    }

    var totalLessonCount: Int {
        Self.learnTopicsCatalog.reduce(0) { $0 + $1.lessons.count }
    }

    var completedLessonCount: Int {
        validLearnProgress.values.filter(\.isCompleted).count
    }

    var learnTotalXP: Int {
        validLearnProgress.values.reduce(0) { $0 + $1.earnedXP }
    }

    var learnCompletionPercentage: Int {
        guard totalLessonCount > 0 else { return 0 }
        return Int((Double(completedLessonCount) / Double(totalLessonCount) * 100).rounded())
    }

    var lessonsCompletedToday: Int {
        validLearnProgress.values.filter { progress in
            guard let completedAt = progress.completedAt else { return false }
            return calendar.isDateInToday(completedAt)
        }.count
    }

    var learnDailyGoalProgressText: String {
        "\(min(lessonsCompletedToday, 1))/1"
    }

    var learnStreakDays: Int {
        let completionDays = Set(
            validLearnProgress.values.compactMap { progress in
                progress.completedAt.map { calendar.startOfDay(for: $0) }
            }
        )

        guard !completionDays.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        var cursor: Date
        if completionDays.contains(today) {
            cursor = today
        } else if completionDays.contains(yesterday) {
            cursor = yesterday
        } else {
            return 0
        }

        var streak = 0
        while completionDays.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }

        return streak
    }

    var continueLearningLesson: LearnLessonState? {
        let lessons = learnTopicStates.flatMap(\.lessons)

        if let nextUnlockedLesson = lessons.first(where: { $0.isUnlocked && !$0.isCompleted }) {
            return nextUnlockedLesson
        }

        return lessons.last(where: \.isCompleted)
    }

    var questTotalXP: Int {
        questProgress.values.reduce(0) { $0 + $1.earnedXP }
    }

    var totalXP: Int {
        learnTotalXP + questTotalXP
    }

    var profileLevel: Int {
        max(1, (totalXP / 80) + 1)
    }

    var profileRankTitle: String {
        switch profileLevel {
        case 1...2:
            return "Finance Apprentice"
        case 3...4:
            return "Budget Pathfinder"
        case 5...6:
            return "Quest Strategist"
        default:
            return "Leaderboard Contender"
        }
    }

    var allQuestStates: [QuestState] {
        Self.questCatalog.map { definition in
            let evaluation = evaluateQuest(definition)
            let completion = questProgress[definition.id]

            return QuestState(
                id: definition.id,
                title: definition.title,
                subtitle: definition.subtitle,
                iconName: definition.iconName,
                xp: definition.xp,
                progressText: evaluation.progressText,
                progressValue: evaluation.progressValue,
                isCompleted: completion?.isCompleted == true,
                completedAt: completion?.completedAt
            )
        }
    }

    var activeQuestStates: [QuestState] {
        allQuestStates.filter { !$0.isCompleted }
    }

    var homeQuestStates: [QuestState] {
        Array(activeQuestStates.prefix(2))
    }

    var recentCompletedQuestStates: [QuestState] {
        allQuestStates
            .filter(\.isCompleted)
            .sorted { lhs, rhs in
                (lhs.completedAt ?? .distantPast) > (rhs.completedAt ?? .distantPast)
            }
    }

    var completedQuestCount: Int {
        recentCompletedQuestStates.count
    }

    var activeQuestCount: Int {
        activeQuestStates.count
    }

    var activeQuestXPAvailable: Int {
        activeQuestStates.map(\.xp).reduce(0, +)
    }

    var badgeStates: [BadgeState] {
        [
            BadgeState(id: "fire", title: "Fire", iconName: "flame.fill", isUnlocked: learnStreakDays >= 3),
            BadgeState(id: "saver", title: "Saver", iconName: "hands.sparkles.fill", isUnlocked: questCompleted("food-under-40")),
            BadgeState(id: "tracker", title: "Tracker", iconName: "figure.run", isUnlocked: questCompleted("track-7-day-expense")),
            BadgeState(id: "rising-star", title: "Rising Star", iconName: "star.circle.fill", isUnlocked: totalXP >= 100),
            BadgeState(id: "champion", title: "Champion", iconName: "medal.fill", isUnlocked: completedQuestCount >= 3)
        ]
    }

    var isSignedInToSocial: Bool {
        socialSession != nil
    }

    var socialProviderLabel: String {
        socialSession?.providerName ?? "Account"
    }

    var socialAccountEmail: String? {
        socialSession?.email
    }

    var socialAccountDisplayName: String {
        socialSession?.displayName ?? displayName
    }

    var googleSignInIssue: String? {
        socialService.googleSignInIssue
    }

    var leaderboardGroup: LeaderboardGroupState? {
        guard let socialGroupRecord else { return nil }
        return LeaderboardGroupState(
            id: socialGroupRecord.id,
            name: socialGroupRecord.name,
            inviteCode: socialGroupRecord.inviteCode,
            memberCount: max(socialGroupRecord.memberCount, socialLeaderboardMembers.count)
        )
    }

    var leaderboardMembers: [LeaderboardMemberState] {
        socialLeaderboardMembers
    }

    var leaderboardTopMembers: [LeaderboardMemberState] {
        Array(leaderboardMembers.prefix(3))
    }

    var leaderboardRemainingMembers: [LeaderboardMemberState] {
        Array(leaderboardMembers.dropFirst(3))
    }

    var groupChatMessages: [GroupChatMessageState] {
        socialChatMessages
    }

    var unreadGroupChatCount: Int {
        guard let groupID = socialGroupRecord?.id else { return 0 }
        let lastReadAt = groupChatReadAt[groupID]

        return socialChatMessages.filter { message in
            guard !message.isCurrentUser else { return false }
            guard let lastReadAt else { return true }
            return message.sentAt > lastReadAt
        }.count
    }

    var analyticsAlerts: [AnalyticsAlertState] {
        let spentSoFar = currentMonthExpenseTotal
        let availableThisMonth = currentMonthAvailableFunds
        let remaining = max(availableThisMonth - spentSoFar, 0)
        let totalDays = daysInCurrentMonth
        let elapsedDays = daysElapsedInCurrentMonth
        let remainingDays = max(totalDays - elapsedDays, 0)

        guard availableThisMonth > 0, elapsedDays > 0 else {
            return [
                AnalyticsAlertState(
                    id: "no-budget-risk",
                    title: "Budget outlook is waiting",
                    summary: "Add this month's expenses and the app will project whether you are likely to exceed budget.",
                    valueText: "No trend yet",
                    iconName: "bell.badge",
                    tone: .neutral
                )
            ]
        }

        let dailyPace = spentSoFar / Double(elapsedDays)
        let projectedMonthEndSpend = dailyPace * Double(totalDays)
        let projectedGap = projectedMonthEndSpend - availableThisMonth
        let safeDailySpend = remainingDays > 0 ? remaining / Double(remainingDays) : remaining
        let runOutDate = estimatedBudgetRunOutDate

        var alerts: [AnalyticsAlertState] = []

        if projectedGap > 0 {
            alerts.append(
                AnalyticsAlertState(
                    id: "budget-pressure",
                    title: "Budget pressure is building",
                    summary: runOutDate.map {
                        "At this pace, you could exceed budget by month-end and run out around \($0.formatted(.dateTime.day().month(.abbreviated)))."
                    } ?? "At this pace, you could exceed budget by month-end.",
                    valueText: CurrencyFormatter.string(from: projectedGap),
                    iconName: "exclamationmark.triangle.fill",
                    tone: .caution
                )
            )
        } else {
            alerts.append(
                AnalyticsAlertState(
                    id: "projected-safe",
                    title: "You are on a stable pace",
                    summary: "Current spending suggests you should stay within this month's budget.",
                    valueText: CurrencyFormatter.string(from: max(availableThisMonth - projectedMonthEndSpend, 0)),
                    iconName: "checkmark.shield.fill",
                    tone: .positive
                )
            )
        }

        alerts.append(
            AnalyticsAlertState(
                id: "safe-daily-spend",
                title: "Daily limit to stay safe",
                summary: "Keep average spending around this amount for the rest of the month.",
                valueText: CurrencyFormatter.string(from: safeDailySpend),
                iconName: "target",
                tone: .neutral
            )
        )

        if projectedGap <= 0, let runOutDate {
            alerts.append(
                AnalyticsAlertState(
                    id: "pace-watch",
                    title: "Stay steady through \(runOutDate.formatted(.dateTime.month(.abbreviated)))",
                    summary: "You are safe for now, but a few heavier days could still tighten the month quickly.",
                    valueText: runOutDate.formatted(.dateTime.day().month(.abbreviated)),
                    iconName: "calendar.badge.clock",
                    tone: .neutral
                )
            )
        }

        return Array(alerts.prefix(2))
    }

    func analyticsSignal(for insight: AnalyticsInsight) -> AnalyticsSignalTrend? {
        guard let relatedSignalID = insight.relatedSignalID else { return nil }
        return analyticsSignalTrends.first(where: { $0.id == relatedSignalID })
    }

    func learnLessonState(for lessonID: String) -> LearnLessonState? {
        learnTopicStates
            .flatMap(\.lessons)
            .first(where: { $0.id == lessonID })
    }

    func nextLearnLessonState(after lessonID: String) -> LearnLessonState? {
        guard let currentLesson = learnLessonState(for: lessonID) else { return nil }

        if let nextLessonInTopic = learnTopicStates[currentLesson.topicIndex].lessons[safe: currentLesson.lessonIndex + 1] {
            return nextLessonInTopic.isUnlocked ? nextLessonInTopic : nil
        }

        let nextTopicIndex = currentLesson.topicIndex + 1
        guard let nextTopic = learnTopicStates[safe: nextTopicIndex] else { return nil }
        return nextTopic.lessons.first(where: \.isUnlocked)
    }

    func startOnboarding() {
        applySocialProfileDefaultsIfNeeded()
        currentStep = .signUp
        persistState()
    }

    func saveProfile(firstName: String, lastName: String, university: String, birthDate: Date?) {
        profile.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.lastName = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.university = university.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.birthDate = birthDate
        currentStep = .budget
        persistState()
    }

    @discardableResult
    func saveMonthlyBudget(from input: String) -> Bool {
        guard let amount = validatedMonthlyBudget(from: input) else {
            return false
        }

        profile.monthlyBudget = amount
        currentStep = .photo
        persistState()
        return true
    }

    @discardableResult
    func updateMonthlyBudget(from input: String) -> Bool {
        guard let amount = validatedMonthlyBudget(from: input) else {
            return false
        }

        profile.monthlyBudget = amount
        persistState()
        return true
    }

    func updateProfilePhoto(with data: Data?) {
        profile.profileImageData = data
        persistState()
    }

    func finishOnboarding() {
        currentStep = .home
        persistState()
    }

    func addIncome(amount: Double, note: String) {
        insertTransaction(amount: amount, note: note, type: .income, category: nil)
    }

    func addExpense(amount: Double, note: String, category: ExpenseCategory) {
        insertTransaction(amount: amount, note: note, type: .expense, category: category)
    }

    @discardableResult
    func addExpenseCategory(name: String, iconName: String) -> ExpenseCategory? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }

        let category = ExpenseCategory(name: trimmedName, iconName: iconName, isCustom: true)
        expenseCategories.append(category)
        persistState()
        return category
    }

    @discardableResult
    func updateExpenseCategory(_ category: ExpenseCategory, name: String, iconName: String) -> ExpenseCategory? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return nil }
        guard let index = expenseCategories.firstIndex(where: { $0.id == category.id }) else { return nil }

        let updatedCategory = ExpenseCategory(id: category.id, name: trimmedName, iconName: iconName, isCustom: category.isCustom)
        expenseCategories[index] = updatedCategory
        transactions = transactions.map { transaction in
            guard transaction.category?.id == category.id else { return transaction }
            return Transaction(
                id: transaction.id,
                amount: transaction.amount,
                note: transaction.note,
                date: transaction.date,
                type: transaction.type,
                category: updatedCategory
            )
        }
        persistState()
        return updatedCategory
    }

    func deleteExpenseCategory(_ category: ExpenseCategory) {
        guard category.isCustom else { return }
        expenseCategories.removeAll { $0.id == category.id }
        transactions = transactions.map { transaction in
            guard transaction.category?.id == category.id else { return transaction }
            return Transaction(
                id: transaction.id,
                amount: transaction.amount,
                note: transaction.note,
                date: transaction.date,
                type: transaction.type,
                category: nil
            )
        }
        persistState()
    }

    func expenses(for category: ExpenseCategory, withinLastDays days: Int = 7) -> [Transaction] {
        let startDate = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -(days - 1), to: .now) ?? .now)

        return transactions.filter { transaction in
            transaction.type == .expense &&
            transaction.category?.id == category.id &&
            transaction.date >= startDate
        }
    }

    func weeklyExpenseTotal(for category: ExpenseCategory) -> Double {
        expenses(for: category).map(\.amount).reduce(0, +)
    }

    func submitLessonAnswer(lessonID: String, selectedOptionIndex: Int) -> Bool {
        guard let lesson = lesson(for: lessonID) else { return false }
        let isCorrect = selectedOptionIndex == lesson.correctOptionIndex

        guard isCorrect else { return false }
        guard !lessonCompleted(lessonID) else { return true }

        learnProgress[lesson.id] = LearnLessonProgress(
            isCompleted: true,
            completedAt: .now,
            earnedXP: lesson.xp
        )
        updateQuestProgress()
        persistState()
        return true
    }

    /// Called by rich lesson views (LearnTab) when the user finishes
    /// a lesson that manages its own quiz and progression internally.
    func completeLesson(_ lessonID: String, earnedXP: Int) {
        guard lesson(for: lessonID) != nil else { return }
        guard !lessonCompleted(lessonID) else { return }
        learnProgress[lessonID] = LearnLessonProgress(
            isCompleted: true,
            completedAt: .now,
            earnedXP: earnedXP
        )
        updateQuestProgress()
        persistState()
    }


    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        socialService.prepareAppleRequest(request)
    }

    func signInWithApple(result: Result<ASAuthorization, Error>, nonce: String?) async {
        await runSocialAction {
            try await self.socialService.signInWithApple(result: result, nonce: nonce)
            try await self.syncRemoteProfileIfNeeded()
        }
    }

    func signInWithGoogle() async {
        await runSocialAction {
            try await self.socialService.signInWithGoogle()
            self.applySocialProfileDefaultsIfNeeded()
            try await self.syncRemoteProfileIfNeeded()
        }
    }

    func signInWithGoogleForOnboarding() async {
        let wasSignedIn = isSignedInToSocial
        await signInWithGoogle()
        guard isSignedInToSocial else { return }

        applySocialProfileDefaultsIfNeeded()
        if currentStep == .welcome || !wasSignedIn {
            currentStep = .signUp
            persistState()
        }
    }

    func signOutFromSocial() async {
        await runSocialAction {
            try self.socialService.signOut()
            self.socialGroupRecord = nil
            self.socialLeaderboardMembers = []
            self.socialChatMessages = []
        }
    }

    func createGroup(named name: String) async {
        await runSocialAction {
            try await self.socialService.createGroup(named: name, payload: self.socialProfilePayload)
        }
    }

    func joinGroup(inviteCode: String) async {
        await runSocialAction {
            try await self.socialService.joinGroup(inviteCode: inviteCode, payload: self.socialProfilePayload)
        }
    }

    func sendGroupMessage(_ text: String) async {
        await runSocialAction {
            let senderName = self.fullName.isEmpty ? self.socialAccountDisplayName : self.fullName
            try await self.socialService.sendMessage(text, senderName: senderName, senderInitials: self.initials)
        }
    }

    func markGroupChatAsRead() {
        guard let groupID = socialGroupRecord?.id else { return }
        let latestVisibleDate = socialChatMessages
            .filter { !$0.isCurrentUser }
            .map(\.sentAt)
            .max() ?? .now

        let currentReadAt = groupChatReadAt[groupID] ?? .distantPast
        guard latestVisibleDate > currentReadAt else { return }

        groupChatReadAt[groupID] = latestVisibleDate
        persistState()
    }

    private func configureSocialBindings() {
        socialService.onSessionChange = { [weak self] session in
            guard let self else { return }
            self.socialSession = session

            guard session != nil else {
                self.socialGroupRecord = nil
                self.socialLeaderboardMembers = []
                self.socialChatMessages = []
                return
            }

            Task { [weak self] in
                guard let self else { return }
                try? await self.syncRemoteProfileIfNeeded()
            }
        }

        socialService.onGroupChange = { [weak self] groupRecord in
            self?.socialGroupRecord = groupRecord
        }

        socialService.onMembersChange = { [weak self] members in
            guard let self else { return }
            self.socialLeaderboardMembers = members.map { member in
                let resolvedDisplayName = member.isCurrentUser && !self.fullName.isEmpty
                    ? self.fullName
                    : member.displayName

                return LeaderboardMemberState(
                    id: member.id,
                    displayName: resolvedDisplayName,
                    xp: member.xp,
                    level: member.level,
                    isCurrentUser: member.isCurrentUser,
                    imageData: member.imageData,
                    initials: member.initials
                )
            }
        }

        socialService.onMessagesChange = { [weak self] messages in
            guard let self else { return }
            self.socialChatMessages = messages.map { message in
                let resolvedSenderName = message.isCurrentUser && !self.fullName.isEmpty
                    ? self.fullName
                    : message.senderName

                return GroupChatMessageState(
                    id: message.id,
                    senderName: resolvedSenderName,
                    senderInitials: message.senderInitials,
                    body: message.body,
                    sentAt: message.sentAt,
                    isCurrentUser: message.isCurrentUser
                )
            }
        }

        socialService.onError = { [weak self] message in
            self?.socialAlert = SocialAlertState(title: "Backend", message: message)
        }
    }

    private func runSocialAction(_ operation: @escaping @MainActor () async throws -> Void) async {
        guard !isSocialActionInProgress else { return }
        isSocialActionInProgress = true
        defer { isSocialActionInProgress = false }

        do {
            try await operation()
        } catch {
            socialAlert = SocialAlertState(
                title: "Action failed",
                message: error.localizedDescription
            )
        }
    }

    private func syncRemoteProfileIfNeeded() async throws {
        guard isSignedInToSocial else { return }
        try await socialService.syncProfile(socialProfilePayload)
    }

    private func applySocialProfileDefaultsIfNeeded() {
        guard let rawSocialName = socialSession?.displayName else {
            return
        }

        let socialName = rawSocialName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !socialName.isEmpty,
              !socialName.contains("@") else {
            return
        }

        let parts = socialName
            .split(whereSeparator: { $0.isWhitespace })
            .map(String.init)

        guard let firstPart = parts.first else { return }

        var didChange = false

        if profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            profile.firstName = firstPart
            didChange = true
        }

        if profile.lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let remainingParts = parts.dropFirst().joined(separator: " ")
            if !remainingParts.isEmpty {
                profile.lastName = remainingParts
                didChange = true
            }
        }

        if didChange {
            persistState()
        }
    }

    private var socialProfilePayload: SocialProfilePayload {
        SocialProfilePayload(
            firstName: profile.firstName,
            lastName: profile.lastName,
            displayName: fullName.isEmpty ? (socialSession?.displayName ?? displayName) : fullName,
            university: profile.university,
            initials: initials,
            xp: totalXP,
            level: profileLevel,
            rankTitle: profileRankTitle,
            learningStreak: learnStreakDays,
            imageData: profile.profileImageData
        )
    }

    private var calendar: Calendar {
        Calendar.current
    }

    private var currentMonthInterval: DateInterval {
        calendar.dateInterval(of: .month, for: .now) ?? DateInterval(start: .now, duration: 86400 * 30)
    }

    private var currentMonthExpenseTotal: Double {
        transactions
            .filter { $0.type == .expense && currentMonthInterval.contains($0.date) }
            .map(\.amount)
            .reduce(0, +)
    }

    private var currentMonthIncomeTotal: Double {
        transactions
            .filter { $0.type == .income && currentMonthInterval.contains($0.date) }
            .map(\.amount)
            .reduce(0, +)
    }

    private var currentMonthAvailableFunds: Double {
        profile.monthlyBudget + currentMonthIncomeTotal
    }

    private var daysInCurrentMonth: Int {
        max(calendar.range(of: .day, in: .month, for: .now)?.count ?? 30, 1)
    }

    private var daysElapsedInCurrentMonth: Int {
        max((calendar.dateComponents([.day], from: currentMonthInterval.start, to: .now).day ?? 0) + 1, 1)
    }

    private var estimatedBudgetRunOutDate: Date? {
        let spentSoFar = currentMonthExpenseTotal
        let available = currentMonthAvailableFunds
        let elapsedDays = Double(daysElapsedInCurrentMonth)
        guard spentSoFar > 0, available > spentSoFar else { return nil }

        let dailyPace = spentSoFar / elapsedDays
        guard dailyPace > 0 else { return nil }

        let remaining = available - spentSoFar
        let daysUntilRunOut = remaining / dailyPace
        guard daysUntilRunOut < Double(daysInCurrentMonth - daysElapsedInCurrentMonth + 1) else { return nil }

        return calendar.date(byAdding: .day, value: Int(daysUntilRunOut.rounded(.up)), to: .now)
    }

    private var currentWeekInterval: DateInterval {
        calendar.dateInterval(of: .weekOfYear, for: .now) ?? DateInterval(start: .now, duration: 86400 * 7)
    }

    private var previousWeekInterval: DateInterval {
        let previousReferenceDate = calendar.date(byAdding: .day, value: -1, to: currentWeekInterval.start) ?? .now
        return calendar.dateInterval(of: .weekOfYear, for: previousReferenceDate) ?? DateInterval(
            start: currentWeekInterval.start.addingTimeInterval(-86400 * 7),
            duration: 86400 * 7
        )
    }

    private var currentWeekComparisonInterval: DateInterval {
        DateInterval(start: currentWeekInterval.start, end: .now)
    }

    private var previousWeekComparisonInterval: DateInterval {
        let elapsed = currentWeekComparisonInterval.duration
        return DateInterval(start: previousWeekInterval.start, end: previousWeekInterval.start.addingTimeInterval(elapsed))
    }

    private func validatedMonthlyBudget(from input: String) -> Double? {
        guard let amount = CurrencyFormatter.parseAmount(input), amount > 0 else {
            return nil
        }

        return amount
    }

    private func expenseTotal(in interval: DateInterval) -> Double {
        expenseTotal(from: interval.start, to: interval.end)
    }

    private func expenseTotal(from start: Date, to end: Date) -> Double {
        transactions
            .filter { transaction in
                transaction.type == .expense &&
                transaction.date >= start &&
                transaction.date < end
            }
            .map(\.amount)
            .reduce(0, +)
    }

    private func analyticsSignalDescriptor(for transaction: Transaction) -> (id: String, title: String, iconName: String)? {
        if let noteSignal = analyticsNoteSignal(from: transaction) {
            return noteSignal
        }

        guard let category = transaction.category else { return nil }
        return (
            id: "category-\(category.id.uuidString)",
            title: category.name,
            iconName: category.iconName
        )
    }

    private func analyticsNoteSignal(from transaction: Transaction) -> (id: String, title: String, iconName: String)? {
        let trimmedNote = transaction.note
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedNote.isEmpty, trimmedNote.count <= 24 else { return nil }

        let words = trimmedNote.split(separator: " ")
        let letters = trimmedNote.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count
        let digits = trimmedNote.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }.count
        let normalized = normalizeAnalyticsKey(trimmedNote)
        let excludedNotes = [
            "total spent", "expense", "spesa", "payment", "pagamento", "receipt", "ricevuta", "grocery"
        ]

        guard words.count <= 3, letters >= 3, digits == 0, !normalized.isEmpty else { return nil }
        guard !excludedNotes.contains(normalized) else { return nil }

        return (
            id: "note-\(normalized)",
            title: formattedAnalyticsTitle(trimmedNote),
            iconName: transaction.category?.iconName ?? "tag.fill"
        )
    }

    private func bestRisingSignal(from signals: [AnalyticsSignalTrend]) -> AnalyticsSignalTrend? {
        signals
            .filter { signal in
                signal.thisWeekAmount > signal.lastWeekAmount &&
                (signal.lastWeekAmount >= 5 || signal.thisWeekAmount >= 20)
            }
            .max { lhs, rhs in
                if lhs.deltaAmount == rhs.deltaAmount {
                    return lhs.thisWeekAmount < rhs.thisWeekAmount
                }
                return lhs.deltaAmount < rhs.deltaAmount
            }
    }

    private func percentChange(from previous: Double, to current: Double) -> Double? {
        guard previous > 0 else { return nil }
        return ((current - previous) / previous) * 100
    }

    private func formattedPercent(_ value: Double) -> String {
        if abs(value.rounded() - value) < 0.05 {
            return "\(Int(value.rounded()))%"
        }

        return String(format: "%.1f%%", value)
    }

    private func normalizeAnalyticsKey(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func formattedAnalyticsTitle(_ value: String) -> String {
        value
            .split(separator: " ")
            .map { word in
                guard let first = word.first else { return "" }
                return first.uppercased() + word.dropFirst().lowercased()
            }
            .joined(separator: " ")
    }

    private func lessonCompleted(_ lessonID: String) -> Bool {
        guard Self.validLearnLessonIDs.contains(lessonID) else { return false }
        return learnProgress[lessonID]?.isCompleted == true
    }

    private var validLearnProgress: [String: LearnLessonProgress] {
        learnProgress.filter { Self.validLearnLessonIDs.contains($0.key) }
    }

    private func previousTopicCompleted(before topicIndex: Int) -> Bool {
        guard topicIndex > 0 else { return true }
        let previousTopic = Self.learnTopicsCatalog[topicIndex - 1]
        return previousTopic.lessons.allSatisfy { lessonCompleted($0.id) }
    }

    private func lessonUnlocked(topicIndex: Int, lessonIndex: Int) -> Bool {
        guard lessonIndex > 0 else { return true }
        let previousLesson = Self.learnTopicsCatalog[topicIndex].lessons[lessonIndex - 1]
        return lessonCompleted(previousLesson.id)
    }

    private func lesson(for lessonID: String) -> LearnLesson? {
        Self.learnTopicsCatalog
            .flatMap(\.lessons)
            .first(where: { $0.id == lessonID })
    }

    private func questCompleted(_ questID: String) -> Bool {
        questProgress[questID]?.isCompleted == true
    }

    private func evaluateQuest(_ definition: QuestDefinition) -> (progressText: String, progressValue: Double, isCompleted: Bool) {
        switch definition.id {
        case "no-spend-day":
            let noSpendDays = noSpendDaysThisWeek
            return (
                progressText: "\(min(noSpendDays, 1))/1 day",
                progressValue: min(Double(noSpendDays), 1),
                isCompleted: noSpendDays >= 1
            )

        case "track-7-day-expense":
            let streak = expenseLoggingStreak
            return (
                progressText: "\(min(streak, 7))/7 days",
                progressValue: min(Double(streak) / 7, 1),
                isCompleted: streak >= 7
            )

        case "food-under-40":
            let spend = foodSpendThisWeek
            let transactions = foodExpenseCountThisWeek
            let cappedSpend = min(spend, 40)
            return (
                progressText: "\(CurrencyFormatter.string(from: cappedSpend)) / \(CurrencyFormatter.string(from: 40))",
                progressValue: min(cappedSpend / 40, 1),
                isCompleted: transactions >= 3 && spend <= 40
            )

        default:
            return (progressText: "0%", progressValue: 0, isCompleted: false)
        }
    }

    private var noSpendDaysThisWeek: Int {
        let expenseDays = Set(
            transactions
                .filter { $0.type == .expense && currentWeekInterval.contains($0.date) }
                .map { calendar.startOfDay(for: $0.date) }
        )

        guard !expenseDays.isEmpty else { return 0 }

        let start = calendar.startOfDay(for: currentWeekInterval.start)
        let end = calendar.startOfDay(for: .now)
        let dayCount = max((calendar.dateComponents([.day], from: start, to: end).day ?? 0) + 1, 0)

        return (0..<dayCount).reduce(0) { count, offset in
            guard let day = calendar.date(byAdding: .day, value: offset, to: start) else { return count }
            return expenseDays.contains(day) ? count : count + 1
        }
    }

    private var expenseLoggingStreak: Int {
        let expenseDays = Set(
            transactions
                .filter { $0.type == .expense }
                .map { calendar.startOfDay(for: $0.date) }
        )

        guard !expenseDays.isEmpty else { return 0 }

        let today = calendar.startOfDay(for: .now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today

        var cursor: Date
        if expenseDays.contains(today) {
            cursor = today
        } else if expenseDays.contains(yesterday) {
            cursor = yesterday
        } else {
            return 0
        }

        var streak = 0
        while expenseDays.contains(cursor) {
            streak += 1
            cursor = calendar.date(byAdding: .day, value: -1, to: cursor) ?? cursor
        }

        return streak
    }

    private var foodTransactionsThisWeek: [Transaction] {
        transactions.filter { transaction in
            transaction.type == .expense &&
            currentWeekInterval.contains(transaction.date) &&
            isFoodTransaction(transaction)
        }
    }

    private var foodSpendThisWeek: Double {
        foodTransactionsThisWeek.map(\.amount).reduce(0, +)
    }

    private var foodExpenseCountThisWeek: Int {
        foodTransactionsThisWeek.count
    }

    private func isFoodTransaction(_ transaction: Transaction) -> Bool {
        guard let category = transaction.category else { return false }

        let normalizedName = category.name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current).lowercased()
        return normalizedName.contains("grocery") ||
            normalizedName.contains("food") ||
            category.iconName == "cart.fill" ||
            category.iconName == "fork.knife"
    }

    private func updateQuestProgress() {
        for definition in Self.questCatalog where !questCompleted(definition.id) {
            let evaluation = evaluateQuest(definition)
            guard evaluation.isCompleted else { continue }

            questProgress[definition.id] = QuestProgress(
                isCompleted: true,
                completedAt: .now,
                earnedXP: definition.xp
            )
        }
    }

    private func insertTransaction(amount: Double, note: String, type: TransactionType, category: ExpenseCategory?) {
        let value = abs(amount)
        guard value > 0 else { return }

        transactions.insert(
            Transaction(
                amount: value,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                date: .now,
                type: type,
                category: category
            ),
            at: 0
        )
        updateQuestProgress()
        persistState()
    }

    private func loadPersistedState() {
        guard let data = UserDefaults.standard.data(forKey: Self.persistedStateKey) else { return }

        do {
            let decodedState = try JSONDecoder().decode(PersistedAppState.self, from: data)
            profile = decodedState.profile
            currentStep = decodedState.currentStep
            transactions = decodedState.transactions
            expenseCategories = mergedExpenseCategories(with: decodedState.expenseCategories)
            learnProgress = decodedState.learnProgress
            questProgress = decodedState.questProgress
            groupChatReadAt = decodedState.groupChatReadAt
            updateQuestProgress()
        } catch {
            expenseCategories = ExpenseCategory.predefined
            learnProgress = [:]
            questProgress = [:]
            groupChatReadAt = [:]
        }
    }

    private func mergedExpenseCategories(with storedCategories: [ExpenseCategory]) -> [ExpenseCategory] {
        guard !storedCategories.isEmpty else {
            return ExpenseCategory.predefined
        }

        let storedCategoryNames = Set(storedCategories.map { normalizedCategoryName($0.name) })
        let missingPredefinedCategories = ExpenseCategory.predefined.filter {
            !storedCategoryNames.contains(normalizedCategoryName($0.name))
        }

        return storedCategories + missingPredefinedCategories
    }

    private func normalizedCategoryName(_ name: String) -> String {
        name
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func persistState() {
        guard persistenceEnabled else { return }

        let persistedState = PersistedAppState(
            profile: profile,
            currentStep: currentStep,
            transactions: transactions,
            expenseCategories: expenseCategories,
            learnProgress: learnProgress,
            questProgress: questProgress,
            groupChatReadAt: groupChatReadAt
        )

        do {
            let data = try JSONEncoder().encode(persistedState)
            UserDefaults.standard.set(data, forKey: Self.persistedStateKey)
        } catch {
            assertionFailure("Failed to persist BudgetPlanner state: \(error)")
        }

        Task { [weak self] in
            guard let self else { return }
            try? await self.syncRemoteProfileIfNeeded()
        }
    }

    private struct QuestDefinition {
        let id: String
        let title: String
        let subtitle: String
        let iconName: String
        let xp: Int
    }

    private struct MockLeaderboardMember {
        let id: String
        let displayName: String
        let initials: String
        let xp: Int
    }

    private static let mockLeaderboardMembers: [MockLeaderboardMember] = [
        MockLeaderboardMember(id: "friend-elena", displayName: "Elena Russo", initials: "ER", xp: 380),
        MockLeaderboardMember(id: "friend-marco", displayName: "Marco D'Amico", initials: "MD", xp: 290),
        MockLeaderboardMember(id: "friend-giulia", displayName: "Giulia Conti", initials: "GC", xp: 240),
        MockLeaderboardMember(id: "friend-luca", displayName: "Luca Ferraro", initials: "LF", xp: 130)
    ]

    private static let questCatalog: [QuestDefinition] = [
        QuestDefinition(
            id: "no-spend-day",
            title: "No spend day",
            subtitle: "Keep one day this week free from expenses",
            iconName: "flame.fill",
            xp: 50
        ),
        QuestDefinition(
            id: "track-7-day-expense",
            title: "Track 7 day expense",
            subtitle: "Log expenses for 7 consecutive days",
            iconName: "flame.fill",
            xp: 150
        ),
        QuestDefinition(
            id: "food-under-40",
            title: "Food under €40",
            subtitle: "Stay under €40 on food this week",
            iconName: "leaf.fill",
            xp: 70
        )
    ]

    private static let learnTopicsCatalog: [LearnTopic] = [
        LearnTopic(
            id: "cashflow-basics",
            title: "Cashflow Basics",
            subtitle: "Learn the rhythm of your money",
            iconName: "chart.bar.fill",
            lessons: [
                LearnLesson(id: "cashflow-detective", title: "Cashflow Detective", subtitle: "Why do you feel broke before payday?", xp: 50, iconName: "magnifyingglass", contentSections: [], quizQuestion: "", quizOptions: [], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "expense-tracking-topic",
            title: "Expense Tracking",
            subtitle: "See where your money actually goes",
            iconName: "scope",
            lessons: [
                LearnLesson(id: "expense-tracking", title: "Expense Tracking", subtitle: "Where does your money really go?", xp: 60, iconName: "scope", contentSections: [], quizQuestion: "", quizOptions: [], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "realistic-budget-topic",
            title: "Realistic Budget",
            subtitle: "Build a plan you can actually keep",
            iconName: "building.columns.fill",
            lessons: [
                LearnLesson(id: "realistic-budget", title: "Realistic Budget", subtitle: "Budgets fail because they are unrealistic.", xp: 70, iconName: "target", contentSections: [], quizQuestion: "", quizOptions: [], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "fixed-costs-topic",
            title: "Fixed Costs & Subscriptions",
            subtitle: "Stop the quiet money leaks",
            iconName: "apps.iphone",
            lessons: [
                LearnLesson(id: "fixed-costs", title: "Fixed Costs", subtitle: "Recurring costs quietly reduce flexibility.", xp: 75, iconName: "creditcard", contentSections: [], quizQuestion: "", quizOptions: [], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "goal-based-saving-topic",
            title: "Goal-Based Saving",
            subtitle: "Give your money a clear purpose",
            iconName: "target",
            lessons: [
                LearnLesson(id: "goal-based-saving", title: "Goal-Based Saving", subtitle: "Saving works best when it's a plan — not a leftover.", xp: 80, iconName: "flag.fill", contentSections: [], quizQuestion: "", quizOptions: [], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "emergency-buffer-topic",
            title: "Emergency Buffer",
            subtitle: "Build your financial safety net",
            iconName: "shield.fill",
            lessons: [
                LearnLesson(id: "emergency-buffer", title: "Emergency Buffer", subtitle: "A small buffer prevents big panic decisions.", xp: 85, iconName: "shield.lefthalf.filled", contentSections: [], quizQuestion: "", quizOptions: [], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "trade-offs-topic",
            title: "Smart Spending Decisions",
            subtitle: "Master the art of trade-offs",
            iconName: "arrow.left.and.right",
            lessons: [
                LearnLesson(id: "trade-offs", title: "Trade-offs", subtitle: "Every yes is a no to something else.", xp: 90, iconName: "scalemass.fill", contentSections: [], quizQuestion: "", quizOptions: [], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "impulse-spending-topic",
            title: "Impulse & Social Spending",
            subtitle: "Master your triggers & habits",
            iconName: "bolt.fill",
            lessons: [
                LearnLesson(id: "impulse-spending", title: "Impulse Spending", subtitle: "Impulse spending is a pattern with triggers.", xp: 95, iconName: "bolt.circle.fill", contentSections: [], quizQuestion: "", quizOptions: [], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "debt-basics-topic",
            title: "Credit & Debt",
            subtitle: "Master your repayment plan",
            iconName: "creditcard.fill",
            lessons: [
                LearnLesson(id: "debt-basics", title: "Debt Basics", subtitle: "Debt payments are part of your budget.", xp: 100, iconName: "creditcard.and.123", contentSections: [], quizQuestion: "", quizOptions: [], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "investing-101",
            title: "Investing 101",
            subtitle: "Start your investment journey",
            iconName: "chart.line.uptrend.xyaxis.circle.fill",
            lessons: [
                LearnLesson(
                    id: "impulse-buys",
                    title: "Impulse buys",
                    subtitle: "Slow down small unplanned spending.",
                    xp: 20,
                    iconName: "bolt.fill",
                    contentSections: [
                        "Impulse spending usually feels small in the moment and expensive in the monthly total.",
                        "A pause rule, like waiting 24 hours before a non-essential purchase, removes many weak decisions."
                    ],
                    quizQuestion: "What helps reduce impulse spending?",
                    quizOptions: [
                        "Adding a waiting period before buying",
                        "Hiding all your budget categories",
                        "Ignoring your account balance"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "student-discounts",
                    title: "Student discounts",
                    subtitle: "Stretch the same budget further.",
                    xp: 20,
                    iconName: "tag.fill",
                    contentSections: [
                        "Student discounts increase spending efficiency without asking you to give up what you use.",
                        "Transport, food, software, and culture often have dedicated student pricing."
                    ],
                    quizQuestion: "Why are student discounts valuable?",
                    quizOptions: [
                        "They lower costs without changing the category itself",
                        "They replace savings completely",
                        "They only matter for luxury purchases"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "why-invest-early",
                    title: "Why invest early",
                    subtitle: "Time matters more than size at first.",
                    xp: 20,
                    iconName: "clock.fill",
                    contentSections: [
                        "Investing early gives compounding more time to work.",
                        "Starting small is still valuable because the habit and time horizon matter a lot."
                    ],
                    quizQuestion: "What is the main advantage of starting to invest early?",
                    quizOptions: [
                        "Your money has more time to compound",
                        "It removes all investment risk",
                        "You never need savings again"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "compound-growth",
                    title: "Compound growth",
                    subtitle: "Growth on top of growth.",
                    xp: 20,
                    iconName: "chart.line.uptrend.xyaxis",
                    contentSections: [
                        "Compound growth happens when your returns begin generating their own returns over time.",
                        "It looks slow at the beginning and stronger later, which is why patience matters."
                    ],
                    quizQuestion: "What best describes compounding?",
                    quizOptions: [
                        "Returns earning more returns over time",
                        "Spending more each month",
                        "Keeping all money in cash forever"
                    ],
                    correctOptionIndex: 0
                )
            ]
        )
    ]

    private static let validLearnLessonIDs = Set(
        learnTopicsCatalog
            .flatMap(\.lessons)
            .map(\.id)
    )

    static var preview: BudgetPlannerStore {
        let store = BudgetPlannerStore(loadPersistedState: false)
        store.profile = UserProfile(
            firstName: "Sabrina",
            lastName: "Mancini",
            university: "University of Naples Federico II",
            monthlyBudget: 800,
            profileImageData: nil
        )
        store.expenseCategories = ExpenseCategory.predefined
        store.transactions = [
            Transaction(
                amount: 18,
                note: "Coffee",
                date: .now.addingTimeInterval(-3600),
                type: .expense,
                category: store.expenseCategories.first(where: { $0.name == "Entertainment" })
            ),
            Transaction(
                amount: 12,
                note: "Coffee",
                date: .now.addingTimeInterval(-86400 * 2),
                type: .expense,
                category: store.expenseCategories.first(where: { $0.name == "Entertainment" })
            ),
            Transaction(
                amount: 42,
                note: "Groceries",
                date: .now.addingTimeInterval(-86400),
                type: .expense,
                category: store.expenseCategories.first(where: { $0.name == "Grocery" })
            ),
            Transaction(
                amount: 460,
                note: "Part-time job",
                date: .now.addingTimeInterval(-7200),
                type: .income,
                category: nil
            )
        ]
        store.learnProgress = [
            "cashflow-detective": LearnLessonProgress(
                isCompleted: true,
                completedAt: .now.addingTimeInterval(-86400),
                earnedXP: 50
            ),
            "expense-tracking": LearnLessonProgress(
                isCompleted: true,
                completedAt: .now,
                earnedXP: 60
            )
        ]
        store.currentStep = .home
        return store
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
