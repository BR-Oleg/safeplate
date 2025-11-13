import Foundation
import Combine

final class AppState: ObservableObject {
    enum Phase {
        case splash
        case unauthenticated
        case authenticated
    }

    @Published var phase: Phase = .splash

    func proceedFromSplash() {
        if phase == .splash {
            phase = .unauthenticated
        }
    }

    func login() {
        phase = .authenticated
    }

    func logout() {
        phase = .unauthenticated
    }
}
