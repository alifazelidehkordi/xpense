import Foundation

struct CategoryIconChoice: Identifiable, Hashable {
    let symbolName: String
    let label: String

    var id: String { symbolName }
}

enum TransactionType: String, CaseIterable, Identifiable, Codable {
    case expense
    case income

    var id: String { rawValue }

    var title: String {
        switch self {
        case .expense:
            return "Expense"
        case .income:
            return "Income"
        }
    }

    var symbolName: String {
        switch self {
        case .expense:
            return "arrow.down.circle"
        case .income:
            return "arrow.up.circle"
        }
    }
}

struct ExpenseCategory: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let iconName: String
    let isCustom: Bool

    init(id: UUID = UUID(), name: String, iconName: String, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.isCustom = isCustom
    }

    static let predefined: [ExpenseCategory] = [
        ExpenseCategory(name: "Grocery", iconName: "cart.fill"),
        ExpenseCategory(name: "Electronics", iconName: "desktopcomputer"),
        ExpenseCategory(name: "Restaurant", iconName: "fork.knife"),
        ExpenseCategory(name: "Rent", iconName: "house.fill"),
        ExpenseCategory(name: "Transportation", iconName: "car.fill"),
        ExpenseCategory(name: "Health", iconName: "cross.case.fill"),
        ExpenseCategory(name: "Stationery", iconName: "pencil.and.ruler.fill"),
        ExpenseCategory(name: "Entertainment", iconName: "gamecontroller.fill"),
        ExpenseCategory(name: "Fuel", iconName: "fuelpump.fill"),
        ExpenseCategory(name: "Shopping", iconName: "bag.fill"),
        ExpenseCategory(name: "Clothing", iconName: "tshirt.fill")
    ]

    static let customIconChoices: [CategoryIconChoice] = [
        CategoryIconChoice(symbolName: "cart.fill", label: "Grocery"),
        CategoryIconChoice(symbolName: "desktopcomputer", label: "Electronics"),
        CategoryIconChoice(symbolName: "fork.knife", label: "Restaurant"),
        CategoryIconChoice(symbolName: "house.fill", label: "Home"),
        CategoryIconChoice(symbolName: "car.fill", label: "Transport"),
        CategoryIconChoice(symbolName: "cross.case.fill", label: "Health"),
        CategoryIconChoice(symbolName: "pencil.and.ruler.fill", label: "Study"),
        CategoryIconChoice(symbolName: "gamecontroller.fill", label: "Play"),
        CategoryIconChoice(symbolName: "fuelpump.fill", label: "Fuel"),
        CategoryIconChoice(symbolName: "bag.fill", label: "Shopping"),
        CategoryIconChoice(symbolName: "tshirt.fill", label: "Style"),
        CategoryIconChoice(symbolName: "cup.and.saucer.fill", label: "Food"),
        CategoryIconChoice(symbolName: "book.fill", label: "Books"),
        CategoryIconChoice(symbolName: "gift.fill", label: "Gift"),
        CategoryIconChoice(symbolName: "heart.fill", label: "Health"),
        CategoryIconChoice(symbolName: "phone.fill", label: "Phone"),
        CategoryIconChoice(symbolName: "tag.fill", label: "Other")
    ]
}

struct Transaction: Identifiable, Hashable, Codable {
    let id: UUID
    let amount: Double
    let note: String
    let date: Date
    let type: TransactionType
    let category: ExpenseCategory?

    init(
        id: UUID = UUID(),
        amount: Double,
        note: String,
        date: Date,
        type: TransactionType,
        category: ExpenseCategory? = nil
    ) {
        self.id = id
        self.amount = amount
        self.note = note
        self.date = date
        self.type = type
        self.category = category
    }

    var displayTitle: String {
        switch type {
        case .expense:
            return category?.name ?? "Expense"
        case .income:
            return "Income"
        }
    }

    var displayIconName: String {
        switch type {
        case .expense:
            return category?.iconName ?? TransactionType.expense.symbolName
        case .income:
            return TransactionType.income.symbolName
        }
    }
}
