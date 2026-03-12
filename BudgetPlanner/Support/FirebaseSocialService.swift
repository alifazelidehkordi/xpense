import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif
import UIKit

struct SocialSessionState: Hashable {
    let userID: String
    let email: String?
    let displayName: String
    let providerName: String
}

struct SocialProfilePayload: Hashable {
    let firstName: String
    let lastName: String
    let displayName: String
    let university: String
    let initials: String
    let xp: Int
    let level: Int
    let rankTitle: String
    let learningStreak: Int
    let imageData: Data?
}

struct SocialGroupRecord: Hashable {
    let id: String
    let name: String
    let inviteCode: String
    let ownerID: String
    let memberCount: Int
}

struct SocialMemberRecord: Identifiable, Hashable {
    let id: String
    let displayName: String
    let xp: Int
    let level: Int
    let rankTitle: String
    let isCurrentUser: Bool
    let imageData: Data?
    let initials: String
}

struct SocialChatMessageRecord: Identifiable, Hashable {
    let id: String
    let senderName: String
    let senderInitials: String
    let body: String
    let sentAt: Date
    let isCurrentUser: Bool
}

enum SocialServiceError: LocalizedError {
    case notAuthenticated
    case alreadyInGroup
    case invalidGroupName
    case invalidInviteCode
    case missingGoogleClientID
    case googleSDKUnavailable
    case missingPresentationContext
    case missingAppleToken
    case missingAppleNonce
    case malformedAppleToken
    case emptyMessage

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "Sign in first to use groups and leaderboard features."
        case .alreadyInGroup:
            return "You are already connected to a group."
        case .invalidGroupName:
            return "Enter a valid group name."
        case .invalidInviteCode:
            return "The invite code was not found. Check it and try again."
        case .missingGoogleClientID:
            return "Google Sign-In is not fully configured. Replace GoogleService-Info.plist with the iOS config that includes the Google client identifiers."
        case .googleSDKUnavailable:
            return "Google Sign-In SDK is not installed in the project yet."
        case .missingPresentationContext:
            return "Unable to present the Google sign-in screen from the current window."
        case .missingAppleToken:
            return "Apple Sign-In did not return an identity token."
        case .missingAppleNonce:
            return "Apple Sign-In nonce is missing. Start the sign-in flow again."
        case .malformedAppleToken:
            return "Apple Sign-In returned an unreadable identity token."
        case .emptyMessage:
            return "Enter a message before sending it."
        }
    }
}

@MainActor
final class FirebaseSocialService {
    var onSessionChange: ((SocialSessionState?) -> Void)?
    var onGroupChange: ((SocialGroupRecord?) -> Void)?
    var onMembersChange: (([SocialMemberRecord]) -> Void)?
    var onMessagesChange: (([SocialChatMessageRecord]) -> Void)?
    var onError: ((String) -> Void)?

    private lazy var auth: Auth = {
        Self.ensureFirebaseConfigured()
        return Auth.auth()
    }()
    private lazy var db: Firestore = {
        Self.ensureFirebaseConfigured()
        return Firestore.firestore()
    }()

    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    private var userDocumentListener: ListenerRegistration?
    private var groupDocumentListener: ListenerRegistration?
    private var groupMembersListener: ListenerRegistration?
    private var groupMessagesListener: ListenerRegistration?

    private var currentGroupID: String?

    init() {
        Self.ensureFirebaseConfigured()
        observeAuthenticationState()
    }

    deinit {
        MainActor.assumeIsolated {
            if let authListenerHandle {
                Auth.auth().removeStateDidChangeListener(authListenerHandle)
            }
            userDocumentListener?.remove()
            groupDocumentListener?.remove()
            groupMembersListener?.remove()
            groupMessagesListener?.remove()
        }
    }

    var isSignedIn: Bool {
        auth.currentUser != nil
    }

    var googleSignInIssue: String? {
        #if canImport(GoogleSignIn)
        guard FirebaseApp.app()?.options.clientID != nil else {
            return SocialServiceError.missingGoogleClientID.localizedDescription
        }
        return nil
        #else
        return SocialServiceError.googleSDKUnavailable.localizedDescription
        #endif
    }

    func refreshState() async {
        await handleAuthenticationChange(auth.currentUser)
    }

    func signInWithGoogle() async throws {
        #if canImport(GoogleSignIn)
        guard let clientID = FirebaseApp.app()?.options.clientID, !clientID.isEmpty else {
            throw SocialServiceError.missingGoogleClientID
        }
        guard let presentingController = Self.topViewController() else {
            throw SocialServiceError.missingPresentationContext
        }

        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingController)
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw SocialServiceError.missingGoogleClientID
        }

        let accessToken = signInResult.user.accessToken.tokenString
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        _ = try await auth.signIn(with: credential)
        #else
        throw SocialServiceError.googleSDKUnavailable
        #endif
    }

    func prepareAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        let nonce = Self.randomNonceString()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Self.sha256(nonce)
        return nonce
    }

    func signInWithApple(result: Result<ASAuthorization, Error>, nonce: String?) async throws {
        guard let nonce else {
            throw SocialServiceError.missingAppleNonce
        }

        let authorization: ASAuthorization
        switch result {
        case .success(let value):
            authorization = value
        case .failure(let error):
            throw error
        }

        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw SocialServiceError.missingAppleToken
        }
        guard let identityToken = credential.identityToken else {
            throw SocialServiceError.missingAppleToken
        }
        guard let tokenString = String(data: identityToken, encoding: .utf8) else {
            throw SocialServiceError.malformedAppleToken
        }

        let firebaseCredential = OAuthProvider.appleCredential(
            withIDToken: tokenString,
            rawNonce: nonce,
            fullName: credential.fullName
        )

        _ = try await auth.signIn(with: firebaseCredential)
    }

    func signOut() throws {
        #if canImport(GoogleSignIn)
        GIDSignIn.sharedInstance.signOut()
        #endif
        try auth.signOut()
    }

    func syncProfile(_ payload: SocialProfilePayload) async throws {
        guard let user = auth.currentUser else { return }

        let userReference = db.collection(Self.userCollection).document(user.uid)
        var data: [String: Any] = [
            "displayName": payload.displayName,
            "firstName": payload.firstName,
            "lastName": payload.lastName,
            "university": payload.university,
            "initials": payload.initials,
            "xp": payload.xp,
            "level": payload.level,
            "rankTitle": payload.rankTitle,
            "learningStreak": payload.learningStreak,
            "email": user.email as Any,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if let imageData = Self.makeAvatarThumbnail(from: payload.imageData) {
            data["profileImageData"] = imageData
        }

        try await userReference.setData(data, merge: true)

        guard let currentGroupID else { return }
        let memberReference = db
            .collection(Self.groupCollection)
            .document(currentGroupID)
            .collection(Self.memberCollection)
            .document(user.uid)

        try await memberReference.setData(memberData(from: payload, userID: user.uid), merge: true)
        try await db.collection(Self.groupCollection).document(currentGroupID).setData([
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func createGroup(named name: String, payload: SocialProfilePayload) async throws {
        guard let user = auth.currentUser else {
            throw SocialServiceError.notAuthenticated
        }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.count >= 3 else {
            throw SocialServiceError.invalidGroupName
        }
        guard currentGroupID == nil else {
            throw SocialServiceError.alreadyInGroup
        }

        let groupReference = db.collection(Self.groupCollection).document()
        let inviteCode = try await uniqueInviteCode()

        try await groupReference.setData([
            "name": trimmedName,
            "inviteCode": inviteCode,
            "ownerID": user.uid,
            "memberCount": 1,
            "createdAt": FieldValue.serverTimestamp(),
            "updatedAt": FieldValue.serverTimestamp()
        ])

        try await groupReference
            .collection(Self.memberCollection)
            .document(user.uid)
            .setData(memberData(from: payload, userID: user.uid, includeJoinDate: true))

        try await db.collection(Self.userCollection).document(user.uid).setData([
            "currentGroupID": groupReference.documentID,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func joinGroup(inviteCode: String, payload: SocialProfilePayload) async throws {
        guard let user = auth.currentUser else {
            throw SocialServiceError.notAuthenticated
        }
        guard currentGroupID == nil else {
            throw SocialServiceError.alreadyInGroup
        }

        let normalizedCode = inviteCode
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        let groupQuery = try await db.collection(Self.groupCollection)
            .whereField("inviteCode", isEqualTo: normalizedCode)
            .limit(to: 1)
            .getDocuments()

        guard let groupDocument = groupQuery.documents.first else {
            throw SocialServiceError.invalidInviteCode
        }

        let memberReference = groupDocument.reference
            .collection(Self.memberCollection)
            .document(user.uid)

        let existingMember = try await memberReference.getDocument()
        if !existingMember.exists {
            try await groupDocument.reference.setData([
                "memberCount": FieldValue.increment(Int64(1)),
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)
        }

        try await memberReference.setData(
            memberData(from: payload, userID: user.uid, includeJoinDate: !existingMember.exists),
            merge: true
        )

        try await db.collection(Self.userCollection).document(user.uid).setData([
            "currentGroupID": groupDocument.documentID,
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    func sendMessage(_ text: String, senderName: String, senderInitials: String) async throws {
        guard let user = auth.currentUser else {
            throw SocialServiceError.notAuthenticated
        }
        guard let currentGroupID else {
            throw SocialServiceError.invalidInviteCode
        }

        let trimmedMessage = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedMessage.isEmpty else {
            throw SocialServiceError.emptyMessage
        }

        try await db.collection(Self.groupCollection)
            .document(currentGroupID)
            .collection(Self.messageCollection)
            .addDocument(data: [
                "senderID": user.uid,
                "senderName": senderName,
                "senderInitials": senderInitials,
                "body": trimmedMessage,
                "createdAt": FieldValue.serverTimestamp()
            ])

        try await db.collection(Self.groupCollection).document(currentGroupID).setData([
            "updatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }

    private func observeAuthenticationState() {
        authListenerHandle = auth.addStateDidChangeListener { [weak self] _, user in
            guard let self else { return }
            Task { @MainActor in
                await self.handleAuthenticationChange(user)
            }
        }
    }

    private func handleAuthenticationChange(_ user: User?) async {
        if let user {
            onSessionChange?(sessionState(for: user))
            await ensureUserDocumentExists(for: user)
            observeUserDocument(for: user.uid)
        } else {
            onSessionChange?(nil)
            currentGroupID = nil
            userDocumentListener?.remove()
            clearGroupListeners()
            onGroupChange?(nil)
            onMembersChange?([])
            onMessagesChange?([])
        }
    }

    private func observeUserDocument(for userID: String) {
        userDocumentListener?.remove()
        userDocumentListener = db.collection(Self.userCollection).document(userID).addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let error {
                self.onError?(error.localizedDescription)
                return
            }

            let groupID = snapshot?.data()?["currentGroupID"] as? String
            Task { @MainActor in
                await self.applyCurrentGroupID(groupID)
            }
        }
    }

    private func applyCurrentGroupID(_ groupID: String?) async {
        guard currentGroupID != groupID else { return }
        currentGroupID = groupID

        guard let groupID else {
            clearGroupListeners()
            onGroupChange?(nil)
            onMembersChange?([])
            onMessagesChange?([])
            return
        }

        observeGroupDocument(groupID: groupID)
        observeGroupMembers(groupID: groupID)
        observeGroupMessages(groupID: groupID)
    }

    private func observeGroupDocument(groupID: String) {
        groupDocumentListener?.remove()
        groupDocumentListener = db.collection(Self.groupCollection).document(groupID).addSnapshotListener { [weak self] snapshot, error in
            guard let self else { return }
            if let error {
                self.onError?(error.localizedDescription)
                return
            }
            guard let snapshot, snapshot.exists, let data = snapshot.data() else {
                self.onGroupChange?(nil)
                return
            }

            let record = SocialGroupRecord(
                id: snapshot.documentID,
                name: data["name"] as? String ?? "BudgetQuest Circle",
                inviteCode: data["inviteCode"] as? String ?? "----",
                ownerID: data["ownerID"] as? String ?? "",
                memberCount: data["memberCount"] as? Int ?? 0
            )
            self.onGroupChange?(record)
        }
    }

    private func observeGroupMembers(groupID: String) {
        groupMembersListener?.remove()
        groupMembersListener = db.collection(Self.groupCollection)
            .document(groupID)
            .collection(Self.memberCollection)
            .order(by: "xp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.onError?(error.localizedDescription)
                    return
                }

                let currentUserID = self.auth.currentUser?.uid
                let members: [SocialMemberRecord] = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let displayName = data["displayName"] as? String ?? "BudgetQuest User"
                    let initials = data["initials"] as? String ?? "BQ"
                    let xp = data["xp"] as? Int ?? 0
                    let level = data["level"] as? Int ?? 1
                    let rankTitle = data["rankTitle"] as? String ?? "Finance Apprentice"
                    let imageData = data["profileImageData"] as? Data

                    return SocialMemberRecord(
                        id: document.documentID,
                        displayName: displayName,
                        xp: xp,
                        level: level,
                        rankTitle: rankTitle,
                        isCurrentUser: document.documentID == currentUserID,
                        imageData: imageData,
                        initials: initials
                    )
                } ?? []

                self.onMembersChange?(members)
            }
    }

    private func observeGroupMessages(groupID: String) {
        groupMessagesListener?.remove()
        groupMessagesListener = db.collection(Self.groupCollection)
            .document(groupID)
            .collection(Self.messageCollection)
            .order(by: "createdAt")
            .limit(toLast: 30)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    self.onError?(error.localizedDescription)
                    return
                }

                let currentUserID = self.auth.currentUser?.uid
                let messages: [SocialChatMessageRecord] = snapshot?.documents.compactMap { document in
                    let data = document.data()
                    let senderID = data["senderID"] as? String ?? ""
                    let senderName = data["senderName"] as? String ?? "Friend"
                    let senderInitials = data["senderInitials"] as? String ?? "BQ"
                    let body = data["body"] as? String ?? ""
                    let sentAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? .now

                    return SocialChatMessageRecord(
                        id: document.documentID,
                        senderName: senderName,
                        senderInitials: senderInitials,
                        body: body,
                        sentAt: sentAt,
                        isCurrentUser: senderID == currentUserID
                    )
                } ?? []

                self.onMessagesChange?(messages)
            }
    }

    private func ensureUserDocumentExists(for user: User) async {
        let reference = db.collection(Self.userCollection).document(user.uid)
        var data: [String: Any] = [
            "displayName": user.displayName ?? (user.email ?? "BudgetQuest User"),
            "email": user.email as Any,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if let currentGroupID {
            data["currentGroupID"] = currentGroupID
        }

        do {
            try await reference.setData(data, merge: true)
        } catch {
            onError?(error.localizedDescription)
        }
    }

    private func memberData(from payload: SocialProfilePayload, userID: String, includeJoinDate: Bool = false) -> [String: Any] {
        var data: [String: Any] = [
            "userID": userID,
            "displayName": payload.displayName,
            "initials": payload.initials,
            "xp": payload.xp,
            "level": payload.level,
            "rankTitle": payload.rankTitle,
            "updatedAt": FieldValue.serverTimestamp()
        ]

        if includeJoinDate {
            data["joinedAt"] = FieldValue.serverTimestamp()
        }

        if let imageData = Self.makeAvatarThumbnail(from: payload.imageData) {
            data["profileImageData"] = imageData
        }

        return data
    }

    private func uniqueInviteCode() async throws -> String {
        while true {
            let code = Self.randomInviteCode()
            let existing = try await db.collection(Self.groupCollection)
                .whereField("inviteCode", isEqualTo: code)
                .limit(to: 1)
                .getDocuments()

            if existing.documents.isEmpty {
                return code
            }
        }
    }

    private func sessionState(for user: User) -> SocialSessionState {
        let providerName = user.providerData.first.map(Self.providerName(for:)) ?? "Account"
        return SocialSessionState(
            userID: user.uid,
            email: user.email,
            displayName: user.displayName ?? user.email ?? "BudgetQuest User",
            providerName: providerName
        )
    }

    private func clearGroupListeners() {
        groupDocumentListener?.remove()
        groupDocumentListener = nil
        groupMembersListener?.remove()
        groupMembersListener = nil
        groupMessagesListener?.remove()
        groupMessagesListener = nil
    }

    private func removeAllListeners() {
        userDocumentListener?.remove()
        userDocumentListener = nil
        clearGroupListeners()
    }

    private static let userCollection = "users"
    private static let groupCollection = "groups"
    private static let memberCollection = "members"
    private static let messageCollection = "messages"

    private static func ensureFirebaseConfigured() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    private static func providerName(for provider: UserInfo) -> String {
        switch provider.providerID {
        case "apple.com":
            return "Apple"
        case "google.com":
            return "Google"
        default:
            return "Account"
        }
    }

    private static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let rootController = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController

        if let navigationController = rootController as? UINavigationController {
            return topViewController(base: navigationController.visibleViewController)
        }
        if let tabBarController = rootController as? UITabBarController {
            return topViewController(base: tabBarController.selectedViewController)
        }
        if let presented = rootController?.presentedViewController {
            return topViewController(base: presented)
        }
        return rootController
    }

    private static func randomInviteCode() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).map { _ in alphabet.randomElement() ?? "A" })
    }

    private static func randomNonceString(length: Int = 32) -> String {
        guard length > 0 else { return "" }
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }

    private static func makeAvatarThumbnail(from data: Data?) -> Data? {
        guard let data, let image = UIImage(data: data) else { return nil }

        let targetSize = CGSize(width: 180, height: 180)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }

        return resizedImage.jpegData(compressionQuality: 0.72)
    }
}
