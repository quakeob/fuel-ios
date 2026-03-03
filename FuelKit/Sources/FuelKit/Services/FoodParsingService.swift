import Foundation
import SwiftData

// MARK: - Parsed Food Result

public struct ParsedFood: Codable, Identifiable, Hashable {
    public var id = UUID()
    public var name: String
    public var calories: Int
    public var protein: Double
    public var carbs: Double
    public var fat: Double
    public var fiber: Double
    public var servingSize: String
    public var servingGrams: Double
    public var quantity: Int
    public var confidence: Double

    enum CodingKeys: String, CodingKey {
        case name, calories, protein, carbs, fat, fiber
        case servingSize = "serving_size"
        case servingGrams = "serving_grams"
        case quantity, confidence
    }

    public init(
        name: String = "",
        calories: Int = 0,
        protein: Double = 0,
        carbs: Double = 0,
        fat: Double = 0,
        fiber: Double = 0,
        servingSize: String = "1 serving",
        servingGrams: Double = 100,
        quantity: Int = 1,
        confidence: Double = 0.8
    ) {
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.servingSize = servingSize
        self.servingGrams = servingGrams
        self.quantity = quantity
        self.confidence = confidence
    }

    public func toFoodEntry(meal: MealCategory, originalInput: String?) -> FoodEntry {
        FoodEntry(
            name: name,
            emoji: EmojiMapper.emoji(for: name),
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            servingDescription: servingSize,
            servingGrams: servingGrams,
            quantity: Double(quantity),
            source: .ai,
            mealCategory: meal,
            originalInput: originalInput,
            confidence: confidence
        )
    }
}

private struct ParseResponse: Codable {
    let foods: [ParsedFood]
}

// MARK: - Emoji Mapper

public enum EmojiMapper {
    private static let mapping: [(keywords: [String], emoji: String)] = [
        (["chicken"], "🍗"), (["beef", "steak", "burger"], "🥩"),
        (["fish", "salmon", "tuna", "cod", "tilapia"], "🐟"), (["shrimp"], "🍤"),
        (["egg"], "🥚"), (["bacon"], "🥓"), (["hot dog"], "🌭"),
        (["pizza"], "🍕"), (["taco"], "🌮"), (["burrito"], "🌯"),
        (["sandwich"], "🥪"), (["salad"], "🥗"), (["soup"], "🍲"),
        (["pasta", "spaghetti", "noodle"], "🍝"), (["rice"], "🍚"),
        (["bread", "toast"], "🍞"), (["bagel"], "🥯"), (["pancake", "waffle"], "🧇"),
        (["apple"], "🍎"), (["banana"], "🍌"), (["orange"], "🍊"),
        (["strawberry", "berry"], "🍓"), (["grape"], "🍇"), (["watermelon"], "🍉"),
        (["mango"], "🥭"), (["peach"], "🍑"), (["avocado"], "🥑"),
        (["broccoli"], "🥦"), (["carrot"], "🥕"), (["corn"], "🌽"),
        (["potato", "fries"], "🥔"), (["tomato"], "🍅"),
        (["cheese"], "🧀"), (["milk", "yogurt"], "🥛"), (["ice cream"], "🍦"),
        (["cookie"], "🍪"), (["chocolate"], "🍫"), (["cake"], "🎂"),
        (["donut"], "🍩"), (["candy"], "🍬"),
        (["coffee"], "☕"), (["tea"], "🍵"), (["beer"], "🍺"),
        (["wine"], "🍷"), (["juice"], "🧃"), (["soda", "cola"], "🥤"),
        (["water"], "💧"), (["protein", "shake", "supplement"], "🥤"),
        (["peanut butter", "almond", "nut"], "🥜"), (["popcorn"], "🍿"),
        (["chips"], "🥔"),
    ]

    public static func emoji(for foodName: String) -> String {
        let lower = foodName.lowercased()
        for (keywords, emoji) in mapping {
            for keyword in keywords {
                if lower.contains(keyword) {
                    return emoji
                }
            }
        }
        return "🍽️"
    }
}

// MARK: - Food Parsing Service

public actor FoodParsingService {
    private let cache = NSCache<NSString, CacheEntry>()
    private var apiKey: String?

    public init() {
        cache.countLimit = AppConfiguration.Limits.maxCacheSize
    }

    public func setAPIKey(_ key: String) {
        self.apiKey = key
    }

    // MARK: - Main Parse Method

    public func parse(_ input: String) async throws -> [ParsedFood] {
        let normalized = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return [] }

        // 1. Check in-memory cache
        if let cached = cache.object(forKey: normalized as NSString) {
            return cached.foods
        }

        // 2. Try offline database
        let offlineResults = OfflineFoodDB.shared.search(normalized)
        if !offlineResults.isEmpty && isFullMatch(input: normalized, results: offlineResults) {
            cacheResult(normalized, foods: offlineResults)
            return offlineResults
        }

        // 3. Call AI API
        guard let apiKey, !apiKey.isEmpty else {
            // No API key — return offline results or empty
            if !offlineResults.isEmpty {
                return offlineResults
            }
            return [ParsedFood(name: input, servingSize: "1 serving")]
        }

        let aiResults = try await callClaudeAPI(input: input, apiKey: apiKey)
        cacheResult(normalized, foods: aiResults)
        return aiResults
    }

    // MARK: - Claude API Call

    private func callClaudeAPI(input: String, apiKey: String) async throws -> [ParsedFood] {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.addValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        request.addValue("application/json", forHTTPHeaderField: "content-type")
        request.timeoutInterval = AppConfiguration.API.timeout

        let systemPrompt = """
        You are a nutrition assistant. Given a food description, return a JSON object with a "foods" array. \
        Each food item should have: name (string), calories (int), protein (float), carbs (float), fat (float), \
        fiber (float), serving_size (string), serving_grams (float), quantity (int), confidence (float 0-1). \
        Estimate standard serving sizes. Be accurate with nutrition data. Only return valid JSON, no other text.
        """

        let body: [String: Any] = [
            "model": AppConfiguration.API.anthropicModel,
            "max_tokens": AppConfiguration.API.maxTokens,
            "temperature": AppConfiguration.API.temperature,
            "system": systemPrompt,
            "messages": [
                ["role": "user", "content": "Parse this food: \(input)"]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw FoodParsingError.apiError
        }
        
        // Handle different HTTP status codes
        switch httpResponse.statusCode {
        case 200:
            break
        case 401:
            AppLogger.error("API authentication failed (401)", category: AppLogger.network)
            throw FoodParsingError.noAPIKey
        case 429:
            AppLogger.warning("API rate limit exceeded (429)", category: AppLogger.network)
            throw FoodParsingError.rateLimited
        case 500...599:
            AppLogger.error("API server error (\(httpResponse.statusCode))", category: AppLogger.network)
            throw FoodParsingError.serverError
        default:
            AppLogger.error("API request failed with status \(httpResponse.statusCode)", category: AppLogger.network)
            throw FoodParsingError.apiError
        }

        // Extract text content from Claude response
        let claudeResponse = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        guard let text = claudeResponse.content.first?.text else {
            throw FoodParsingError.parseError
        }

        // Parse the JSON from Claude's response
        guard let jsonData = text.data(using: .utf8) else {
            throw FoodParsingError.parseError
        }

        let parsed = try JSONDecoder().decode(ParseResponse.self, from: jsonData)
        return parsed.foods
    }

    // MARK: - Helpers

    private func isFullMatch(input: String, results: [ParsedFood]) -> Bool {
        // Simple heuristic: if we found results and input is a simple food name
        !results.isEmpty && !input.contains(" and ") && !input.contains(",")
    }

    private func cacheResult(_ key: String, foods: [ParsedFood]) {
        cache.setObject(CacheEntry(foods: foods), forKey: key as NSString)
    }
}

// MARK: - Cache Entry

private final class CacheEntry: NSObject {
    let foods: [ParsedFood]
    init(foods: [ParsedFood]) { self.foods = foods }
}

// MARK: - Claude Response Types

private struct ClaudeResponse: Codable {
    let content: [ContentBlock]
}

private struct ContentBlock: Codable {
    let text: String?
    let type: String
}

// MARK: - Errors

public enum FoodParsingError: LocalizedError {
    case apiError
    case parseError
    case noAPIKey
    case offline
    case rateLimited
    case serverError

    public var errorDescription: String? {
        switch self {
        case .apiError: return "Failed to reach nutrition API"
        case .parseError: return "Could not parse food data"
        case .noAPIKey: return "API key not configured. Please add your key in Settings."
        case .offline: return "No internet connection"
        case .rateLimited: return "Too many requests. Please try again in a moment."
        case .serverError: return "Server error. Please try again later."
        }
    }
}

// MARK: - Offline Food Database

public final class OfflineFoodDB {
    public static let shared = OfflineFoodDB()
    private var foods: [OfflineFood] = []

    private struct OfflineFood {
        let name: String
        let calories: Int
        let protein: Double
        let carbs: Double
        let fat: Double
        let fiber: Double
        let servingDescription: String
        let servingGrams: Double
    }

    private init() {
        loadDatabase()
    }

    private func loadDatabase() {
        guard let dbURL = Bundle.module.url(forResource: "usda_foods", withExtension: "sqlite") else {
            return
        }

        var db: OpaquePointer?
        guard sqlite3_open_v2(dbURL.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK else {
            return
        }
        defer { sqlite3_close(db) }

        var stmt: OpaquePointer?
        let query = "SELECT name, calories, protein, carbs, fat, fiber, serving_description, serving_grams FROM foods"
        guard sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK else { return }
        defer { sqlite3_finalize(stmt) }

        while sqlite3_step(stmt) == SQLITE_ROW {
            let name = String(cString: sqlite3_column_text(stmt, 0))
            let calories = Int(sqlite3_column_int(stmt, 1))
            let protein = sqlite3_column_double(stmt, 2)
            let carbs = sqlite3_column_double(stmt, 3)
            let fat = sqlite3_column_double(stmt, 4)
            let fiber = sqlite3_column_double(stmt, 5)
            let serving = String(cString: sqlite3_column_text(stmt, 6))
            let grams = sqlite3_column_double(stmt, 7)

            foods.append(OfflineFood(
                name: name,
                calories: calories,
                protein: protein,
                carbs: carbs,
                fat: fat,
                fiber: fiber,
                servingDescription: serving,
                servingGrams: grams
            ))
        }
    }

    public func search(_ query: String) -> [ParsedFood] {
        let tokens = query.lowercased().split(separator: " ").map(String.init)
        guard !tokens.isEmpty else { return [] }

        return foods
            .filter { food in
                let name = food.name.lowercased()
                return tokens.allSatisfy { name.contains($0) }
            }
            .prefix(5)
            .map { food in
                ParsedFood(
                    name: food.name,
                    calories: food.calories,
                    protein: food.protein,
                    carbs: food.carbs,
                    fat: food.fat,
                    fiber: food.fiber,
                    servingSize: food.servingDescription,
                    servingGrams: food.servingGrams,
                    quantity: 1,
                    confidence: 0.9
                )
            }
    }
}

// SQLite3 imports for offline DB
import SQLite3
