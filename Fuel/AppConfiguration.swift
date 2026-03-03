import Foundation

/// Centralized configuration for the Fuel app
/// Adjust these values for different environments and feature toggles
enum AppConfiguration {
    
    // MARK: - App Information
    
    static let appName = "Fuel"
    static let appGroupIdentifier = "group.com.jakedavis.fuel"
    static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.jakedavis.fuel"
    
    // MARK: - API Configuration
    
    enum API {
        /// Network request timeout in seconds
        static let timeout: TimeInterval = 30
        
        /// Maximum number of retry attempts for failed requests
        static let maxRetries = 3
        
        /// Delay between retry attempts in seconds
        static let retryDelay: TimeInterval = 2
        
        /// Cache duration for API responses in seconds (1 hour)
        static let cacheDuration: TimeInterval = 3600
        
        /// Anthropic API model to use
        static let anthropicModel = "claude-haiku-4-5-20251001"
        
        /// Maximum tokens for AI responses
        static let maxTokens = 1024
        
        /// Temperature for AI responses (lower = more deterministic)
        static let temperature = 0.1
    }
    
    // MARK: - Feature Flags
    
    enum Features {
        /// Enable CloudKit sync (requires iCloud entitlement)
        static let cloudKitEnabled = false
        
        /// Enable offline mode with local database
        static let offlineModeEnabled = true
        
        /// Enable analytics (requires analytics SDK)
        static let analyticsEnabled = false
        
        /// Enable crash reporting (requires crash reporting SDK)
        static let crashReportingEnabled = false
        
        /// Enable barcode scanning
        static let barcodeScanningEnabled = true
        
        /// Enable HealthKit integration
        static let healthKitEnabled = true
        
        /// Enable AI food parsing
        static let aiParsingEnabled = true
        
        /// Show debug information in UI
        static var debugModeEnabled: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
    
    // MARK: - Data Limits
    
    enum Limits {
        /// Maximum food entries per day
        static let maxFoodEntriesPerDay = 100
        
        /// Maximum photo size in bytes (5MB)
        static let maxPhotoSize: Int = 5_000_000
        
        /// Maximum number of recent templates to show
        static let maxRecentTemplates = 20
        
        /// Maximum cache size for food database (200 items)
        static let maxCacheSize = 200
        
        /// Maximum length for food name
        static let maxFoodNameLength = 100
        
        /// Maximum length for notes/descriptions
        static let maxNotesLength = 500
    }
    
    // MARK: - UI Configuration
    
    enum UI {
        /// Default animation duration
        static let animationDuration: TimeInterval = 0.3
        
        /// Debounce delay for search in seconds
        static let searchDebounceDelay: TimeInterval = 0.5
        
        /// Default corner radius for cards
        static let cornerRadius: CGFloat = 12
        
        /// Default spacing between elements
        static let defaultSpacing: CGFloat = 16
    }
    
    // MARK: - Notifications
    
    enum Notifications {
        /// Enable daily reminder notifications
        static let dailyRemindersEnabled = true
        
        /// Default reminder time (8:00 PM)
        static let defaultReminderHour = 20
        static let defaultReminderMinute = 0
    }
    
    // MARK: - Storage
    
    enum Storage {
        /// SwiftData store filename
        static let storeFilename = "Fuel.store"
        
        /// Offline food database filename
        static let offlineDatabaseFilename = "usda_foods.sqlite"
    }
    
    // MARK: - Security
    
    enum Security {
        /// Keychain key for Anthropic API key
        static let anthropicAPIKeyKeychainKey = "anthropic_api_key"
        
        /// Keychain access group for sharing with extensions
        static let keychainAccessGroup = "group.com.jakedavis.fuel"
    }
    
    // MARK: - External URLs
    
    enum URLs {
        /// Privacy policy URL (REQUIRED for App Store)
        static let privacyPolicy = URL(string: "https://fuel.app/privacy")!
        
        /// Terms of service URL
        static let termsOfService = URL(string: "https://fuel.app/terms")!
        
        /// Support/help URL
        static let support = URL(string: "https://fuel.app/support")!
        
        /// App Store URL for ratings
        static var appStore: URL {
            URL(string: "https://apps.apple.com/app/id YOUR_APP_ID")!
        }
    }
    
    // MARK: - Environment Detection
    
    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    
    static var isProduction: Bool {
        !isDebug && !isTestFlight
    }
    
    // MARK: - Version Information
    
    static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    static var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
}
