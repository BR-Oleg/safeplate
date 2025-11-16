import Foundation
#if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore
#endif

protocol CouponsRepositoryProtocol {
    func fetchUserCoupons(userId: String, completion: @escaping (Result<[Coupon], Error>) -> Void)
    func fetchAvailableCoupons(completion: @escaping (Result<[AvailableCoupon], Error>) -> Void)
    func redeemCoupon(availableCouponId: String, userId: String, completion: @escaping (Result<Coupon, Error>) -> Void)
}

enum CouponsRepositoryError: Error {
    case firebaseUnavailable
    case userNotFound
    case couponNotFound
    case insufficientPoints
}

struct CouponsRepository: CouponsRepositoryProtocol {
    func fetchUserCoupons(userId: String, completion: @escaping (Result<[Coupon], Error>) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(.failure(CouponsRepositoryError.firebaseUnavailable))
            return
        }
        let db = Firestore.firestore()
        db.collection("userCoupons")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let docs = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                let coupons: [Coupon] = docs.compactMap { doc in
                    let data = doc.data()
                    guard
                        let title = data["title"] as? String,
                        let description = data["description"] as? String,
                        let discount = data["discount"] as? Double,
                        let pointsCost = data["pointsCost"] as? Int
                    else { return nil }

                    let isActive = data["isActive"] as? Bool ?? true
                    let isUsed = data["isUsed"] as? Bool ?? false
                    let expiresAt = parseDate(data["expiresAt"]) ?? Date()
                    let usedAt = parseDate(data["usedAt"])

                    return Coupon(
                        id: doc.documentID,
                        title: title,
                        description: description,
                        pointsCost: pointsCost,
                        discount: discount,
                        isActive: isActive,
                        isUsed: isUsed,
                        expiresAt: expiresAt,
                        usedAt: usedAt
                    )
                }
                completion(.success(coupons))
            }
        #else
        completion(.failure(CouponsRepositoryError.firebaseUnavailable))
        #endif
    }

    func fetchAvailableCoupons(completion: @escaping (Result<[AvailableCoupon], Error>) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(.failure(CouponsRepositoryError.firebaseUnavailable))
            return
        }
        let db = Firestore.firestore()
        db.collection("availableCoupons")
            .whereField("isActive", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let docs = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                let coupons: [AvailableCoupon] = docs.compactMap { doc in
                    let data = doc.data()
                    guard
                        let title = data["title"] as? String,
                        let description = data["description"] as? String,
                        let discount = data["discount"] as? Double,
                        let pointsCost = data["pointsCost"] as? Int
                    else { return nil }
                    let validityDays = data["validityDays"] as? Int ?? 30
                    let establishmentId = data["establishmentId"] as? String
                    let establishmentName = data["establishmentName"] as? String

                    return AvailableCoupon(
                        id: doc.documentID,
                        title: title,
                        description: description,
                        discount: discount,
                        pointsCost: pointsCost,
                        validityDays: validityDays,
                        establishmentId: establishmentId,
                        establishmentName: establishmentName
                    )
                }
                completion(.success(coupons))
            }
        #else
        completion(.failure(CouponsRepositoryError.firebaseUnavailable))
        #endif
    }

    func redeemCoupon(availableCouponId: String, userId: String, completion: @escaping (Result<Coupon, Error>) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseFirestore) && canImport(FirebaseCore)
        FirebaseManager.configure()
        guard FirebaseApp.app() != nil else {
            completion(.failure(CouponsRepositoryError.firebaseUnavailable))
            return
        }
        let db = Firestore.firestore()

        let userRef = db.collection("users").document(userId)
        let availableRef = db.collection("availableCoupons").document(availableCouponId)

        userRef.getDocument { userSnapshot, userError in
            if let userError = userError {
                completion(.failure(userError))
                return
            }
            guard let userData = userSnapshot?.data() else {
                completion(.failure(CouponsRepositoryError.userNotFound))
                return
            }
            let currentPoints = userData["points"] as? Int ?? 0

            availableRef.getDocument { couponSnapshot, couponError in
                if let couponError = couponError {
                    completion(.failure(couponError))
                    return
                }
                guard let data = couponSnapshot?.data() else {
                    completion(.failure(CouponsRepositoryError.couponNotFound))
                    return
                }

                let isActive = data["isActive"] as? Bool ?? true
                guard isActive else {
                    completion(.failure(CouponsRepositoryError.couponNotFound))
                    return
                }

                guard let title = data["title"] as? String,
                      let description = data["description"] as? String,
                      let discount = data["discount"] as? Double,
                      let pointsCost = data["pointsCost"] as? Int
                else {
                    completion(.failure(CouponsRepositoryError.couponNotFound))
                    return
                }

                if currentPoints < pointsCost {
                    completion(.failure(CouponsRepositoryError.insufficientPoints))
                    return
                }

                let validityDays = data["validityDays"] as? Int ?? 30
                let establishmentId = data["establishmentId"] as? String
                let establishmentName = data["establishmentName"] as? String

                let now = Date()
                let expiresAt = Calendar.current.date(byAdding: .day, value: validityDays, to: now) ?? now
                let couponId = UUID().uuidString

                var couponData: [String: Any] = [
                    "userId": userId,
                    "establishmentId": establishmentId as Any,
                    "establishmentName": establishmentName as Any,
                    "title": title,
                    "description": description,
                    "discount": discount,
                    "createdAt": ISO8601DateFormatter().string(from: now),
                    "expiresAt": ISO8601DateFormatter().string(from: expiresAt),
                    "isActive": true,
                    "isUsed": false,
                    "pointsCost": pointsCost
                ]
                if establishmentId == nil { couponData.removeValue(forKey: "establishmentId") }
                if establishmentName == nil { couponData.removeValue(forKey: "establishmentName") }

                let userCouponRef = db.collection("userCoupons").document(couponId)

                let batch = db.batch()
                batch.setData(couponData, forDocument: userCouponRef)
                batch.updateData(["points": currentPoints - pointsCost], forDocument: userRef)

                batch.commit { batchError in
                    if let batchError = batchError {
                        completion(.failure(batchError))
                    } else {
                        let coupon = Coupon(
                            id: couponId,
                            title: title,
                            description: description,
                            pointsCost: pointsCost,
                            discount: discount,
                            isActive: true,
                            isUsed: false,
                            expiresAt: expiresAt,
                            usedAt: nil
                        )
                        completion(.success(coupon))
                    }
                }
            }
        }
        #else
        completion(.failure(CouponsRepositoryError.firebaseUnavailable))
        #endif
    }

    private func parseDate(_ value: Any?) -> Date? {
        if let str = value as? String {
            return ISO8601DateFormatter().date(from: str)
        }
        #if canImport(FirebaseFirestore)
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        }
        #endif
        return nil
    }
}
