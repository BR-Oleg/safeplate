import XCTest

final class SafePlateNativeUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testBasicFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Wait for login button and tap it
        let loginButton = app.buttons["loginButton"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()

        // Wait for the tab bar
        let tabBar = app.tabBars.element(boundBy: 0)
        XCTAssertTrue(tabBar.waitForExistence(timeout: 5))

        // Navigate through tabs
        let favoritos = tabBar.buttons["Favoritos"]
        if favoritos.exists { favoritos.tap() }
        let cupons = tabBar.buttons["Cupons"]
        if cupons.exists { cupons.tap() }
        let perfil = tabBar.buttons["Perfil"]
        if perfil.exists { perfil.tap() }

        // Pause briefly for video capture
        sleep(2)
    }
}
