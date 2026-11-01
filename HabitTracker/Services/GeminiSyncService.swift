import Foundation

public final class GeminiSyncService {
    public static let shared = GeminiSyncService()
    
    private let apiKeyStorageKey = "GeminiAPIKey"
    
    private init() {}
    
    public var storedApiKey: String {
        get {
            UserDefaults.standard.string(forKey: apiKeyStorageKey) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue.trimmingCharacters(in: .whitespacesAndNewlines), forKey: apiKeyStorageKey)
        }
    }
    
    // MARK: - DTO for JSON Decoding
    public struct AISyncedQuestionDTO: Codable {
        public let title: String
        public let category: String
        public let question: String
        public let keyTakeaways: String
        public let companyTag: String
        public let difficulty: String
    }
    
    public enum SyncError: LocalizedError {
        case missingApiKey
        case invalidURL
        case networkError(String)
        case decodingError(String)
        case emptyResponse
        
        public var errorDescription: String? {
            switch self {
            case .missingApiKey:
                return "Gemini API Key is missing. Please provide your API key to sync questions."
            case .invalidURL:
                return "Invalid Gemini API endpoint URL."
            case .networkError(let msg):
                return "Network request failed: \(msg)"
            case .decodingError(let msg):
                return "Failed to parse AI response: \(msg)"
            case .emptyResponse:
                return "Gemini API returned an empty response."
            }
        }
    }
    
    /// Syncs real-world interview questions for the selected technical categories using Gemini API
    public func fetchLatestInterviewQuestions(
        categories: [String],
        apiKey: String
    ) async throws -> [AISyncedQuestionDTO] {
        let cleanKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanKey.isEmpty else {
            throw SyncError.missingApiKey
        }
        
        // Save the key for future convenience
        self.storedApiKey = cleanKey
        
        let categoriesList = categories.joined(separator: ", ")
        let prompt = """
        You are a Principal Engineering Technical Interviewer. Generate 5 to 8 real-world, high-yield technical interview questions and scenario challenges recently asked at top tech companies (FAANG, tier-1 tech startups) for these specific engineering tracks: [\(categoriesList)].
        
        For each question:
        - Provide a concise concept title (e.g. "Swift 6 Actor Isolation & Sendable", "Kafka Partition Rebalancing & Consumer Lag", "LRU Cache O(1) Design").
        - The exact question or real-world scenario asked in technical rounds.
        - Key takeaways, tradeoffs, time/space complexity, or bullet points needed for an optimal answer.
        - The company that recently asks this (e.g. "Apple / Meta", "Uber / Netflix", "Databricks / Stripe").
        - Difficulty: "Easy", "Medium", or "Hard".
        - The category matching one of: [\(categoriesList)].
        
        Respond with a JSON array strictly adhering to this schema:
        [
          {
            "title": "String",
            "category": "String",
            "question": "String",
            "keyTakeaways": "String",
            "companyTag": "String",
            "difficulty": "Easy" | "Medium" | "Hard"
          }
        ]
        """
        
        // Gemini 2.5 Flash / 1.5 Flash endpoint
        guard let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=\(cleanKey)") else {
            throw SyncError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "responseMimeType": "application/json",
                "temperature": 0.3
            ]
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw SyncError.networkError("Could not serialize request: \(error.localizedDescription)")
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let errorString = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
            throw SyncError.networkError("API Error (\(httpResponse.statusCode)): \(errorString)")
        }
        
        // Decode Gemini API Response Envelope
        struct GeminiEnvelope: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable {
                        let text: String?
                    }
                    let parts: [Part]?
                }
                let content: Content?
            }
            let candidates: [Candidate]?
        }
        
        let envelope = try JSONDecoder().decode(GeminiEnvelope.self, from: data)
        guard let text = envelope.candidates?.first?.content?.parts?.first?.text, !text.isEmpty else {
            throw SyncError.emptyResponse
        }
        
        // Parse the inner JSON array of questions
        guard let jsonData = text.data(using: .utf8) else {
            throw SyncError.decodingError("Could not convert response text to UTF8 data.")
        }
        
        do {
            let questions = try JSONDecoder().decode([AISyncedQuestionDTO].self, from: jsonData)
            return questions
        } catch {
            throw SyncError.decodingError("Failed to decode question array: \(error.localizedDescription). Raw text: \(text)")
        }
    }
}
