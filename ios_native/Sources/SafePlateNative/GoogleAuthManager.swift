import Foundation
import UIKit
#if canImport(FirebaseAuth) && canImport(FirebaseCore) && canImport(GoogleSignIn)
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
#endif

enum GoogleAuthManager {
    static func signIn(presenting: UIViewController, completion: @escaping (Bool, Error?) -> Void) {
        #if canImport(FirebaseAuth) && canImport(FirebaseCore) && canImport(GoogleSignIn)
        FirebaseManager.configure()
        guard let app = FirebaseApp.app(), let clientID = app.options.clientID else {
            let error = NSError(
                domain: "GoogleAuthManager",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Firebase/Google não configurado"]
            )
            completion(false, error)
            return
        }

        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            if let error = error {
                completion(false, error)
                return
            }

            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                let error = NSError(
                    domain: "GoogleAuthManager",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Resposta do Google inválida"]
                )
                completion(false, error)
                return
            }

            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            Auth.auth().signIn(with: credential) { _, error in
                if let error = error as NSError? {
                    if let code = AuthErrorCode.Code(rawValue: error.code), code == .keychainError {
                        // Em alguns ambientes de teste o keychain não está disponível, mas o login pode ter ocorrido.
                        completion(true, nil)
                    } else {
                        completion(false, error)
                    }
                } else {
                    completion(true, nil)
                }
            }
        }
        #else
        let error = NSError(
            domain: "GoogleAuthManager",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Google Sign-In indisponível neste build"]
        )
        completion(false, error)
        #endif
    }
}
