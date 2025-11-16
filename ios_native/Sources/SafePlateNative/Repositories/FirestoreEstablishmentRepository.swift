import Foundation
#if canImport(FirebaseFirestore) && canImport(FirebaseCore)
import FirebaseFirestore
import FirebaseCore
#endif

struct FirestoreEstablishmentRepository {
    func fetchAll(completion: @escaping (Result<[Establishment], Error>) -> Void) {
        #if canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(.success([]))
            return
        }

        let db = Firestore.firestore()
        db.collection("establishments").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let documents = snapshot?.documents else {
                completion(.success([]))
                return
            }

            let establishments: [Establishment] = documents.compactMap { doc in
                let data = doc.data()

                guard
                    let name = data["name"] as? String
                else { return nil }

                let description = (data["description"] as? String)
                    ?? (data["shortDescription"] as? String)
                    ?? (data["address"] as? String)
                    ?? ""

                let latitude: Double
                if let value = data["latitude"] as? Double {
                    latitude = value
                } else if let number = data["latitude"] as? NSNumber {
                    latitude = number.doubleValue
                } else {
                    return nil
                }

                let longitude: Double
                if let value = data["longitude"] as? Double {
                    longitude = value
                } else if let number = data["longitude"] as? NSNumber {
                    longitude = number.doubleValue
                } else {
                    return nil
                }

                let rating: Double
                if let value = data["rating"] as? Double {
                    rating = value
                } else if let number = data["rating"] as? NSNumber {
                    rating = number.doubleValue
                } else {
                    rating = 0
                }

                let categories: [String]
                if let cats = data["categories"] as? [String] {
                    categories = cats
                } else if let category = data["category"] as? String {
                    categories = [category]
                } else {
                    categories = []
                }

                return Establishment(
                    id: doc.documentID,
                    name: name,
                    description: description,
                    latitude: latitude,
                    longitude: longitude,
                    rating: rating,
                    categories: categories
                )
            }

            completion(.success(establishments))
        }
        #else
        completion(.success([]))
        #endif
    }
}
