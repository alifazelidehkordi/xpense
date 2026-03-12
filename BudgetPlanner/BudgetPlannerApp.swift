import SwiftUI
import FirebaseCore
#if canImport(GoogleSignIn)
import GoogleSignIn
#endif

final class BudgetPlannerAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        return true
    }
}

@main
struct BudgetPlannerApp: App {
    @UIApplicationDelegateAdaptor(BudgetPlannerAppDelegate.self) private var appDelegate
    @StateObject private var store: BudgetPlannerStore

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        _store = StateObject(wrappedValue: BudgetPlannerStore())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onOpenURL { url in
                    #if canImport(GoogleSignIn)
                    GIDSignIn.sharedInstance.handle(url)
                    #endif
                }
        }
    }
}
