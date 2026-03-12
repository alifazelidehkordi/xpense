import SwiftUI
import UIKit

struct ProfileAvatarView: View {
    let imageData: Data?
    let initials: String
    let size: CGFloat
    let backgroundColors: [Color]

    var body: some View {
        Group {
            if let image = profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                LinearGradient(
                    colors: backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .overlay {
                    Text(initials)
                        .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white.opacity(0.88), lineWidth: 3)
        )
        .shadow(color: AppTheme.shadow, radius: 14, x: 0, y: 10)
    }

    private var profileImage: UIImage? {
        guard let imageData else { return nil }
        return UIImage(data: imageData)
    }
}
