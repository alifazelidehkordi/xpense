import PhotosUI
import SwiftUI

struct ProfilePhotoView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingPhoto = false

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Add a profile photo")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("This step is optional. If you skip it, the app will use your initials on the home screen.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(4)
            }

            VStack(spacing: 22) {
                ProfileAvatarView(
                    imageData: store.profile.profileImageData,
                    initials: store.initials,
                    size: 164,
                    backgroundColors: [AppTheme.cardTop.opacity(0.94), AppTheme.cardBottom]
                )

                PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                    HStack(spacing: 10) {
                        Image(systemName: "photo.badge.plus")
                        Text(isLoadingPhoto ? "Loading..." : "Choose photo")
                    }
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppTheme.white)
                    .foregroundStyle(AppTheme.textPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.outline, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .stroke(AppTheme.outline, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow, radius: 22, x: 0, y: 12)

            VStack(spacing: 14) {
                Button {
                    store.finishOnboarding()
                } label: {
                    Text("Open home")
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

                Button("Skip for now") {
                    store.updateProfilePhoto(with: nil)
                    store.finishOnboarding()
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
        .padding(.top, 36)
        .padding(.bottom, 32)
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            isLoadingPhoto = true
            defer { isLoadingPhoto = false }

            if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                store.updateProfilePhoto(with: data)
            }
        }
    }
}
