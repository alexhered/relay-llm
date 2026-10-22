import HTTPTypes
import Foundation
import Hummingbird

// Read settings from environment variables
let config = Config.load()
let client = OpenRouterClient(apiKey: config.apiKey)

// TODO: add rate limiting in case the token leaks
// TODO: add streaming support (OpenRouter supports "stream": true)
let router = Router()

router.get("health") { _, _ -> String in
    return "ok"
}

router.post("ask") { request, context -> AskResponse in
    // Simple shared token check so only my phone can use the server
    let tokenHeader = HTTPField.Name("X-Relay-Token")!
    guard request.headers[tokenHeader] == config.relayToken else {
        throw HTTPError(.unauthorized)
    }

    let body = try await request.decode(as: AskRequest.self, context: context)

    if body.prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        throw HTTPError(.badRequest, message: "prompt is empty")
    }

    let model = body.model ?? config.defaultModel

    do {
        let reply = try await client.send(prompt: body.prompt, model: model)
        return AskResponse(reply: reply)
    } catch {
        print("OpenRouter error: \(error)")
        throw HTTPError(.badGateway, message: "could not get a reply from the model")
    }
}

let app = Application(
    router: router,
    configuration: .init(address: .hostname(config.host, port: config.port))
)

print("relay-llm listening on \(config.host):\(config.port)")
try await app.runService()
