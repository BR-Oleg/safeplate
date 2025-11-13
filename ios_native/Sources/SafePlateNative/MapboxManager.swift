import Foundation
#if canImport(MapboxMaps)
import MapboxMaps

enum MapboxManager {
    static func configure() {
        let token = "pk.eyJ1Ijoic2FmZXBsYXRlNTAwIiwiYSI6ImNtaGZoMXF2NTA1dDIya3B5dnljbXkzZG4ifQ.DgeBcy0YXvBdDLdPVerqjA"
        ResourceOptionsManager.default.resourceOptions.accessToken = token
    }
}
#else
enum MapboxManager {
    static func configure() { /* no-op */ }
}
#endif
