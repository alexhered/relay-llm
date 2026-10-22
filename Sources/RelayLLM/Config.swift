import Foundation

struct Config {
    let apiKey: String
    let relayToken: String
    let defaultModel: String
    let host: String
    let port: Int

    static func load() -> Config {
        let env = ProcessInfo.processInfo.environment

        guard let apiKey = env["OPENROUTER_API_KEY"], !apiKey.isEmpty else {
            fatalError("OPENROUTER_API_KEY is not set")
        }
        guard let token = env["RELAY_TOKEN"], !token.isEmpty else {
            fatalError("RELAY_TOKEN is not set")
        }

        return Config(
            apiKey: apiKey,
            relayToken: token,
            defaultModel: env["DEFAULT_MODEL"] ?? "openai/gpt-4o-mini",
            host: env["HOST"] ?? "0.0.0.0",
            port: Int(env["PORT"] ?? "") ?? 8080
        )
    }
}
