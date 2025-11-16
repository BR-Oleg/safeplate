import Foundation
#if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
#endif

protocol UserRepositoryProtocol {
    func fetchCurrentUser(completion: @escaping (Result<AppUser, Error>) -> Void)
    func updatePreferredLanguage(userId: String, languageCode: String, completion: @escaping (Error?) -> Void)
    func updatePremium(userId: String, isPremium: Bool, expiresAt: Date?, completion: @escaping (Error?) -> Void)
    func updateUserType(userId: String, userType: String, completion: @escaping (Error?) -> Void)
}

enum UserRepositoryError: Error {
    case notAuthenticated
    case firebaseUnavailable
}

struct UserRepository: UserRepositoryProtocol {
    func fetchCurrentUser(completion: @escaping (Result<AppUser, Error>) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(.failure(UserRepositoryError.firebaseUnavailable))
            return
        }
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(UserRepositoryError.notAuthenticated))
            return
        }

        let db = Firestore.firestore()
        let docRef = db.collection("users").document(currentUser.uid)
        docRef.getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let email = currentUser.email ?? ""
            let name = currentUser.displayName

            if let snapshot = snapshot, snapshot.exists, let data = snapshot.data() {
                let points = data["points"] as? Int ?? 0
                let isPremium = data["isPremium"] as? Bool ?? false
                let preferredLanguage = data["preferredLanguage"] as? String
                let userType = data["type"] as? String

                var premiumExpiresAt: Date?
                if let raw = data["premiumExpiresAt"] {
                    if let timestamp = raw as? Timestamp {
                        premiumExpiresAt = timestamp.dateValue()
                    } else if let str = raw as? String {
                        premiumExpiresAt = ISO8601DateFormatter().date(from: str)
                    }
                }

                let user = AppUser(
                    id: currentUser.uid,
                    email: email,
                    name: name,
                    points: points,
                    isPremium: isPremium,
                    premiumExpiresAt: premiumExpiresAt,
                    preferredLanguageCode: preferredLanguage,
                    userType: userType
                )
                completion(.success(user))
            } else {
                var userData: [String: Any] = [
                    "id": currentUser.uid,
                    "email": email,
                    "type": "user",
                    "points": 0,
                    "isPremium": false,
                    "totalCheckIns": 0,
                    "totalReviews": 0,
                    "totalReferrals": 0,
                    "preferredLanguage": AppState.Language.pt.rawValue
                ]
                if let name = name {
                    userData["name"] = name
                }

                docRef.setData(userData, merge: true) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        let user = AppUser(
                            id: currentUser.uid,
                            email: email,
                            name: name,
                            points: 0,
                            isPremium: false,
                            premiumExpiresAt: nil,
                            preferredLanguageCode: AppState.Language.pt.rawValue,
                            userType: "user"
                        )
                        completion(.success(user))
                    }
                }
            }
        }
        #else
        completion(.failure(UserRepositoryError.firebaseUnavailable))
        #endif
    }

    func updatePreferredLanguage(userId: String, languageCode: String, completion: @escaping (Error?) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(UserRepositoryError.firebaseUnavailable)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "preferredLanguage": languageCode
        ]) { error in
            completion(error)
        }
        #else
        completion(UserRepositoryError.firebaseUnavailable)
        #endif
    }

    func updatePremium(userId: String, isPremium: Bool, expiresAt: Date?, completion: @escaping (Error?) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(UserRepositoryError.firebaseUnavailable)
            return
        }
        let db = Firestore.firestore()
        var updates: [String: Any] = [
            "isPremium": isPremium
        ]
        if let expiresAt = expiresAt {
            updates["premiumExpiresAt"] = Timestamp(date: expiresAt)
        } else {
            updates["premiumExpiresAt"] = FieldValue.delete()
        }
        db.collection("users").document(userId).updateData(updates) { error in
            completion(error)
        }
        #else
        completion(UserRepositoryError.firebaseUnavailable)
        #endif
    }

    func updateUserType(userId: String, userType: String, completion: @escaping (Error?) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(UserRepositoryError.firebaseUnavailable)
            return
        }
        let db = Firestore.firestore()
        db.collection("users").document(userId).updateData([
            "type": userType
        ]) { error in
            completion(error)
        }
        #else
        completion(UserRepositoryError.firebaseUnavailable)
        #endif
    }
}
