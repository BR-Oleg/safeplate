import Foundation
#if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
#endif

protocol FavoritesRepositoryProtocol {
    func fetchFavoriteIDs(userId: String, completion: @escaping (Result<Set<String>, Error>) -> Void)
    func setFavorite(establishmentId: String, userId: String, isFavorite: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}

enum FavoritesRepositoryError: Error {
    case firebaseUnavailable
}

struct FavoritesRepository: FavoritesRepositoryProtocol {
    func fetchFavoriteIDs(userId: String, completion: @escaping (Result<Set<String>, Error>) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(.failure(FavoritesRepositoryError.firebaseUnavailable))
            return
        }
        let db = Firestore.firestore()
        db.collection("favorites")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let docs = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                let ids: Set<String> = Set(docs.compactMap { $0.data()["establishmentId"] as? String })
                completion(.success(ids))
            }
        #else
        completion(.failure(FavoritesRepositoryError.firebaseUnavailable))
        #endif
    }

    func setFavorite(establishmentId: String, userId: String, isFavorite: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(.failure(FavoritesRepositoryError.firebaseUnavailable))
            return
        }
        let db = Firestore.firestore()
        let docId = "\(userId)_\(establishmentId)"
        let ref = db.collection("favorites").document(docId)

        if isFavorite {
            let data: [String: Any] = [
                "userId": userId,
                "establishmentId": establishmentId,
                "savedAt": ISO8601DateFormatter().string(from: Date())
            ]
            ref.setData(data, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } else {
            ref.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
        #else
        completion(.failure(FavoritesRepositoryError.firebaseUnavailable))
        #endif
    }
}
