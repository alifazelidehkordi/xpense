import re

with open("BudgetPlanner/Models/BudgetPlannerStore.swift", "r") as f:
    content = f.read()

start_marker = "    private static let learnTopicsCatalog: [LearnTopic] = ["
end_marker = "    static let preview = BudgetPlannerStore(profile: Profile("

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx != -1 and end_idx != -1:
    old_catalog_section = content[start_idx:end_idx]
    
    # We will replace it with the new exactly 13-lesson structure
    new_catalog = """    private static let learnTopicsCatalog: [LearnTopic] = [
        LearnTopic(
            id: "cashflow-basics",
            title: "Cashflow Basics",
            subtitle: "Learn the rhythm of your money",
            iconName: "chart.bar.fill",
            lessons: [
                LearnLesson(id: "cashflow-detective", title: "Cashflow Detective", subtitle: "Why do you feel broke before payday?", xp: 50, iconName: "magnifyingglass", contentSections: [], quizQuestion: "If rent is due before payday, what risk happens?", quizOptions: ["A. You earn less money", "B. A cashflow gap", "C. Spending disappears"], correctOptionIndex: 1)
            ]
        ),
        LearnTopic(
            id: "expense-tracking-topic",
            title: "Expense Tracking",
            subtitle: "See where your money actually goes",
            iconName: "scope",
            lessons: [
                LearnLesson(id: "expense-tracking", title: "Expense Tracking", subtitle: "Where does your money really go?", xp: 60, iconName: "scope", contentSections: [], quizQuestion: "Which type of spending is usually easier to reduce?", quizOptions: ["A. Fixed expenses", "B. Variable expenses"], correctOptionIndex: 1)
            ]
        ),
        LearnTopic(
            id: "realistic-budget-topic",
            title: "Realistic Budget",
            subtitle: "Build a plan you can actually keep",
            iconName: "building.columns.fill",
            lessons: [
                LearnLesson(id: "realistic-budget", title: "Realistic Budget", subtitle: "Budgets fail because they are unrealistic.", xp: 70, iconName: "target", contentSections: [], quizQuestion: "What is a safer first budget reduction?", quizOptions: ["A. 10%", "B. 60%"], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "fixed-costs-topic",
            title: "Fixed Costs & Subscriptions",
            subtitle: "Stop the quiet money leaks",
            iconName: "apps.iphone",
            lessons: [
                LearnLesson(id: "fixed-costs", title: "Fixed Costs", subtitle: "Recurring costs quietly reduce flexibility.", xp: 75, iconName: "creditcard", contentSections: [], quizQuestion: "Which is usually harder to reduce quickly?", quizOptions: ["A. Fixed costs", "B. Variable costs"], correctOptionIndex: 0)
            ]
        ),
        LearnTopic(
            id: "goal-based-saving-topic",
            title: "Goal-Based Saving",
            subtitle: "Give your money a clear purpose",
            iconName: "target",
            lessons: [
                LearnLesson(id: "goal-based-saving", title: "Goal-Based Saving", subtitle: "Saving works best when it's a plan — not a leftover.", xp: 80, iconName: "flag.fill", contentSections: [], quizQuestion: "What makes saving more reliable?", quizOptions: ["A. Saving what is left at the end", "B. Scheduling the saving first"], correctOptionIndex: 1)
            ]
        ),
        LearnTopic(
            id: "emergency-buffer-topic",
            title: "Emergency Buffer",
            subtitle: "Build your financial safety net",
            iconName: "shield.fill",
            lessons: [
                LearnLesson(id: "emergency-buffer", title: "Emergency Buffer", subtitle: "A small buffer prevents big panic decisions.", xp: 85, iconName: "shield.lefthalf.filled", contentSections: [], quizQuestion: "Which situation is closer to a real emergency?", quizOptions: ["A. Phone charger broke", "B. Rent due and account short", "C. Flash sale online"], correctOptionIndex: 1)
            ]
        ),
        LearnTopic(
            id: "trade-offs-topic",
            title: "Smart Spending Decisions",
            subtitle: "Master the art of trade-offs",
            iconName: "arrow.left.and.right",
            lessons: [
                LearnLesson(id: "trade-offs", title: "Trade-offs", subtitle: "Every yes is a no to something else.", xp: 90, iconName: "scalemass.fill", contentSections: [], quizQuestion: "Opportunity cost means:", quizOptions: ["A. A hidden fee", "B. What you give up when you choose something"], correctOptionIndex: 1)
            ]
        ),
        LearnTopic(
            id: "impulse-spending-topic",
            title: "Impulse & Social Spending",
            subtitle: "Master your triggers & habits",
            iconName: "bolt.fill",
            lessons: [
                LearnLesson(id: "impulse-spending", title: "Impulse Spending", subtitle: "Impulse spending is a pattern with triggers.", xp: 95, iconName: "bolt.circle.fill", contentSections: [], quizQuestion: "Which strategy usually works better?", quizOptions: ["A. \\"I'll just try harder\\"", "B. A specific If–Then plan"], correctOptionIndex: 1)
            ]
        ),
        LearnTopic(
            id: "debt-basics-topic",
            title: "Credit & Debt",
            subtitle: "Master your repayment plan",
            iconName: "creditcard.fill",
            lessons: [
                LearnLesson(id: "debt-basics", title: "Debt Basics", subtitle: "Debt payments are part of your budget.", xp: 100, iconName: "creditcard.and.123", contentSections: [], quizQuestion: "What usually happens if you only pay the minimum?", quizOptions: ["A. Debt ends quickly", "B. You often pay longer and more in total"], correctOptionIndex: 1)
            ]
        ),
        LearnTopic(
            id: "smart-spending",
            title: "Smart Spending",
            subtitle: "Spend wisely as a student",
            iconName: "bag.fill",
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
                        "They replace savings completely"
                    ],
                    correctOptionIndex: 0
                )
            ]
        ),
        LearnTopic(
            id: "investing-101",
            title: "Investing 101",
            subtitle: "Start your investment journey",
            iconName: "chart.line.uptrend.xyaxis.circle.fill",
            lessons: [
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
                        "It removes all investment risk"
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
                        "Spending more each month"
                    ],
                    correctOptionIndex: 0
                )
            ]
        )
    ]

    // MARK: - App State

"""
    
    # We must find the last closing brace before preview.
    # Actually just taking everything up to `    // MARK: - App State\n` in the old text.
    old_end = content.find("    // MARK: - App State\n")
    if old_end != -1:
        new_content = content[:start_idx] + new_catalog + content[old_end:]
        with open("BudgetPlanner/Models/BudgetPlannerStore.swift", "w") as f:
            f.write(new_content)
        print("Success")
    else:
        print("Could not find App State marker")
else:
    print("Could not find markers")

