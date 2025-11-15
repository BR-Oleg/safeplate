import Foundation
#if canImport(FirebaseCore)
import FirebaseCore

enum FirebaseManager {
    static func configure() {
        if FirebaseApp.app() != nil { return }
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        } else {
            print("FirebaseManager: GoogleService-Info.plist not found. Running without Firebase.")
        }
    }
}
#else
enum FirebaseManager {
    static func configure() { /* no-op */ }
}
#endif
