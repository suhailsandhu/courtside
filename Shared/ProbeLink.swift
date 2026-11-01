import Foundation

enum ProbeLink {
    static func make(token: String) -> URL {
        var components = URLComponents()
        components.scheme = "courtside-probe"
        components.host = "widget"
        components.queryItems = [URLQueryItem(name: "token", value: token)]
        return components.url!
    }

    static func token(from url: URL) -> String? {
        guard url.scheme == "courtside-probe", url.host == "widget",
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let token = items.first(where: { $0.name == "token" })?.value,
              !token.isEmpty, token.count <= 100 else { return nil }
        return token
    }
}
