import Foundation
import OSLog

/// Centralized logging system for the Fuel app
/// Use these loggers instead of print() statements for production-ready logging
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.jakedavis.fuel"
    
    /// General app lifecycle and state changes
    static let app = Logger(subsystem: subsystem, category: "app")
    
    /// Data persistence and SwiftData operations
    static let data = Logger(subsystem: subsystem, category: "data")
    
    /// Network requests and API calls
    static let network = Logger(subsystem: subsystem, category: "network")
    
    /// User interface and interaction events
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    /// Security-related operations (Keychain, etc.)
    static let security = Logger(subsystem: subsystem, category: "security")
}

// MARK: - Convenience Methods

extension AppLogger {
    /// Log a non-critical event (use sparingly in production)
    static func debug(_ message: String, category: Logger) {
        #if DEBUG
        category.debug("\(message, privacy: .public)")
        #endif
    }
    
    /// Log informational messages
    static func info(_ message: String, category: Logger) {
        category.info("\(message, privacy: .public)")
    }
    
    /// Log warning messages that don't prevent operation
    static func warning(_ message: String, category: Logger) {
        category.warning("\(message, privacy: .public)")
    }
    
    /// Log error messages
    static func error(_ message: String, error: Error? = nil, category: Logger) {
        if let error = error {
            category.error("\(message, privacy: .public): \(error.localizedDescription, privacy: .public)")
        } else {
            category.error("\(message, privacy: .public)")
        }
    }
    
    /// Log critical errors that may cause data loss or crashes
    static func critical(_ message: String, error: Error? = nil, category: Logger) {
        if let error = error {
            category.critical("\(message, privacy: .public): \(error.localizedDescription, privacy: .public)")
        } else {
            category.critical("\(message, privacy: .public)")
        }
    }
}

// MARK: - Usage Examples
/*
 
 // Debug logging (only in debug builds)
 AppLogger.debug("User tapped add food button", category: AppLogger.ui)
 
 // Info logging
 AppLogger.info("App launched successfully", category: AppLogger.app)
 
 // Warning logging
 AppLogger.warning("API response took longer than expected", category: AppLogger.network)
 
 // Error logging
 AppLogger.error("Failed to save food entry", error: error, category: AppLogger.data)
 
 // Critical logging
 AppLogger.critical("Model container initialization failed", error: error, category: AppLogger.data)
 
 */
