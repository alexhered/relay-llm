import Hummingbird

// What the phone sends to /ask
struct AskRequest: Decodable {
    let prompt: String
    let model: String?
}

// What the server sends back
struct AskResponse: ResponseEncodable {
    let reply: String
}

// OpenRouter uses the same format as the OpenAI chat completions API.
// I only added the fields I actually use.
struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatRequest: Encodable {
    let model: String
    let messages: [ChatMessage]
}

struct ChatResponse: Decodable {
    struct Choice: Decodable {
        let message: ChatMessage
    }
    let choices: [Choice]
}
