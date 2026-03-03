import SwiftUI
import FuelKit

struct WatchQuickLogView: View {
    @Environment(WatchSessionManager.self) private var session

    private let quickFoods: [(String, String, Int)] = [
        ("Coffee", "☕", 5),
        ("Protein Shake", "🥤", 200),
        ("Banana", "🍌", 105),
        ("Apple", "🍎", 95),
        ("Yogurt", "🫙", 150),
        ("Granola Bar", "🍫", 190),
        ("Handful of Nuts", "🥜", 170),
        ("Egg", "🥚", 72),
    ]

    var body: some View {
        List {
            ForEach(quickFoods, id: \.0) { food in
                Button {
                    session.quickLog(name: food.0, emoji: food.1, calories: food.2)
                } label: {
                    HStack {
                        Text(food.1)
                        VStack(alignment: .leading) {
                            Text(food.0)
                                .font(.caption)
                            Text("\(food.2) cal")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Quick Log")
    }
}
