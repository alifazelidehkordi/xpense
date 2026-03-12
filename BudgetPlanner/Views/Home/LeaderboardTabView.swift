import SwiftUI
import UIKit

struct LeaderboardTabView: View {
    @EnvironmentObject private var store: BudgetPlannerStore

    let openChat: () -> Void

    @State private var showGroupActions = false
    @State private var showCreateGroupAlert = false
    @State private var showJoinGroupAlert = false
    @State private var showInviteCopiedAlert = false
    @State private var groupNameDraft = ""
    @State private var inviteCodeDraft = ""

    private var spotlightMembers: [LeaderboardMemberState] {
        Array(store.leaderboardMembers.dropFirst().prefix(2))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                header

                if !store.isSignedInToSocial {
                    authSection
                } else if let group = store.leaderboardGroup {
                    groupMetaSection(group)
                    leaderboardSection
                    chatEntryCard
                } else {
                    emptyGroupSection
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 36)
        }
        .background(AppTheme.background)
        .confirmationDialog("Connect with friends", isPresented: $showGroupActions) {
            Button("Create group") {
                showCreateGroupAlert = true
            }

            Button("Join group") {
                showJoinGroupAlert = true
            }

            Button("Cancel", role: .cancel) { }
        }
        .alert("Create Group", isPresented: $showCreateGroupAlert) {
            TextField("Group name", text: $groupNameDraft)
            Button("Cancel", role: .cancel) {
                groupNameDraft = ""
            }
            Button("Create") {
                let name = groupNameDraft
                groupNameDraft = ""
                Task {
                    await store.createGroup(named: name)
                }
            }
        } message: {
            Text("Create a private XP leaderboard for your friends.")
        }
        .alert("Join Group", isPresented: $showJoinGroupAlert) {
            TextField("Invite code", text: $inviteCodeDraft)
                .textInputAutocapitalization(.characters)
            Button("Cancel", role: .cancel) {
                inviteCodeDraft = ""
            }
            Button("Join") {
                let code = inviteCodeDraft
                inviteCodeDraft = ""
                Task {
                    await store.joinGroup(inviteCode: code)
                }
            }
        } message: {
            Text("Enter the invite code shared by your friend.")
        }
        .alert("Invite code copied", isPresented: $showInviteCopiedAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Share the code with your friends so they can join your leaderboard.")
        }
        .alert(item: $store.socialAlert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("Leaderboard")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Spacer()

            Button(action: handleHeaderAction) {
                HStack(spacing: 8) {
                    Image(systemName: store.isSignedInToSocial ? "person.badge.plus" : "person.crop.circle.badge.checkmark")
                    Text(store.isSignedInToSocial ? "Add Friend" : "Connect")
                }
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.cardTop)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(AppTheme.white.opacity(0.88))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.outline, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var authSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Connect your account")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Sign in once to create or join a group. The app only shares your public XP, level, and profile name with friends.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(3)

            Button {
                Task {
                    await store.signInWithGoogle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.system(size: 20, weight: .bold))
                    Text("Continue with Google")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                    Spacer()
                }
                .foregroundStyle(AppTheme.textPrimary)
                .padding(.horizontal, 18)
                .frame(height: 54)
                .background(AppTheme.white.opacity(store.googleSignInIssue == nil ? 0.96 : 0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.outline, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(store.googleSignInIssue != nil || store.isSocialActionInProgress)

            if let issue = store.googleSignInIssue {
                Text(issue)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.negative)
                    .lineSpacing(2)
            } else {
                Text("Apple Sign-In is disabled in this build because personal Apple development teams cannot sign apps with that capability.")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
                    .lineSpacing(2)
            }
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .leaderboardPrimaryCard(cornerRadius: 30)
    }

    private func groupMetaSection(_ group: LeaderboardGroupState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                }

                Spacer()

                Button {
                    Task {
                        await store.signOutFromSocial()
                    }
                } label: {
                    Text("Sign out")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppTheme.white.opacity(0.88))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }

            HStack(spacing: 10) {
                groupChip(title: "Invite", value: group.inviteCode)

                ShareLink(item: "Join my BudgetQuest leaderboard with invite code \(group.inviteCode).") {
                    HStack(spacing: 6) {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share")
                    }
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(AppTheme.white.opacity(0.88))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .leaderboardPrimaryCard(cornerRadius: 28)
    }

    private var emptyGroupSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Start your group")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Create a group or join a friend's invite code. Once connected, the leaderboard updates from Firebase in real time.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(3)

            HStack(spacing: 12) {
                socialActionButton(title: "Create Group", filled: true) {
                    showCreateGroupAlert = true
                }

                socialActionButton(title: "Join Group", filled: false) {
                    showJoinGroupAlert = true
                }
            }
        }
        .padding(22)
        .leaderboardPrimaryCard(cornerRadius: 30)
    }

    private var leaderboardSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let champion = store.leaderboardMembers.first {
                LeaderboardChampionCard(member: champion)
            }

            if !spotlightMembers.isEmpty {
                HStack(spacing: 12) {
                    ForEach(Array(spotlightMembers.enumerated()), id: \.element.id) { offset, member in
                        LeaderboardSpotlightCard(member: member, rank: offset + 2)
                    }
                }
            }

            if !store.leaderboardRemainingMembers.isEmpty {
                VStack(spacing: 12) {
                    ForEach(Array(store.leaderboardRemainingMembers.enumerated()), id: \.element.id) { offset, member in
                        LeaderboardListRow(
                            rank: offset + 4,
                            member: member,
                            isHighlighted: member.isCurrentUser
                        )
                    }
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "person.2")
                Text("\(max(store.leaderboardMembers.count - 1, 0)) friends connected")
            }
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundStyle(AppTheme.textPrimary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 6)
        }
    }

    private var chatEntryCard: some View {
        Button(action: openChat) {
            HStack(spacing: 16) {
                ZStack(alignment: .topTrailing) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(AppTheme.white.opacity(0.95))
                        .frame(width: 58, height: 58)

                    Image(systemName: "ellipsis.message.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(AppTheme.cardTop)

                    if store.unreadGroupChatCount > 0 {
                        Text(store.unreadGroupChatCount > 9 ? "9+" : "\(store.unreadGroupChatCount)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(AppTheme.negative)
                            .clipShape(Capsule())
                            .offset(x: 10, y: -10)
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text("Open Group Chat")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        if store.unreadGroupChatCount > 0 {
                            Text("\(store.unreadGroupChatCount) new")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.negative)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(AppTheme.chartBlush.opacity(0.9))
                                .clipShape(Capsule())
                        }
                    }

                    Text(chatPreviewText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 10)

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(AppTheme.cardTop)
            }
            .padding(20)
            .leaderboardPrimaryCard(cornerRadius: 30)
        }
        .buttonStyle(.plain)
    }

    private var chatPreviewText: String {
        if let lastMessage = store.groupChatMessages.last {
            let prefix = lastMessage.isCurrentUser ? "You" : lastMessage.senderName
            return "\(prefix): \(lastMessage.body)"
        }

        return "Open the conversation with your group in a dedicated chat screen."
    }

    private func groupChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)

            Text(value)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.white.opacity(0.88))
        .clipShape(Capsule())
    }

    private func socialActionButton(title: String, filled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(filled ? Color.white : AppTheme.cardTop)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(filled ? AppTheme.cardTop : AppTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(filled ? Color.clear : AppTheme.outline, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func handleHeaderAction() {
        guard store.isSignedInToSocial else {
            store.socialAlert = SocialAlertState(
                title: "Sign in required",
                message: "Connect with Google first, then create or join a leaderboard group."
            )
            return
        }

        guard let group = store.leaderboardGroup else {
            showGroupActions = true
            return
        }

        UIPasteboard.general.string = group.inviteCode
        showInviteCopiedAlert = true
    }
}

struct LeaderboardChatView: View {
    @EnvironmentObject private var store: BudgetPlannerStore
    @State private var draftMessage = ""
    @FocusState private var isMessageFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        if store.groupChatMessages.isEmpty {
                            emptyState
                        } else {
                            ForEach(store.groupChatMessages) { message in
                                LeaderboardChatBubble(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(AppTheme.background)
                .onAppear {
                    store.markGroupChatAsRead()
                    scrollToLatestMessage(using: proxy, animated: false)
                }
                .onChange(of: store.groupChatMessages.last?.id) { _, _ in
                    store.markGroupChatAsRead()
                    scrollToLatestMessage(using: proxy, animated: true)
                }
            }

            HStack(spacing: 12) {
                TextField("Send a message to the group", text: $draftMessage)
                    .textFieldStyle(.plain)
                    .focused($isMessageFieldFocused)
                    .submitLabel(.send)
                    .onSubmit(sendDraftMessage)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 15)
                    .background(AppTheme.white.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(AppTheme.outline, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Button(action: sendDraftMessage) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(AppTheme.cardTop)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(store.isSocialActionInProgress)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 18)
            .background(AppTheme.background)
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppTheme.background)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isMessageFieldFocused = false
                }
            }
        }
        .onAppear {
            store.markGroupChatAsRead()
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("No messages yet")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Text("Start the conversation with your group here. New messages will appear live.")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(AppTheme.textSecondary)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .leaderboardSecondaryCard(cornerRadius: 22)
    }

    private func sendDraftMessage() {
        let message = draftMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else {
            isMessageFieldFocused = false
            return
        }

        draftMessage = ""
        isMessageFieldFocused = false

        Task {
            await store.sendGroupMessage(message)
            store.markGroupChatAsRead()
        }
    }

    private func scrollToLatestMessage(using proxy: ScrollViewProxy, animated: Bool) {
        guard let lastMessageID = store.groupChatMessages.last?.id else { return }

        let action = {
            proxy.scrollTo(lastMessageID, anchor: .bottom)
        }

        if animated {
            withAnimation(.easeOut(duration: 0.2)) {
                action()
            }
        } else {
            action()
        }
    }
}

private struct LeaderboardChampionCard: View {
    let member: LeaderboardMemberState

    var body: some View {
        HStack(spacing: 16) {
            ProfileAvatarView(
                imageData: member.imageData,
                initials: member.initials,
                size: 88,
                backgroundColors: [AppTheme.cardTop.opacity(0.92), AppTheme.cardBottom]
            )

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Label("1st place", systemImage: "crown.fill")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.cardTop)

                    if member.isCurrentUser {
                        Text("You")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppTheme.cardTop)
                            .clipShape(Capsule())
                    }
                }

                Text(member.displayName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(2)

                Text("Level \(member.level)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)

                Text("\(member.xp) XP")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
            }

            Spacer()
        }
        .padding(20)
        .leaderboardPrimaryCard(cornerRadius: 28)
    }
}

private struct LeaderboardSpotlightCard: View {
    let member: LeaderboardMemberState
    let rank: Int

    var body: some View {
        VStack(spacing: 12) {
            ProfileAvatarView(
                imageData: member.imageData,
                initials: member.initials,
                size: 72,
                backgroundColors: [AppTheme.cardTop.opacity(0.92), AppTheme.cardBottom]
            )

            VStack(spacing: 4) {
                Text("\(rank)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)

                Text(member.displayName)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                    .lineLimit(1)

                Text("\(member.xp) XP")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.cardTop)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(AppTheme.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.outline, lineWidth: 1)
        )
    }
}

private struct LeaderboardListRow: View {
    let rank: Int
    let member: LeaderboardMemberState
    let isHighlighted: Bool

    var body: some View {
        HStack(spacing: 14) {
            Text("\(rank)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.cardTop)
                .frame(width: 28)

            ProfileAvatarView(
                imageData: member.imageData,
                initials: member.initials,
                size: 40,
                backgroundColors: [AppTheme.cardTop.opacity(0.92), AppTheme.cardBottom]
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(member.displayName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)

                Text("Level \(member.level)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(member.xp)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                Text("XP")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isHighlighted ? AppTheme.cardTop.opacity(0.35) : AppTheme.outline, lineWidth: isHighlighted ? 1.5 : 1)
        )
    }
}

private struct LeaderboardChatBubble: View {
    let message: GroupChatMessageState

    var body: some View {
        HStack {
            if message.isCurrentUser {
                Spacer(minLength: 54)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(message.senderName)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(message.isCurrentUser ? Color.white.opacity(0.9) : AppTheme.cardTop)

                    Text(message.sentAt.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(message.isCurrentUser ? Color.white.opacity(0.7) : AppTheme.textSecondary)
                }

                Text(message.body)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(message.isCurrentUser ? Color.white : AppTheme.textPrimary)
                    .lineSpacing(3)
            }
            .padding(14)
            .background(message.isCurrentUser ? AppTheme.cardTop : AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(message.isCurrentUser ? Color.clear : AppTheme.outline, lineWidth: 1)
            )

            if !message.isCurrentUser {
                Spacer(minLength: 54)
            }
        }
    }
}

private struct LeaderboardPrimaryCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .background {
                LinearGradient(
                    colors: [AppTheme.white.opacity(0.92), AppTheme.lightLavender.opacity(0.94)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(AppTheme.outline, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow, radius: 18, x: 0, y: 10)
    }
}

private struct LeaderboardSecondaryCardModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .background(AppTheme.white.opacity(0.9))
            .clipShape(shape)
            .overlay(
                shape
                    .stroke(AppTheme.outline, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow.opacity(0.45), radius: 10, x: 0, y: 6)
    }
}

private extension View {
    func leaderboardPrimaryCard(cornerRadius: CGFloat) -> some View {
        modifier(LeaderboardPrimaryCardModifier(cornerRadius: cornerRadius))
    }

    func leaderboardSecondaryCard(cornerRadius: CGFloat) -> some View {
        modifier(LeaderboardSecondaryCardModifier(cornerRadius: cornerRadius))
    }
}
