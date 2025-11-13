import Foundation
#if canImport(FirebaseCore)
import FirebaseCore

enum FirebaseManager {
    static func configure() {
        if FirebaseApp.app() != nil { return }
        let options = FirebaseOptions(
            googleAppID: "1:476899420653:ios:fcd5a28dc225e9ae03dfe4",
            gcmSenderID: "476899420653"
        )
        options.apiKey = "AIzaSyBhAWZ61YF4Qhl_GJjRl6avMpkUZuK6n8k"
        options.projectID = "safeplate-a14e9"
        options.storageBucket = "safeplate-a14e9.firebasestorage.app"
        FirebaseApp.configure(options: options)
    }
}
#else
enum FirebaseManager {
    static func configure() { /* no-op */ }
}
#endif
