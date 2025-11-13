import Foundation
#if canImport(FirebaseAuth)
import FirebaseCore
import FirebaseAuth

enum AuthManager {
    static func signInAnonymously(completion: @escaping (Bool, Error?) -> Void) {
        FirebaseManager.configure()
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
