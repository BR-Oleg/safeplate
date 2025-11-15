import Foundation
#if canImport(FirebaseAuth)
import FirebaseCore
import FirebaseAuth

enum AuthManager {
    static func signInAnonymously(completion: @escaping (Bool, Error?) -> Void) {
        FirebaseManager.configure()
        // If Firebase is not configured (e.g. missing GoogleService-Info.plist),
        // signal an error so the UI can show that we are running offline.
        guard FirebaseApp.app() != nil else {
            let error = NSError(
                domain: "AuthManager",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Firebase não configurado (FirebaseApp.app() == nil)"]
            )
            completion(false, error)
            return
        }

        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                completion(false, error)
            } else {
                completion(true, nil)
            }
        }
    }
}
#else
enum AuthManager {
    static func signInAnonymously(completion: @escaping (Bool, Error?) -> Void) {
        // FirebaseAuth indisponível neste build (simulador CI sem dependências) -> seguir em modo offline
        completion(true, nil)
    }
}
#endif
