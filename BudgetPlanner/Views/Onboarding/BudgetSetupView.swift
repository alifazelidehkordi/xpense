import SwiftUI

struct BudgetSetupView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @State private var monthlyBudget = ""
    @State private var showValidation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Set your monthly budget")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Enter the amount you want to manage this month. You can update it later when we add settings.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(4)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("Monthly amount")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                HStack(spacing: 14) {
                    Text("€")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.cardTop)

                    TextField("800", text: $monthlyBudget)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

                if showValidation {
                    Text("Enter a valid budget amount greater than zero.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.negative)
                }
            }
            .padding(24)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(AppTheme.outline, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow, radius: 22, x: 0, y: 12)

            Button {
                showValidation = !store.saveMonthlyBudget(from: monthlyBudget)
            } label: {
                Text("Continue")
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

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 36)
        .padding(.bottom, 32)
        .onAppear {
            if monthlyBudget.isEmpty && store.profile.monthlyBudget > 0 {
                monthlyBudget = String(Int(store.profile.monthlyBudget))
            }
        }
    }
}
