import Foundation

enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "it_IT")
        formatter.currencyCode = "EUR"
        formatter.currencySymbol = "€"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.positivePrefix = "€"
        formatter.positiveSuffix = ""
        formatter.negativePrefix = "-€"
        formatter.negativeSuffix = ""
        return formatter
    }()

    private static let inputFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "it_IT")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static func string(from value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? String(format: "€%.2f", value)
    }

    static func inputString(from value: Double) -> String {
        inputFormatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value).replacingOccurrences(of: ".", with: ",")
    }

    static func parseAmount(_ rawValue: String) -> Double? {
        let cleaned = rawValue
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "€", with: "")
            .filter { "0123456789,.".contains($0) }

        guard !cleaned.isEmpty else { return nil }

        let normalized: String
        if cleaned.contains(",") && cleaned.contains(".") {
            if let commaIndex = cleaned.lastIndex(of: ","), let dotIndex = cleaned.lastIndex(of: "."), commaIndex > dotIndex {
                normalized = cleaned
                    .replacingOccurrences(of: ".", with: "")
                    .replacingOccurrences(of: ",", with: ".")
            } else {
                normalized = cleaned.replacingOccurrences(of: ",", with: "")
            }
        } else {
            normalized = cleaned.replacingOccurrences(of: ",", with: ".")
        }

        return Double(normalized)
    }
}
