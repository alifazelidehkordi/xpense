import SwiftUI
import Vision
import VisionKit

struct IncomeEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore

    @State private var amount = ""
    @State private var note = ""
    @State private var showValidation = false

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 18) {
                EntryTopBar(
                    title: "New Income",
                    subtitle: "Add the amount and an optional short note.",
                    close: { dismiss() }
                )

                CompactEntryCard(title: "Amount") {
                    HStack(spacing: 14) {
                        Text("€")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.cardTop)

                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 18)
                    .background(AppTheme.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }

                CompactEntryCard(title: "Note (Optional)") {
                    TextField("Scholarship, part-time job...", text: $note)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(AppTheme.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }

                if showValidation {
                    Text("Enter a valid income amount greater than zero.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.negative)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer(minLength: 0)

                Button {
                    guard let parsedAmount = CurrencyFormatter.parseAmount(amount), parsedAmount > 0 else {
                        showValidation = true
                        return
                    }

                    store.addIncome(amount: parsedAmount, note: note)
                    dismiss()
                } label: {
                    Text("Save income")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.cardTop, AppTheme.cardTop.opacity(0.82)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: AppTheme.shadow, radius: 16, x: 0, y: 10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, max(20, geometry.safeAreaInsets.bottom + 8))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(AppTheme.background)
        .navigationBarBackButtonHidden(true)
    }
}

struct ExpenseEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore

    @State private var amount = ""
    @State private var note = ""
    @State private var selectedCategory: ExpenseCategory?
    @State private var showValidation = false
    @State private var showCategoryManager = false
    @State private var showReceiptScanner = false
    @State private var isProcessingReceipt = false
    @State private var receiptStatusMessage: String?
    @State private var receiptAlertMessage = ""
    @State private var showReceiptAlert = false

    private let categoryColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    private var availableCategories: [ExpenseCategory] {
        store.expenseCategories
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                EntryTopBar(
                    title: "New Expense",
                    subtitle: "Amount, note, and category on one page.",
                    close: { dismiss() }
                )

                scanReceiptCard

                CompactEntryCard(title: "Amount") {
                    HStack(spacing: 14) {
                        Text("€")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.cardTop)

                        TextField("0.00", text: $amount)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 18)
                    .background(AppTheme.white)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }

                CompactEntryCard(title: "Note (Optional)") {
                    TextField("Add a short note", text: $note)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(AppTheme.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }

                CompactEntryCard(title: "Category") {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Pick a category or tap Add to create your own.")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                                .lineLimit(2)

                            Spacer()

                            Button {
                                showCategoryManager = true
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add")
                                }
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(AppTheme.white)
                                .foregroundStyle(AppTheme.textPrimary)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.outline, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        LazyVGrid(columns: categoryColumns, spacing: 10) {
                            ForEach(availableCategories) { category in
                                CategoryGridButton(
                                    category: category,
                                    isSelected: selectedCategory?.id == category.id
                                ) {
                                    selectedCategory = category
                                    showValidation = false
                                }
                            }
                        }
                    }
                }

                if showValidation {
                    Text(validationMessage)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.negative)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 120)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(AppTheme.background)
        .safeAreaInset(edge: .bottom) {
            saveExpenseButton
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(AppTheme.background.opacity(0.96))
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showCategoryManager) {
            CategoryManagerSheet(selectedCategory: $selectedCategory)
                .environmentObject(store)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showReceiptScanner) {
            ReceiptScannerView(
                onCancel: {
                    showReceiptScanner = false
                },
                onScan: { images in
                    showReceiptScanner = false
                    processReceipt(images)
                },
                onError: { message in
                    showReceiptScanner = false
                    presentReceiptAlert(message)
                }
            )
            .ignoresSafeArea()
        }
        .alert("Receipt Scan", isPresented: $showReceiptAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(receiptAlertMessage)
        }
        .onChange(of: selectedCategory) { _, newValue in
            if newValue != nil {
                showValidation = false
            }
        }
    }

    private var validationMessage: String {
        if CurrencyFormatter.parseAmount(amount) == nil || CurrencyFormatter.parseAmount(amount) == 0 {
            return "Enter a valid expense amount greater than zero."
        }

        return "Choose a category before saving the expense."
    }

    private var scanReceiptCard: some View {
        CompactEntryCard(title: "Receipt Scan") {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Scan a receipt")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Autofill the amount and predicted category.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    Spacer()

                    Button {
                        startReceiptScan()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.viewfinder")
                            Text("Scan")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(AppTheme.cardTop)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(isProcessingReceipt)
                }

                if isProcessingReceipt {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(AppTheme.cardTop)

                        Text("Reading receipt and predicting category...")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                if let receiptStatusMessage {
                    Text(receiptStatusMessage)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(3)
                }
            }
        }
    }

    private var saveExpenseButton: some View {
        Button {
            saveExpense()
        } label: {
            Text("Save expense")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [AppTheme.cardTop, AppTheme.cardTop.opacity(0.82)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: AppTheme.shadow, radius: 16, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    private func startReceiptScan() {
        guard VNDocumentCameraViewController.isSupported else {
            presentReceiptAlert("Receipt scanning is not available on this device.")
            return
        }

        showReceiptScanner = true
    }

    private func processReceipt(_ images: [UIImage]) {
        guard !images.isEmpty else {
            presentReceiptAlert("No receipt pages were captured.")
            return
        }

        isProcessingReceipt = true
        receiptStatusMessage = nil

        let categories = availableCategories
        Task {
            do {
                let suggestion = try await Task.detached(priority: .userInitiated) {
                    try ReceiptScannerEngine.extractSuggestion(from: images, categories: categories)
                }.value

                await MainActor.run {
                    applyReceiptSuggestion(suggestion)
                }
            } catch {
                await MainActor.run {
                    isProcessingReceipt = false
                    presentReceiptAlert(error.localizedDescription)
                }
            }
        }
    }

    private func applyReceiptSuggestion(_ suggestion: ReceiptSuggestion) {
        isProcessingReceipt = false

        guard let totalAmount = suggestion.totalAmount else {
            presentReceiptAlert("I couldn't find a final total on this receipt. Try another scan or enter the amount manually.")
            return
        }

        amount = CurrencyFormatter.inputString(from: totalAmount)

        if note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let merchantName = suggestion.merchantName {
            note = merchantName
        }

        if let predictedCategory = suggestion.predictedCategory {
            selectedCategory = predictedCategory
            receiptStatusMessage = "Filled \(CurrencyFormatter.string(from: totalAmount)) and predicted \(predictedCategory.name). Review it, then save."
        } else {
            receiptStatusMessage = "Filled \(CurrencyFormatter.string(from: totalAmount)). Review the category, then save."
        }
    }

    private func presentReceiptAlert(_ message: String) {
        receiptAlertMessage = message
        showReceiptAlert = true
    }

    private func saveExpense() {
        guard let parsedAmount = CurrencyFormatter.parseAmount(amount), parsedAmount > 0 else {
            showValidation = true
            return
        }

        guard let selectedCategory else {
            showValidation = true
            return
        }

        store.addExpense(amount: parsedAmount, note: note, category: selectedCategory)
        dismiss()
    }
}

private struct EntryTopBar: View {
    let title: String
    let subtitle: String
    let close: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: close) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.white.opacity(0.9))
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(AppTheme.outline, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()
        }
    }
}

private struct CompactEntryCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            content
        }
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }
}

private struct CategoryGridButton: View {
    let category: ExpenseCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: category.iconName)
                    .font(.system(size: 19, weight: .bold))
                    .foregroundStyle(isSelected ? .white : AppTheme.cardTop)
                    .frame(width: 44, height: 44)
                    .background(isSelected ? AppTheme.cardTop : AppTheme.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(category.name)
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

private struct CategoryManagerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: BudgetPlannerStore

    @Binding var selectedCategory: ExpenseCategory?
    @State private var categoryName = ""
    @State private var selectedIconName = ExpenseCategory.customIconChoices.first?.symbolName ?? "tag.fill"
    @State private var editingCategory: ExpenseCategory?
    @State private var showValidation = false

    private let iconColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(editingCategory == nil ? "Add custom category" : "Edit custom category")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Type any category name you want, then choose the icon you want to use for it.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(3)
                    }

                    CompactEntryCard(title: "Category name") {
                        TextField("Books, Gym, Medical...", text: $categoryName)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(AppTheme.white)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }

                    CompactEntryCard(title: "Icon") {
                        LazyVGrid(columns: iconColumns, spacing: 10) {
                            ForEach(ExpenseCategory.customIconChoices) { choice in
                                Button {
                                    selectedIconName = choice.symbolName
                                } label: {
                                    VStack(spacing: 8) {
                                        Image(systemName: choice.symbolName)
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(selectedIconName == choice.symbolName ? .white : AppTheme.cardTop)
                                            .frame(width: 50, height: 50)
                                            .background(selectedIconName == choice.symbolName ? AppTheme.cardTop : AppTheme.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                                        Text(choice.label)
                                            .font(.system(size: 12, weight: .bold, design: .rounded))
                                            .foregroundStyle(AppTheme.textPrimary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(AppTheme.white.opacity(0.9))
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(selectedIconName == choice.symbolName ? AppTheme.cardTop : AppTheme.outline, lineWidth: selectedIconName == choice.symbolName ? 2 : 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    if showValidation {
                        Text("Enter a category name before saving and using it.")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.negative)
                    }

                    Button {
                        saveCategory()
                    } label: {
                        Text(editingCategory == nil ? "Create Category" : "Update Category")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.cardTop, AppTheme.cardTop.opacity(0.82)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    if editingCategory != nil {
                        Button("Cancel editing") {
                            resetEditor()
                        }
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Custom categories")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        if store.customExpenseCategories.isEmpty {
                            Text("No custom categories yet.")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(AppTheme.textSecondary)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(store.customExpenseCategories) { category in
                                HStack(spacing: 14) {
                                    Image(systemName: category.iconName)
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(AppTheme.cardTop)
                                        .frame(width: 42, height: 42)
                                        .background(AppTheme.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                                    Text(category.name)
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(AppTheme.textPrimary)

                                    Spacer()

                                    Button("Use") {
                                        selectedCategory = category
                                        dismiss()
                                    }
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.positive)

                                    Button("Edit") {
                                        editingCategory = category
                                        categoryName = category.name
                                        selectedIconName = category.iconName
                                    }
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.cardTop)

                                    Button("Delete") {
                                        if selectedCategory?.id == category.id {
                                            selectedCategory = nil
                                        }
                                        store.deleteExpenseCategory(category)
                                        if editingCategory?.id == category.id {
                                            resetEditor()
                                        }
                                    }
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.negative)
                                }
                                .padding(16)
                                .background(AppTheme.white.opacity(0.88))
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(AppTheme.outline, lineWidth: 1)
                                )
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 22)
                .padding(.bottom, 28)
            }
            .background(AppTheme.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        saveCategory()
                    }
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                }
            }
        }
    }

    private func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            showValidation = true
            return
        }

        if let editingCategory {
            if let updatedCategory = store.updateExpenseCategory(editingCategory, name: trimmedName, iconName: selectedIconName) {
                selectedCategory = updatedCategory
                showValidation = false
                dismiss()
            }
        } else if let createdCategory = store.addExpenseCategory(name: trimmedName, iconName: selectedIconName) {
            selectedCategory = createdCategory
            showValidation = false
            dismiss()
        }
    }

    private func resetEditor() {
        editingCategory = nil
        categoryName = ""
        selectedIconName = ExpenseCategory.customIconChoices.first?.symbolName ?? "tag.fill"
        showValidation = false
    }
}

private struct ReceiptSuggestion {
    let merchantName: String?
    let totalAmount: Double?
    let predictedCategory: ExpenseCategory?
}

private enum ReceiptScanError: LocalizedError {
    case noImages
    case noTextFound
    case imageConversionFailed

    var errorDescription: String? {
        switch self {
        case .noImages:
            return "No receipt pages were captured."
        case .noTextFound:
            return "I couldn't read any text from this receipt."
        case .imageConversionFailed:
            return "I couldn't process the scanned receipt image."
        }
    }
}

private enum ReceiptScannerEngine {
    private static let amountRegex = try? NSRegularExpression(
        pattern: #"(?:(?:€|eur)\s*)?\d{1,4}(?:[.,]\d{3})*(?:[.,]\d{2})"#,
        options: [.caseInsensitive]
    )

    private static let excludedMerchantTerms = [
        "receipt", "ricevuta", "fattura", "invoice", "tax", "vat", "iva", "totale", "total",
        "subtotal", "cash", "change", "visa", "mastercard", "thank", "grazie"
    ]

    private static let prioritizedTotalKeywords: [(keyword: String, score: Int)] = [
        ("grand total", 280),
        ("amount due", 270),
        ("totale a pagare", 270),
        ("importo totale", 260),
        ("totale euro", 250),
        ("da pagare", 220),
        ("pagato", 210),
        ("netto", 180),
        ("totale", 170),
        ("total", 160)
    ]

    private static let excludedTotalKeywords = [
        "subtotal", "sub total", "tax", "vat", "iva", "discount", "sconto",
        "change", "cash", "card", "resto", "rounding", "commissione"
    ]

    private static let categoryRules: [String: [String]] = [
        "Grocery": [
            "conad", "esselunga", "coop", "lidl", "eurospin", "carrefour", "piccolo", "deco",
            "deco", "pasta", "supermercato", "spesa", "alimentari", "pane", "latte", "frutta",
            "market", "minimarket", "pasticceria", "aldi", "sole365", "pam", "md", "sigma",
            "crai", "despar", "dok", "famila", "bennet", "sidis", "tigre", "ipercoop"
        ],
        "Electronics": [
            "apple", "mediaworld", "unieuro", "euronics", "samsung", "elettronica", "telefono",
            "laptop", "tablet", "cavo", "iphone", "android", "hp"
        ],
        "Restaurant": [
            "ristorante", "pizzeria", "bar", "caffe", "caffe", "trattoria", "mcdonald",
            "burger", "sushi", "coperto", "menu", "menu", "cena", "panzo", "osteria",
            "hosteria", "secondo", "cheeseburger", "mcnuggets", "sundae", "patate", "fries"
        ],
        "Transportation": [
            "trenitalia", "italo", "atm", "taxi", "uber", "ryanair", "autostrada", "parcheggio",
            "biglietto", "treno", "bus", "eav", "anm"
        ],
        "Health": [
            "farmacia", "medico", "dottore", "clinica", "farmaco", "visita", "analisi",
            "ospedale", "dentista", "ottico"
        ],
        "Entertainment": [
            "cinema", "teatro", "film", "spettacolo", "uci", "thespace", "teatro di san carlo",
            "sala", "the space", "uci cinemas", "ticketone", "posto unico", "numero biglietto",
            "ticketone it", "vivaticket"
        ],
        "Fuel": [
            "eni", "shell", "q8", "ip", "agip", "benzina", "gasolio", "carburante", "gas"
        ],
        "Shopping": [
            "zara", "h&m", "nike", "adidas", "abbigliamento", "scarpe", "borsa", "vestiti",
            "moda", "ikea", "primark", "ovs", "pantalone", "t shirt", "pandora"
        ]
    ]

    static func extractSuggestion(from images: [UIImage], categories: [ExpenseCategory]) throws -> ReceiptSuggestion {
        guard !images.isEmpty else {
            throw ReceiptScanError.noImages
        }

        let textLines = try images.flatMap { image in
            try recognizeText(in: image)
        }

        let sanitizedLines = textLines
            .map(sanitizeOCRLine)
            .filter { !$0.isEmpty }

        guard !sanitizedLines.isEmpty else {
            throw ReceiptScanError.noTextFound
        }

        let merchantName = detectMerchant(in: sanitizedLines)
        let totalAmount = detectTotal(in: sanitizedLines)
        let predictedCategory = predictCategory(merchantName: merchantName, lines: sanitizedLines, categories: categories)

        return ReceiptSuggestion(
            merchantName: merchantName,
            totalAmount: totalAmount,
            predictedCategory: predictedCategory
        )
    }

    private static func recognizeText(in image: UIImage) throws -> [String] {
        guard let cgImage = image.cgImage else {
            throw ReceiptScanError.imageConversionFailed
        }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["it-IT", "en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        try handler.perform([request])

        return request.results?.compactMap { observation in
            observation.topCandidates(1).first?.string
        } ?? []
    }

    private static func sanitizeOCRLine(_ rawLine: String) -> String {
        rawLine
            .replacingOccurrences(of: "\u{00A0}", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func detectMerchant(in lines: [String]) -> String? {
        for line in lines.prefix(8) {
            let lowercased = line.lowercased()

            if excludedMerchantTerms.contains(where: lowercased.contains) {
                continue
            }

            let letterCount = line.unicodeScalars.filter { CharacterSet.letters.contains($0) }.count
            let digitCount = line.unicodeScalars.filter { CharacterSet.decimalDigits.contains($0) }.count

            guard letterCount >= 3, letterCount > digitCount else {
                continue
            }

            return line
        }

        return nil
    }

    private static func detectTotal(in lines: [String]) -> Double? {
        struct AmountCandidate {
            let amount: Double
            let score: Int
            let lineIndex: Int
        }

        var candidates: [AmountCandidate] = []

        for (index, line) in lines.enumerated() {
            let normalizedLine = normalizeForMatching(line)
            let linePriority = priorityScoreForTotalLine(normalizedLine)
            let exclusionPenalty = exclusionPenaltyForTotalLine(normalizedLine)
            let laterLineBoost = max(0, index - max(1, lines.count / 3))

            if let lineAmount = preferredAmount(from: line, prioritizeTrailingAmount: linePriority > 0) {
                let score = linePriority + laterLineBoost + (index >= lines.count - 3 ? 16 : 0) - exclusionPenalty
                candidates.append(AmountCandidate(amount: lineAmount, score: score, lineIndex: index))
            }

            guard linePriority > 0, index + 1 < lines.count else {
                continue
            }

            let nextLine = lines[index + 1]
            let nextLinePenalty = exclusionPenaltyForTotalLine(normalizeForMatching(nextLine))

            if let nextLineAmount = preferredAmount(from: nextLine, prioritizeTrailingAmount: true) {
                let score = linePriority + laterLineBoost + 36 - exclusionPenalty - nextLinePenalty
                candidates.append(AmountCandidate(amount: nextLineAmount, score: score, lineIndex: index + 1))
            }
        }

        if let bestScoredCandidate = candidates
            .filter({ $0.score > 0 })
            .max(by: { lhs, rhs in
                if lhs.score == rhs.score {
                    if lhs.lineIndex == rhs.lineIndex {
                        return lhs.amount < rhs.amount
                    }
                    return lhs.lineIndex < rhs.lineIndex
                }
                return lhs.score < rhs.score
            }) {
            return bestScoredCandidate.amount
        }

        let trailingWindow = max(4, lines.count / 2)
        let trailingAmounts = lines
            .suffix(trailingWindow)
            .flatMap(extractAmounts)
            .filter { $0 > 0 }

        return trailingAmounts.max() ?? lines
            .flatMap(extractAmounts)
            .filter { $0 > 0 }
            .max()
    }

    private static func extractAmounts(from line: String) -> [Double] {
        guard let amountRegex else { return [] }
        let fullRange = NSRange(line.startIndex..<line.endIndex, in: line)
        return amountRegex.matches(in: line, range: fullRange).compactMap { match in
            guard let range = Range(match.range, in: line) else { return nil }
            return CurrencyFormatter.parseAmount(String(line[range]))
        }
    }

    private static func predictCategory(merchantName: String?, lines: [String], categories: [ExpenseCategory]) -> ExpenseCategory? {
        let fullText = normalizeForMatching(lines.joined(separator: " "))
        let merchantText = normalizeForMatching(merchantName ?? "")

        // Let user-defined categories win if their name appears in the OCR text.
        if let customMatch = categories.first(where: { $0.isCustom && fullText.contains(normalizeForMatching($0.name)) }) {
            return customMatch
        }

        var bestCategoryName: String?
        var bestScore = 0

        for (categoryName, keywords) in categoryRules {
            var score = 0

            for keyword in keywords {
                let normalizedKeyword = normalizeForMatching(keyword)

                if merchantText.contains(normalizedKeyword) {
                    score += 6
                }

                if fullText.contains(normalizedKeyword) {
                    score += 2
                }
            }

            if score > bestScore {
                bestScore = score
                bestCategoryName = categoryName
            }
        }

        guard let bestCategoryName, bestScore > 0 else {
            return nil
        }

        return categories.first(where: { $0.name.caseInsensitiveCompare(bestCategoryName) == .orderedSame })
    }

    private static func priorityScoreForTotalLine(_ normalizedLine: String) -> Int {
        prioritizedTotalKeywords.reduce(into: 0) { bestScore, entry in
            if normalizedLine.contains(normalizeForMatching(entry.keyword)) {
                bestScore = max(bestScore, entry.score)
            }
        }
    }

    private static func exclusionPenaltyForTotalLine(_ normalizedLine: String) -> Int {
        excludedTotalKeywords.contains(where: normalizedLine.contains) ? 180 : 0
    }

    private static func preferredAmount(from line: String, prioritizeTrailingAmount: Bool) -> Double? {
        let amounts = extractAmounts(from: line).filter { $0 > 0 }
        guard !amounts.isEmpty else { return nil }
        return prioritizeTrailingAmount ? amounts.last : amounts.max()
    }

    private static func normalizeForMatching(_ value: String) -> String {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .replacingOccurrences(of: "&", with: " and ")
            .replacingOccurrences(of: "[^a-z0-9]+", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private struct ReceiptScannerView: UIViewControllerRepresentable {
    let onCancel: () -> Void
    let onScan: ([UIImage]) -> Void
    let onError: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) { }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let parent: ReceiptScannerView

        init(_ parent: ReceiptScannerView) {
            self.parent = parent
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.onCancel()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.onError(error.localizedDescription)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let images = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
            parent.onScan(images)
        }
    }
}
