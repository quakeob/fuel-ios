import Foundation

/// Centralized configuration for the Fuel app
/// Adjust these values for different environments and feature toggles
public enum AppConfiguration {
    
    // MARK: - App Information
    
    public static let appName = "Fuel"
    public static let appGroupIdentifier = "group.com.jakedavis.fuel"
    public static let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.jakedavis.fuel"
    
    // MARK: - API Configuration
    
    public enum API {
        /// Network request timeout in seconds
        public static let timeout: TimeInterval = 30
        
        /// Maximum number of retry attempts for failed requests
        public static let maxRetries = 3
        
        /// Delay between retry attempts in seconds
        public static let retryDelay: TimeInterval = 2
        
        /// Cache duration for API responses in seconds (1 hour)
        public static let cacheDuration: TimeInterval = 3600
        
        /// Anthropic API model to use
        public static let anthropicModel = "claude-haiku-4-5-20251001"
        
        /// Maximum tokens for AI responses
        public static let maxTokens = 1024
        
        /// Temperature for AI responses (lower = more deterministic)
        public static let temperature = 0.1
    }
    
    // MARK: - Feature Flags
    
    public enum Features {
        /// Enable CloudKit sync (requires iCloud entitlement)
        public static let cloudKitEnabled = false
        
        /// Enable offline mode with local database
        public static let offlineModeEnabled = true
        
        /// Enable analytics (requires analytics SDK)
        public static let analyticsEnabled = false
        
        /// Enable crash reporting (requires crash reporting SDK)
        public static let crashReportingEnabled = false
        
        /// Enable barcode scanning
        public static let barcodeScanningEnabled = true
        
        /// Enable HealthKit integration
        public static let healthKitEnabled = true
        
        /// Enable AI food parsing
        public static let aiParsingEnabled = true
        
        /// Show debug information in UI
        public static var debugModeEnabled: Bool {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }
    }
    
    // MARK: - Data Limits
    
    public enum Limits {
        /// Maximum food entries per day
        public static let maxFoodEntriesPerDay = 100
        
        /// Maximum photo size in bytes (5MB)
        public static let maxPhotoSize: Int = 5_000_000
        
        /// Maximum number of recent templates to show
        public static let maxRecentTemplates = 20
        
        /// Maximum cache size for food database (200 items)
        public static let maxCacheSize = 200
        
        /// Maximum length for food name
        public static let maxFoodNameLength = 100
        
        /// Maximum length for notes/descriptions
        public static let maxNotesLength = 500
    }
    
    // MARK: - UI Configuration
    
    public enum UI {
        /// Default animation duration
        public static let animationDuration: TimeInterval = 0.3
        
        /// Debounce delay for search in seconds
        public static let searchDebounceDelay: TimeInterval = 0.5
        
        /// Default corner radius for cards
        public static let cornerRadius: CGFloat = 12
        
        /// Default spacing between elements
        public static let defaultSpacing: CGFloat = 16
    }
    
    // MARK: - Notifications
    
    public enum Notifications {
        /// Enable daily reminder notifications
        public static let dailyRemindersEnabled = true
        
        /// Default reminder time (8:00 PM)
        public static let defaultReminderHour = 20
        public static let defaultReminderMinute = 0
    }
    
    // MARK: - Storage
    
    public enum Storage {
        /// SwiftData store filename
        public static let storeFilename = "Fuel.store"
        
        /// Offline food database filename
        public static let offlineDatabaseFilename = "usda_foods.sqlite"
    }
    
    // MARK: - Security
    
    public enum Security {
        /// Keychain key for Anthropic API key
        public static let anthropicAPIKeyKeychainKey = "anthropic_api_key"
        
        /// Keychain access group for sharing with extensions
        public static let keychainAccessGroup = "group.com.jakedavis.fuel"
    }
    
    // MARK: - External URLs
    
    public enum URLs {
        /// Privacy policy URL (REQUIRED for App Store)
        public static let privacyPolicy = URL(string: "https://fuel.app/privacy")!
        
        /// Terms of service URL
        public static let termsOfService = URL(string: "https://fuel.app/terms")!
        
        /// Support/help URL
        public static let support = URL(string: "https://fuel.app/support")!
        
        /// App Store URL for ratings
        public static var appStore: URL {
            URL(string: "https://apps.apple.com/app/id YOUR_APP_ID")!
        }
    }
    
    // MARK: - Environment Detection
    
    public static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    public static var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    
    public static var isProduction: Bool {
        !isDebug && !isTestFlight
    }
    
    // MARK: - Version Information
    
    public static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    public static var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    public static var fullVersion: String {
        "\(appVersion) (\(buildNumber))"
    }
}
