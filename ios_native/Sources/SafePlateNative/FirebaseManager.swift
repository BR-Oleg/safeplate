import Foundation
#if canImport(FirebaseCore)
import FirebaseCore

enum FirebaseManager {
    static func configure() {
        if FirebaseApp.app() != nil { return }
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
            if FirebaseApp.app() != nil { return }
        }

        #if DEBUG
        if FirebaseApp.app() == nil {
            let options = FirebaseOptions(
                googleAppID: "1:476899420653:ios:3c8037d0a8fae5e103dfe4",
                gcmSenderID: "476899420653"
            )
            options.apiKey = "AIzaSyD6BrhUmXeqFYiPnNbVbxkxvxwnyqNrzQ8"
            options.projectID = "safeplate-a14e9"
            options.storageBucket = "safeplate-a14e9.firebasestorage.app"
            FirebaseApp.configure(options: options)
        }
        #else
        if FirebaseApp.app() == nil {
            print("FirebaseManager: GoogleService-Info.plist not found or configure() failed. Running without Firebase.")
        }
        #endif
    }
}
#else
enum FirebaseManager {
    static func configure() { /* no-op */ }
}
#endif
