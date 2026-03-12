import Foundation

extension BudgetPlannerStore {
    static let learnTopicsCatalog: [LearnTopic] = [
        LearnTopic(
            id: "cashflow-basics",
            title: "Cashflow Basics",
            subtitle: "Learn the rhythm of your money",
            iconName: "chart.bar.fill",
            lessons: [
                LearnLesson(
                    id: "cashflow-detective",
                    title: "Cashflow Detective",
                    subtitle: "Why do you feel broke before payday?",
                    xp: 50,
                    iconName: "magnifyingglass",
                    contentSections: [],
                    quizQuestion: "If rent is due before payday, what risk happens?",
                    quizOptions: ["A. You earn less money", "B. A cashflow gap", "C. Spending disappears"],
                    correctOptionIndex: 1
                )
            ]
        ),
        LearnTopic(
            id: "expense-tracking-topic",
            title: "Expense Tracking",
            subtitle: "See where your money actually goes",
            iconName: "scope",
            lessons: [
                LearnLesson(
                    id: "expense-tracking",
                    title: "Expense Tracking",
                    subtitle: "Where does your money really go?",
                    xp: 60,
                    iconName: "scope",
                    contentSections: [],
                    quizQuestion: "Which type of spending is usually easier to reduce?",
                    quizOptions: ["A. Fixed expenses", "B. Variable expenses"],
                    correctOptionIndex: 1
                )
            ]
        ),
        LearnTopic(
            id: "realistic-budget-topic",
            title: "Realistic Budget",
            subtitle: "Build a plan you can actually keep",
            iconName: "building.columns.fill",
            lessons: [
                LearnLesson(
                    id: "realistic-budget",
                    title: "Realistic Budget",
                    subtitle: "Budgets fail because they are unrealistic.",
                    xp: 70,
                    iconName: "target",
                    contentSections: [],
                    quizQuestion: "What is a safer first budget reduction?",
                    quizOptions: ["A. 10%", "B. 60%"],
                    correctOptionIndex: 0
                )
            ]
        ),
        LearnTopic(
            id: "fixed-costs-topic",
            title: "Fixed Costs & Subscriptions",
            subtitle: "Stop the quiet money leaks",
            iconName: "apps.iphone",
            lessons: [
                LearnLesson(
                    id: "fixed-costs",
                    title: "Fixed Costs",
                    subtitle: "Recurring costs quietly reduce flexibility.",
                    xp: 75,
                    iconName: "creditcard",
                    contentSections: [],
                    quizQuestion: "Which is usually harder to reduce quickly?",
                    quizOptions: ["A. Fixed costs", "B. Variable costs"],
                    correctOptionIndex: 0
                )
            ]
        ),
        LearnTopic(
            id: "goal-based-saving-topic",
            title: "Goal-Based Saving",
            subtitle: "Give your money a clear purpose",
            iconName: "target",
            lessons: [
                LearnLesson(
                    id: "goal-based-saving",
                    title: "Goal-Based Saving",
                    subtitle: "Saving works best when it's a plan — not a leftover.",
                    xp: 80,
                    iconName: "flag.fill",
                    contentSections: [],
                    quizQuestion: "What makes saving more reliable?",
                    quizOptions: ["A. Saving what is left at the end", "B. Scheduling the saving first"],
                    correctOptionIndex: 1
                )
            ]
        ),
        LearnTopic(
            id: "emergency-buffer-topic",
            title: "Emergency Buffer",
            subtitle: "Build your financial safety net",
            iconName: "shield.fill",
            lessons: [
                LearnLesson(
                    id: "emergency-buffer",
                    title: "Emergency Buffer",
                    subtitle: "A small buffer prevents big panic decisions.",
                    xp: 85,
                    iconName: "shield.lefthalf.filled",
                    contentSections: [],
                    quizQuestion: "Which situation is closer to a real emergency?",
                    quizOptions: ["A. Phone charger broke", "B. Rent due and account short", "C. Flash sale online"],
                    correctOptionIndex: 1
                )
            ]
        ),
        LearnTopic(
            id: "trade-offs-topic",
            title: "Smart Spending Decisions",
            subtitle: "Master the art of trade-offs",
            iconName: "arrow.left.and.right",
            lessons: [
                LearnLesson(
                    id: "trade-offs",
                    title: "Trade-offs",
                    subtitle: "Every yes is a no to something else.",
                    xp: 90,
                    iconName: "decisionmaker",
                    contentSections: [],
                    quizQuestion: "Opportunity cost means:",
                    quizOptions: ["A. A hidden fee", "B. What you give up when you choose something"],
                    correctOptionIndex: 1
                )
            ]
        ),
        LearnTopic(
            id: "impulse-spending-topic",
            title: "Impulse & Social Spending",
            subtitle: "Master your triggers & habits",
            iconName: "bolt.fill",
            lessons: [
                LearnLesson(
                    id: "impulse-spending",
                    title: "Impulse Spending",
                    subtitle: "Impulse spending is a pattern with triggers.",
                    xp: 95,
                    iconName: "lightning.circle",
                    contentSections: [],
                    quizQuestion: "Which strategy usually works better?",
                    quizOptions: ["A. “I’ll just try harder”", "B. A specific If–Then plan"],
                    correctOptionIndex: 1
                )
            ]
        ),
        LearnTopic(
            id: "debt-basics-topic",
            title: "Credit & Debt",
            subtitle: "Master your repayment plan",
            iconName: "creditcard.fill",
            lessons: [
                LearnLesson(
                    id: "debt-basics",
                    title: "Debt Basics",
                    subtitle: "Debt payments are part of your budget.",
                    xp: 100,
                    iconName: "creditcard.and.123",
                    contentSections: [],
                    quizQuestion: "What usually happens if you only pay the minimum?",
                    quizOptions: ["A. Debt ends quickly", "B. You often pay longer and more in total"],
                    correctOptionIndex: 1
                )
            ]
        ),
        LearnTopic(
            id: "budgeting-basics",
            title: "Budgeting Basics",
            subtitle: "Master the foundation of budgeting",
            iconName: "chart.pie.fill",
            lessons: [
                LearnLesson(
                    id: "what-is-a-budget",
                    title: "What is budget?",
                    subtitle: "See why a budget gives your money a clear job.",
                    xp: 20,
                    iconName: "wallet.pass.fill",
                    contentSections: [
                        "A budget is a simple plan for where your money should go before the month starts.",
                        "Instead of asking where your money went, budgeting lets you decide in advance what matters most.",
                        "Even a small student budget works better when rent, food, transport, and fun each have a limit."
                    ],
                    quizQuestion: "What is the main purpose of a budget?",
                    quizOptions: [
                        "To plan how your money will be used",
                        "To avoid checking your bank account",
                        "To spend everything before month-end"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "rule-50-30-20",
                    title: "50/30/20 rule",
                    subtitle: "A fast framework for splitting income.",
                    xp: 20,
                    iconName: "circle.grid.3x3.fill",
                    contentSections: [
                        "The 50/30/20 rule is a starting point: about 50% for needs, 30% for wants, and 20% for savings or debt goals.",
                        "It does not need to be exact, especially as a student. Rent can push your needs higher, and that is normal.",
                        "The value is in giving each euro a role instead of treating all money as one big pile."
                    ],
                    quizQuestion: "In the 50/30/20 rule, what does the 20 usually represent?",
                    quizOptions: [
                        "Savings or debt reduction",
                        "Entertainment spending",
                        "Daily transport"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "tracking-expenses",
                    title: "Tracking expenses",
                    subtitle: "Why tracking removes financial guesswork.",
                    xp: 20,
                    iconName: "list.bullet.clipboard.fill",
                    contentSections: [
                        "People often avoid money tracking because they think it feels restrictive or tiring.",
                        "In practice, tracking creates awareness. You see small repeated costs before they silently become a habit.",
                        "Once you know your real spending pattern, it becomes much easier to adjust only the categories that matter."
                    ],
                    quizQuestion: "Why does tracking expenses help most?",
                    quizOptions: [
                        "It shows repeated spending patterns clearly",
                        "It makes every purchase free",
                        "It removes the need for a budget"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "budget-categories",
                    title: "Budget categories",
                    subtitle: "Use categories so decisions are easier.",
                    xp: 20,
                    iconName: "square.grid.2x2.fill",
                    contentSections: [
                        "Categories turn one big spending total into smaller, easier decisions.",
                        "When groceries and clothing are separated, you can react precisely instead of just feeling that you spent too much.",
                        "Good categories are simple, consistent, and easy to remember each time you log an expense."
                    ],
                    quizQuestion: "What is the main benefit of categories?",
                    quizOptions: [
                        "They make overspending easier to spot",
                        "They increase your income automatically",
                        "They remove all bills"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "monthly-review",
                    title: "Monthly review",
                    subtitle: "Close the loop and improve next month.",
                    xp: 20,
                    iconName: "calendar.badge.checkmark",
                    contentSections: [
                        "A monthly review helps you compare the budget you planned with the life you actually lived.",
                        "Look for categories that were always under pressure and categories where money was left unused.",
                        "The goal is not perfection. The goal is a slightly smarter plan for the next month."
                    ],
                    quizQuestion: "What should a monthly review help you do?",
                    quizOptions: [
                        "Adjust next month using real spending data",
                        "Delete all old transactions",
                        "Ignore categories completely"
                    ],
                    correctOptionIndex: 0
                )
            ]
        ),
        LearnTopic(
            id: "saving-strategies",
            title: "Saving Strategies",
            subtitle: "Learn smart ways to grow spare money",
            iconName: "banknote.fill",
            lessons: [
                LearnLesson(
                    id: "pay-yourself-first",
                    title: "Pay yourself first",
                    subtitle: "Save before spending the rest.",
                    xp: 20,
                    iconName: "banknote.fill",
                    contentSections: [
                        "Saving works better when it happens at the beginning of the month, not with whatever is left at the end.",
                        "Even a small automatic amount builds momentum and reduces decision fatigue.",
                        "Consistency matters more than size at the start."
                    ],
                    quizQuestion: "What does pay yourself first mean?",
                    quizOptions: [
                        "Move money to savings before flexible spending",
                        "Spend more on yourself before bills",
                        "Only save if money is left over"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "emergency-fund",
                    title: "Emergency fund",
                    subtitle: "Create a buffer for surprises.",
                    xp: 20,
                    iconName: "shield.fill",
                    contentSections: [
                        "An emergency fund protects you from turning unexpected costs into debt.",
                        "Student emergencies are usually smaller than full adult household costs, but they still matter: repairs, travel, health, or tech problems.",
                        "A small buffer is still powerful because it buys time and options."
                    ],
                    quizQuestion: "Why is an emergency fund useful?",
                    quizOptions: [
                        "It covers unexpected costs without panic",
                        "It replaces your monthly budget",
                        "It guarantees investment returns"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "saving-habits",
                    title: "Saving habits",
                    subtitle: "Use systems instead of willpower.",
                    xp: 20,
                    iconName: "sparkles",
                    contentSections: [
                        "Good saving habits are small systems you can repeat, like rounding up purchases or moving leftover weekly money into savings.",
                        "Habits beat motivation because they continue on low-energy days.",
                        "The easiest savings plan is the one you do without having to negotiate with yourself each time."
                    ],
                    quizQuestion: "What makes a saving habit strong?",
                    quizOptions: [
                        "It is easy to repeat consistently",
                        "It depends on feeling motivated every day",
                        "It only happens once a year"
                    ],
                    correctOptionIndex: 0
                )
            ]
        ),
        LearnTopic(
            id: "smart-spending",
            title: "Smart Spending",
            subtitle: "Spend wisely as a student",
            iconName: "bag.fill",
            lessons: [
                LearnLesson(
                    id: "needs-vs-wants",
                    title: "Needs vs wants",
                    subtitle: "Spend with priority, not impulse.",
                    xp: 20,
                    iconName: "checkmark.seal.fill",
                    contentSections: [
                        "Needs keep your life stable. Wants improve comfort or fun.",
                        "Neither is automatically bad, but confusing them makes planning harder.",
                        "When money feels tight, clear priorities reduce stress because you know what must stay protected."
                    ],
                    quizQuestion: "Which example is most likely a need?",
                    quizOptions: [
                        "Monthly transport to university",
                        "A second pair of sneakers this month",
                        "Extra streaming subscriptions"
                    ],
                    correctOptionIndex: 0
                ),
                LearnLesson(
                    id: "impulse-buys",
                    title: "Impulse buys",
                    subtitle: "Slow down small unplanned spending.",
                    xp: 20,
                    iconName: "bolt.fill",
                    contentSections: [
                        "Impulse spending usually feels small in the moment and expensive in the monthly total.",
                        "A pause rule, like waiting 24 hours before a non-essential purchase, removes many weak decisions.",
                        "The goal is not to remove enjoyment. It is to reduce automatic spending."
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
                        "Transport, food, software, and culture often have dedicated student pricing.",
                        "A smart spender looks for lower prices before cutting useful categories."
                    ],
                    quizQuestion: "Why are student discounts valuable?",
                    quizOptions: [
                        "They lower costs without changing the category itself",
                        "They replace savings completely",
                        "They only matter for luxury purchases"
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
                        "Starting small is still valuable because the habit and time horizon matter a lot.",
                        "You should only invest money that is not needed soon for rent, food, or emergencies."
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
                    id: "risk-and-diversification",
                    title: "Risk and diversification",
                    subtitle: "Do not depend on one outcome.",
                    xp: 20,
                    iconName: "triangle.fill",
                    contentSections: [
                        "Risk is the possibility that an investment will not behave the way you hoped.",
                        "Diversification spreads your exposure across different assets so one bad result hurts less.",
                        "It does not remove risk, but it makes it more manageable."
                    ],
                    quizQuestion: "What does diversification mainly do?",
                    quizOptions: [
                        "Spreads risk across different investments",
                        "Guarantees profits every month",
                        "Eliminates price changes"
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
                        "It looks slow at the beginning and stronger later, which is why patience matters.",
                        "The key lesson is that time and consistency often beat trying to time every move perfectly."
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
}
