import SwiftUI

struct SignUpView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var university = ""
    @State private var birthDate: Date?

    private let universities = [
        "University of Naples Federico II",
        "University of Parthenope",
        "University of Naples \"L'Orientale\"",
        "University of Suor Orsola Benincasa",
    ]

    private var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && birthDate != nil
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Button {
                    withAnimation {
                        store.currentStep = OnboardingStep.welcome
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)
                        .frame(width: 44, height: 44)
                        .background(AppTheme.surface)
                        .clipShape(Circle())
                        .shadow(color: AppTheme.shadow, radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Build a smarter student budget")
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text("Start with your details so the app can prepare your budget home screen.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(4)
                }

                if store.isSignedInToSocial {
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(AppTheme.cardTop)
                            .frame(width: 44, height: 44)
                            .background(AppTheme.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 5) {
                            Text("Google account connected")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)

                            Text(
                                "Your name was prefilled from \(store.socialAccountDisplayName). You can edit it before continuing."
                            )
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineSpacing(3)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.outline, lineWidth: 1)
                    )
                }

                VStack(spacing: 18) {
                    InputField(title: "First name", text: $firstName)
                    InputField(title: "Surname", text: $lastName)
                    BirthDateField(
                        title: "Age",
                        placeholder: "Select your birth date",
                        selection: $birthDate
                    )
                    UniversityPickerField(
                        title: "University (optional)",
                        placeholder: "Choose your university",
                        selection: $university,
                        options: universities
                    )
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
                    store.saveProfile(
                        firstName: firstName,
                        lastName: lastName,
                        university: university,
                        birthDate: birthDate
                    )
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
                .disabled(!isFormValid)
                .opacity(isFormValid ? 1 : 0.55)
            }
            .padding(.horizontal, 24)
            .padding(.top, 36)
            .padding(.bottom, 32)
        }
        .onAppear(perform: populateFormFromStore)
        .onChange(of: store.socialSession?.userID) { _, _ in
            populateFormFromStore()
        }
    }

    private func populateFormFromStore() {
        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            firstName = store.profile.firstName
        }

        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lastName = store.profile.lastName
        }

        if university.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            university = store.profile.university
        }

        if birthDate == nil {
            birthDate = store.profile.birthDate
        }
    }
}

private struct InputField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            TextField(title, text: $text)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .textInputAutocapitalization(.words)
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

private struct UniversityPickerField: View {
    let title: String
    let placeholder: String
    @Binding var selection: String
    let options: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            Menu {
                ForEach(options, id: \.self) { option in
                    Button {
                        selection = option
                    } label: {
                        HStack {
                            Text(option)
                            if selection == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(selection.isEmpty ? placeholder : selection)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(
                            selection.isEmpty ? AppTheme.textSecondary : AppTheme.textPrimary
                        )
                        .multilineTextAlignment(.leading)

                    Spacer(minLength: 12)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppTheme.cardTop)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

private struct BirthDateField: View {
    let title: String
    let placeholder: String
    @Binding var selection: Date?

    @State private var isPickerPresented = false
    @State private var draftDate = BirthDateField.defaultBirthDate

    private static var defaultBirthDate: Date {
        Calendar.current.date(byAdding: .year, value: -18, to: .now) ?? .now
    }

    private var selectedDateText: String {
        guard let selection else { return placeholder }
        return selection.formatted(.dateTime.day().month(.abbreviated).year())
    }

    private var ageText: String? {
        guard let selection else { return nil }
        let years = max(
            Calendar.current.dateComponents([.year], from: selection, to: .now).year ?? 0, 0)
        return "\(years) years old"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            Button {
                draftDate = selection ?? Self.defaultBirthDate
                isPickerPresented = true
            } label: {
                HStack(spacing: 12) {
                    Text(selectedDateText)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(
                            selection == nil ? AppTheme.textSecondary : AppTheme.textPrimary)

                    Spacer(minLength: 12)

                    Image(systemName: "calendar")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AppTheme.cardTop)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .sheet(isPresented: $isPickerPresented) {
                NavigationStack {
                    DatePicker(
                        "Birth date",
                        selection: $draftDate,
                        in: ...Date.now,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .padding(20)
                    .navigationTitle("Select birth date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                isPickerPresented = false
                            }
                        }

                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                selection = draftDate
                                isPickerPresented = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium, .large])
            }

            if let ageText {
                Text(ageText)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .padding(.leading, 2)
            }
        }
    }
}
