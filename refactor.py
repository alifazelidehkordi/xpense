import sys

path = "/Users/foundation26/Downloads/New project/1/BudgetPlanner/Views/Panels/LearnPanel.swift"
with open(path, "r") as f:
    text = f.read()

# We need to replace `struct LearnView: View { ... }` up to `struct LearnGameMiniTile`

# Let's find the start of LearnView
start_idx = text.find("struct LearnView: View {")
if start_idx == -1:
    print("Could not find LearnView")
    sys.exit(1)

# Let's find the end of LearnGameMiniTile
end_idx = text.find("private struct LearnCoinAvatarView")
if end_idx == -1:
    print("Could not find LearnCoinAvatarView")
    sys.exit(1)

replacement = """struct LearnView: View {
    @EnvironmentObject private var store: BudgetPlannerStore

    @State private var coinsBalance = 0
    @State private var savingsBalance = 0
    @State private var hasSeededGameState = false
    @State private var popupState: LearnTilePopupState?
    @Namespace private var animationNamespace

    let openLesson: (LearnLessonState) -> Void

    private var allLessons: [LearnLessonState] {
        store.learnTopicStates.flatMap(\\.lessons)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 120)
                    
                    ForEach(Array(allLessons.enumerated().reversed()), id: \\.element.id) { index, lessonState in
                        LevelNodeRow(
                            index: index,
                            lessonState: lessonState,
                            isCompleted: index < store.completedLessonCount,
                            isActive: index == store.completedLessonCount,
                            animationNamespace: _animationNamespace,
                            onTap: { preview(index: index, lessonState: lessonState) }
                        )
                    }
                    
                    Spacer().frame(height: 380) // Space for the HUD
                }
                .frame(maxWidth: .infinity)
                .background(
                    GeometryReader { geo in
                        Image("MapBackground")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geo.size.width, height: max(geo.size.height, geo.size.height)) // Will stretch if not tall enough, consider using .tile or just center
                            .clipped()
                    }
                )
            }
            .ignoresSafeArea()

            bankCardGlass
                .padding(.horizontal, 16)
                .padding(.bottom, 16)

            if let popupState {
                LearnTileActionPopup(
                    popupState: popupState,
                    onClose: { self.popupState = nil },
                    onPrimaryAction: {
                        if let lessonState = popupState.lessonState {
                            openLesson(lessonState)
                        }
                        self.popupState = nil
                    }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 86)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.36, dampingFraction: 0.86), value: popupState?.id)
        .onAppear(perform: seedGameStateIfNeeded)
    }

    private var bankCardGlass: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("BANK")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x231C4D))
                    
                    Text("Savings Fund")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x231C4D).opacity(0.8))
                    
                    Text("$\\(savingsBalance)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: 0x231C4D))
                }

                Spacer()

                Image(systemName: "building.columns.fill")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(Color(hex: 0xA854F7))
                    .padding(12)
                    .background(Color.white.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            ProgressView(value: min(max(Double(savingsBalance) / 10_000, 0), 1))
                .tint(Color(hex: 0xA854F7))
                .frame(height: 8)
                .background(Color.white.opacity(0.3))
                .clipShape(Capsule())

            HStack(spacing: 12) {
                gelButton(title: "DEPOSIT", action: { quickDeposit(250) })
                gelButton(title: "WITHDRAW", action: { withdraw(250) })
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }

    private func gelButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color(hex: 0x8D4EFF), Color(hex: 0x5E22D8)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func seedGameStateIfNeeded() {
        if !hasSeededGameState {
            coinsBalance = max(store.learnTotalXP * 22, 2_500)
            savingsBalance = max(store.learnTotalXP * 8, 1_200)
            hasSeededGameState = true
        }
    }

    private func quickDeposit(_ amount: Int) {
        guard coinsBalance > 0 else { return }
        let value = min(amount, coinsBalance)
        coinsBalance -= value
        savingsBalance += value
    }

    private func withdraw(_ amount: Int) {
        let value = min(amount, savingsBalance)
        savingsBalance -= value
        coinsBalance += value
    }

    private func preview(index: Int, lessonState: LearnLessonState) {
        if index > store.completedLessonCount {
            popupState = LearnTilePopupState(
                title: "Level Locked",
                lessonTitle: lessonState.lesson.title,
                message: "Keep learning to unlock!",
                economyText: "Complete previous levels first.",
                actionTitle: nil,
                lessonState: nil
            )
        } else {
            popupState = LearnTilePopupState(
                title: index == store.completedLessonCount ? "Active Level" : "Completed Level",
                lessonTitle: lessonState.lesson.title,
                message: index == store.completedLessonCount ? "Next step: \\(lessonState.lesson.subtitle)" : "You have already completed this lesson.",
                economyText: lessonState.lesson.subtitle,
                actionTitle: index == store.completedLessonCount ? "Start Lesson" : "Review Lesson",
                lessonState: lessonState
            )
        }
    }
}

private struct LevelNodeRow: View {
    let index: Int
    let lessonState: LearnLessonState
    let isCompleted: Bool
    let isActive: Bool
    var animationNamespace: Namespace.ID
    let onTap: () -> Void

    private var xOffset: CGFloat {
        let period = 4.0
        let amplitude: CGFloat = 80.0
        return CGFloat(sin(Double(index) / period * .pi)) * amplitude
    }

    var body: some View {
        ZStack {
            Button(action: onTap) {
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .shadow(color: isActive ? Color(hex: 0xA854F7).opacity(0.6) : .clear, radius: 10)
            }
            .buttonStyle(.plain)

            if isActive {
                LearnCoinAvatarView(isRolling: false)
                    .matchedGeometryEffect(id: "avatar_id", in: animationNamespace)
                    .offset(y: -50)
                    .zIndex(10)
                    .rotation3DEffect(
                        .degrees(10),
                        axis: (x: 1, y: 0, z: 0)
                    )
            }
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .offset(x: xOffset)
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isActive)
    }

    private var assetName: String {
        if isCompleted { return "LevelCompleted" }
        if isActive { return "LevelActive" }
        return "LevelLocked"
    }
}

"""

new_text = text[:start_idx] + replacement + text[end_idx:]

with open(path, "w") as f:
    f.write(new_text)

print("Done replacing LearnView.")
