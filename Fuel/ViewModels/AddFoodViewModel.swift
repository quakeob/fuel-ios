import SwiftUI
import SwiftData
import FuelKit

@Observable
final class AddFoodViewModel {
    var selectedTab: AddFoodTab = .ai
    var inputText = ""
    var selectedMeal: MealCategory = .snacks
    var isLoading = false
    var parsedFoods: [ParsedFood] = []
    var error: String?
    var showConfirmation = false

    // Manual entry fields
    var manualName = ""
    var manualCalories = ""
    var manualProtein = ""
    var manualCarbs = ""
    var manualFat = ""
    var manualFiber = ""
    var manualServing = "1 serving"

    // Recent/template foods
    var recentTemplates: [FoodTemplate] = []

    // Scanner
    var scannedBarcode: String?
    var scannedProduct: ParsedFood?

    private let parsingService = FoodParsingService()

    enum AddFoodTab: String, CaseIterable, Identifiable {
        case ai = "AI Parse"
        case manual = "Manual"
        case recent = "Recent"
        case scan = "Scan"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .ai: return "sparkles"
            case .manual: return "square.and.pencil"
            case .recent: return "clock"
            case .scan: return "barcode.viewfinder"
            }
        }
    }

    func detectMealFromTime() {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<11: selectedMeal = .breakfast
        case 11..<15: selectedMeal = .lunch
        case 15..<17: selectedMeal = .snacks
        default: selectedMeal = .dinner
        }
    }

    func loadRecents(context: ModelContext) {
        var descriptor = FetchDescriptor<FoodTemplate>(
            sortBy: [
                SortDescriptor(\.usageCount, order: .reverse),
                SortDescriptor(\.lastUsed, order: .reverse)
            ]
        )
        descriptor.fetchLimit = AppConfiguration.Limits.maxRecentTemplates
        recentTemplates = (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - AI Parsing

    @MainActor
    func parseFood() async {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        isLoading = true
        error = nil

        // Load API key from Keychain
        if let key = KeychainHelper.load(key: AppConfiguration.Security.anthropicAPIKeyKeychainKey) {
            await parsingService.setAPIKey(key)
        } else {
            AppLogger.warning("No API key found in Keychain", category: AppLogger.network)
        }

        do {
            let results = try await parsingService.parse(text)
            parsedFoods = results
            showConfirmation = !results.isEmpty
            AppLogger.info("Successfully parsed \(results.count) food items", category: AppLogger.network)
        } catch {
            self.error = error.localizedDescription
            AppLogger.error("Food parsing failed", error: error, category: AppLogger.network)
        }

        isLoading = false
    }

    // MARK: - Logging

    @MainActor
    func logParsedFoods(context: ModelContext, appState: AppState) {
        let log = appState.ensureTodayLog(context: context)

        for food in parsedFoods {
            let entry = food.toFoodEntry(meal: selectedMeal, originalInput: inputText)
            context.insert(entry)
            entry.dailyLog = log

            // Save as template for future
            saveTemplate(from: entry, context: context)
        }
        
        do {
            try context.save()
            AppLogger.info("Logged \(parsedFoods.count) parsed food entries", category: AppLogger.data)
        } catch {
            AppLogger.error("Failed to save parsed foods", error: error, category: AppLogger.data)
            self.error = "Failed to save food entries. Please try again."
        }

        resetState()
    }

    @MainActor
    func logManualEntry(context: ModelContext, appState: AppState) {
        let log = appState.ensureTodayLog(context: context)

        let entry = FoodEntry(
            name: manualName.isEmpty ? "Quick Add" : manualName,
            calories: Int(manualCalories) ?? 0,
            protein: Double(manualProtein) ?? 0,
            carbs: Double(manualCarbs) ?? 0,
            fat: Double(manualFat) ?? 0,
            fiber: Double(manualFiber) ?? 0,
            servingDescription: manualServing,
            source: .manual,
            mealCategory: selectedMeal
        )

        context.insert(entry)
        entry.dailyLog = log

        if !manualName.isEmpty {
            saveTemplate(from: entry, context: context)
        }
        
        do {
            try context.save()
            AppLogger.info("Logged manual food entry: \(entry.name)", category: AppLogger.data)
        } catch {
            AppLogger.error("Failed to save manual entry", error: error, category: AppLogger.data)
            self.error = "Failed to save food entry. Please try again."
        }

        resetState()
    }

    @MainActor
    func logTemplate(_ template: FoodTemplate, context: ModelContext, appState: AppState) {
        let log = appState.ensureTodayLog(context: context)
        let entry = template.toFoodEntry(meal: selectedMeal)
        context.insert(entry)
        entry.dailyLog = log
        template.recordUsage()
        
        do {
            try context.save()
            AppLogger.info("Logged template food: \(template.name)", category: AppLogger.data)
        } catch {
            AppLogger.error("Error logging template", error: error, category: AppLogger.data)
            self.error = "Failed to save food entry. Please try again."
        }
    }

    @MainActor
    func logScannedProduct(context: ModelContext, appState: AppState) {
        guard let product = scannedProduct else { return }
        let log = appState.ensureTodayLog(context: context)
        let entry = product.toFoodEntry(meal: selectedMeal, originalInput: scannedBarcode)
        context.insert(entry)
        entry.dailyLog = log
        saveTemplate(from: entry, context: context)
        
        do {
            try context.save()
            AppLogger.info("Logged scanned product: \(product.name)", category: AppLogger.data)
        } catch {
            AppLogger.error("Failed to save scanned product", error: error, category: AppLogger.data)
            self.error = "Failed to save food entry. Please try again."
        }
        
        resetState()
    }

    // MARK: - Barcode

    @MainActor
    func lookupBarcode(_ code: String) async {
        scannedBarcode = code
        isLoading = true
        error = nil

        do {
            let product = try await BarcodeService.shared.lookup(barcode: code)
            scannedProduct = product.toParsedFood()
            AppLogger.info("Successfully looked up barcode: \(code)", category: AppLogger.network)
        } catch {
            self.error = error.localizedDescription
            AppLogger.error("Barcode lookup failed for: \(code)", error: error, category: AppLogger.network)
        }

        isLoading = false
    }

    // MARK: - Helpers

    private func saveTemplate(from entry: FoodEntry, context: ModelContext) {
        let name = entry.name
        var descriptor = FetchDescriptor<FoodTemplate>(
            predicate: #Predicate { $0.name == name }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            existing.recordUsage()
        } else {
            let template = FoodTemplate.from(entry)
            template.recordUsage()
            context.insert(template)
        }
    }

    private func resetState() {
        inputText = ""
        parsedFoods = []
        error = nil
        showConfirmation = false
        manualName = ""
        manualCalories = ""
        manualProtein = ""
        manualCarbs = ""
        manualFat = ""
        manualFiber = ""
        scannedBarcode = nil
        scannedProduct = nil
    }
}

// MARK: - Keychain Helper

enum KeychainHelper {
    private static let accessGroup = AppConfiguration.Security.keychainAccessGroup
    
    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        
        // Use access group for sharing between app and extensions
        #if !targetEnvironment(simulator)
        query[kSecAttrAccessGroup as String] = accessGroup
        #endif
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            AppLogger.info("Keychain: Successfully saved key '\(key)'", category: AppLogger.security)
        } else {
            AppLogger.error("Keychain: Failed to save key '\(key)' with status: \(status)", category: AppLogger.security)
        }
    }

    static func load(key: String) -> String? {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        #if !targetEnvironment(simulator)
        query[kSecAttrAccessGroup as String] = accessGroup
        #endif
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else {
            if status != errSecItemNotFound {
                AppLogger.error("Keychain: Failed to load key '\(key)' with status: \(status)", category: AppLogger.security)
            }
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }

    static func delete(key: String) {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        #if !targetEnvironment(simulator)
        query[kSecAttrAccessGroup as String] = accessGroup
        #endif
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            AppLogger.info("Keychain: Successfully deleted key '\(key)'", category: AppLogger.security)
        } else if status != errSecItemNotFound {
            AppLogger.error("Keychain: Failed to delete key '\(key)' with status: \(status)", category: AppLogger.security)
        }
    }
}
