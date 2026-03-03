import Foundation

public struct BarcodeProduct: Sendable {
    public let barcode: String
    public let name: String
    public let brand: String?
    public let calories: Int
    public let protein: Double
    public let carbs: Double
    public let fat: Double
    public let fiber: Double
    public let servingSize: String
    public let servingGrams: Double
    public let imageURL: URL?

    public func toParsedFood() -> ParsedFood {
        ParsedFood(
            name: brand != nil ? "\(brand!) \(name)" : name,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            servingSize: servingSize,
            servingGrams: servingGrams,
            quantity: 1,
            confidence: 0.95
        )
    }
}

public actor BarcodeService {
    public static let shared = BarcodeService()

    private let cache = NSCache<NSString, CacheEntry>()

    private init() {
        cache.countLimit = 100
    }

    public func lookup(barcode: String) async throws -> BarcodeProduct {
        // Check cache
        if let cached = cache.object(forKey: barcode as NSString) {
            return cached.product
        }

        // Call Open Food Facts API
        let urlString = "https://world.openfoodfacts.org/api/v2/product/\(barcode).json?fields=product_name,brands,nutriments,serving_size,serving_quantity,image_front_url"
        guard let url = URL(string: urlString) else {
            throw BarcodeError.invalidBarcode
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw BarcodeError.networkError
        }

        let offResponse = try JSONDecoder().decode(OFFResponse.self, from: data)

        guard offResponse.status == 1, let product = offResponse.product else {
            throw BarcodeError.productNotFound
        }

        let nutriments = product.nutriments
        let servingGrams = product.serving_quantity ?? 100.0

        let result = BarcodeProduct(
            barcode: barcode,
            name: product.product_name ?? "Unknown Product",
            brand: product.brands,
            calories: Int(nutriments.energyKcalServing ?? nutriments.energyKcal100g ?? 0),
            protein: nutriments.proteinsServing ?? nutriments.proteins100g ?? 0,
            carbs: nutriments.carbohydratesServing ?? nutriments.carbohydrates100g ?? 0,
            fat: nutriments.fatServing ?? nutriments.fat100g ?? 0,
            fiber: nutriments.fiberServing ?? nutriments.fiber100g ?? 0,
            servingSize: product.serving_size ?? "1 serving",
            servingGrams: servingGrams,
            imageURL: product.image_front_url.flatMap { URL(string: $0) }
        )

        cache.setObject(CacheEntry(product: result), forKey: barcode as NSString)
        return result
    }
}

// MARK: - Open Food Facts Types

private struct OFFResponse: Codable {
    let status: Int
    let product: OFFProduct?
}

private struct OFFProduct: Codable {
    let product_name: String?
    let brands: String?
    let nutriments: OFFNutriments
    let serving_size: String?
    let serving_quantity: Double?
    let image_front_url: String?
}

private struct OFFNutriments: Codable {
    let energyKcalServing: Double?
    let energyKcal100g: Double?
    let proteinsServing: Double?
    let proteins100g: Double?
    let carbohydratesServing: Double?
    let carbohydrates100g: Double?
    let fatServing: Double?
    let fat100g: Double?
    let fiberServing: Double?
    let fiber100g: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcalServing = "energy-kcal_serving"
        case energyKcal100g = "energy-kcal_100g"
        case proteinsServing = "proteins_serving"
        case proteins100g = "proteins_100g"
        case carbohydratesServing = "carbohydrates_serving"
        case carbohydrates100g = "carbohydrates_100g"
        case fatServing = "fat_serving"
        case fat100g = "fat_100g"
        case fiberServing = "fiber_serving"
        case fiber100g = "fiber_100g"
    }
}

private final class CacheEntry: NSObject {
    let product: BarcodeProduct
    init(product: BarcodeProduct) { self.product = product }
}

public enum BarcodeError: LocalizedError {
    case invalidBarcode
    case networkError
    case productNotFound

    public var errorDescription: String? {
        switch self {
        case .invalidBarcode: return "Invalid barcode"
        case .networkError: return "Could not look up barcode"
        case .productNotFound: return "Product not found in database"
        }
    }
}
