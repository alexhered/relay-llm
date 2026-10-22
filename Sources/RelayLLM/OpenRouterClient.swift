import Foundation

enum OpenRouterError: Error {
    case badStatus(Int, String)
    case emptyReply
}

struct OpenRouterClient {
    let apiKey: String
    let url = URL(string: "https://openrouter.ai/api/v1/chat/completions")!

    func send(prompt: String, model: String) async throws -> String {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60

        let body = ChatRequest(
            model: model,
            messages: [ChatMessage(role: "user", content: prompt)]
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            let text = String(data: data, encoding: .utf8) ?? ""
            throw OpenRouterError.badStatus(http.statusCode, text)
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let reply = decoded.choices.first?.message.content else {
            throw OpenRouterError.emptyReply
        }

        // TODO: keep conversation history so follow-up questions work
        return reply
    }
}
