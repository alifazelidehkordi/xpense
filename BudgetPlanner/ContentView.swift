import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: BudgetPlannerStore

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            Group {
                switch store.currentStep {
                case .welcome:
                    WelcomeView()
                case .signUp:
                    SignUpView()
                case .budget:
                    BudgetSetupView()
                case .photo:
                    ProfilePhotoView()
                case .home:
                    MainTabView()
                }
            }
            .transition(.opacity.combined(with: .move(edge: .trailing)))
        }
        .animation(.easeInOut(duration: 0.3), value: store.currentStep)
    }
}

struct WelcomeView: View {
    @EnvironmentObject private var store: BudgetPlannerStore

    var body: some View {
        ZStack {
            // Background matching the space/purple aesthetic
            RadialGradient(
                gradient: Gradient(colors: [Color(hex: 0x8A45D8), Color(hex: 0x4B1792)]),
                center: .top,
                startRadius: 20,
                endRadius: 800
            )
            .ignoresSafeArea()

            // Star/dust/particle background effect placeholder
            // A simple noise or dots layer
            GeometryReader { geometry in
                Path { path in
                    for _ in 0..<40 {
                        let x = CGFloat.random(in: 0...geometry.size.width)
                        let y = CGFloat.random(in: 0...geometry.size.height)
                        path.addEllipse(in: CGRect(x: x, y: y, width: 2, height: 2))
                    }
                }
                .fill(Color.white.opacity(0.15))
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 50)

                Text("Xpense")
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: Color.white.opacity(0.4), radius: 10, x: 0, y: 0)

                Spacer()

                // Main Character Image
                Image("SplashCharacter")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 450)
                    .padding(.horizontal, 10)
                    // Add a subtle shadow to ground the character
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 15)

                Spacer()

                // Bottom Buttons
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button {
                            // Replace with routing to Login if available
                            store.currentStep = .signUp
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "shield.lefthalf.filled")
                                Text("Log In")
                            }
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundStyle(.white)
                            .background(Color.white.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                        }

                        Button {
                            store.currentStep = .signUp
                        } label: {
                            Text("Sign Up")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .foregroundStyle(.white)
                                .background(Color(hex: 0x6E2BC4))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                    }

                    Button {
                        store.finishOnboarding()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "star.fill")
                                .foregroundStyle(Color(hex: 0xF8D147))
                            Text("Go to Dashboard")
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(.white)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: 0xA76FF0), Color(hex: 0x7933DF)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.black.opacity(0.25), radius: 12, x: 0, y: 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(BudgetPlannerStore())
}
