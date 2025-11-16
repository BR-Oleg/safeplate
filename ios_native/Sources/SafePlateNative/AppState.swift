import Foundation
import Combine

final class AppState: ObservableObject {
    enum Phase {
        case splash
        case unauthenticated
        case authenticated
    }

    enum Language: String {
        case pt
        case en
        case es
    }

    @Published var phase: Phase = .splash
    @Published var language: Language = .pt
    @Published var isPremium: Bool = false
    @Published var points: Int = 0
    @Published var userId: String?

    private let languageStorageKey = "app_language"

    private let translations: [Language: [String: String]] = [
        .pt: [
            "tab_search": "Buscar",
            "tab_favorites": "Favoritos",
            "tab_coupons": "Cupons",
            "tab_profile": "Perfil",
            "nav_search": "Buscar",
            "nav_favorites": "Favoritos",
            "nav_coupons": "Cupons",
            "nav_profile": "Perfil"
        ],
        .en: [
            "tab_search": "Search",
            "tab_favorites": "Favorites",
            "tab_coupons": "Coupons",
            "tab_profile": "Profile",
            "nav_search": "Search",
            "nav_favorites": "Favorites",
            "nav_coupons": "Coupons",
            "nav_profile": "Profile"
        ],
        .es: [
            "tab_search": "Buscar",
            "tab_favorites": "Favoritos",
            "tab_coupons": "Cupones",
            "tab_profile": "Perfil",
            "nav_search": "Buscar",
            "nav_favorites": "Favoritos",
            "nav_coupons": "Cupones",
            "nav_profile": "Perfil"
        ]
    ]

    init() {
        loadLanguage()
    }

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
        userId = nil
        points = 0
        isPremium = false
    }

    private func loadLanguage() {
        if let raw = UserDefaults.standard.string(forKey: languageStorageKey),
           let lang = Language(rawValue: raw) {
            language = lang
        }
    }

    func setLanguage(_ lang: Language) {
        language = lang
        UserDefaults.standard.set(lang.rawValue, forKey: languageStorageKey)
    }

    func setPremium(_ value: Bool) {
        isPremium = value
    }

    func setPoints(_ value: Int) {
        points = max(0, value)
    }

    func applyUser(_ user: AppUser) {
        userId = user.id
        setPoints(user.points)
        setPremium(user.isPremiumActive)
        if let code = user.preferredLanguageCode,
           let lang = Language(rawValue: code) {
            setLanguage(lang)
        }
    }

    func localized(_ key: String) -> String {
        translations[language]?[key] ?? translations[.pt]?[key] ?? key
    }
}
