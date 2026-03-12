import Foundation
import Testing
@testable import XPense

@MainActor
struct BudgetPlannerTests {
    @Test func learnSummariesIgnoreStaleProgressEntries() async throws {
        let store = BudgetPlannerStore(loadPersistedState: false)

        store.learnProgress = [
            "cashflow-detective": LearnLessonProgress(
                isCompleted: true,
                completedAt: .now,
                earnedXP: 50
            ),
            "what-is-a-budget": LearnLessonProgress(
                isCompleted: true,
                completedAt: .now,
                earnedXP: 999
            )
        ]

        #expect(store.completedLessonCount == 1)
        #expect(store.learnTotalXP == 50)
        #expect(store.lessonsCompletedToday == 1)
        #expect(store.learnCompletionPercentage == Int((Double(1) / Double(store.totalLessonCount) * 100).rounded()))
    }

    @Test func completeLessonIgnoresUnknownLessonIDs() async throws {
        let store = BudgetPlannerStore(loadPersistedState: false)

        store.completeLesson("missing-lesson", earnedXP: 250)

        #expect(store.learnProgress.isEmpty)
        #expect(store.completedLessonCount == 0)
        #expect(store.learnTotalXP == 0)
    }

    @Test func learnProgressionUnlocksNextTopicAfterCompletion() async throws {
        let store = BudgetPlannerStore(loadPersistedState: false)

        #expect(store.learnLessonState(for: "cashflow-detective")?.isUnlocked == true)
        #expect(store.learnLessonState(for: "expense-tracking")?.isUnlocked == false)

        store.completeLesson("cashflow-detective", earnedXP: 50)

        let nextLesson = store.nextLearnLessonState(after: "cashflow-detective")
        #expect(nextLesson?.id == "expense-tracking")
        #expect(store.learnLessonState(for: "expense-tracking")?.isUnlocked == true)
    }
}
