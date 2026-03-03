import SwiftUI
import SwiftData
import FuelKit

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @State private var goals: UserGoals?
    @State private var apiKey = ""
    @State private var healthEnabled = false
    @State private var showAPIKeyField = false
    @State private var showDemoAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // Goals Section
                Section("Daily Goals") {
                    if let goals {
                        GoalRow(label: "Calories", value: Binding(
                            get: { goals.dailyCalories },
                            set: { goals.dailyCalories = $0; goals.updatedAt = Date() }
                        ), unit: "cal", range: 500...6000, step: 50)

                        GoalRow(label: "Protein", value: Binding(
                            get: { Int(goals.proteinGrams) },
                            set: { goals.proteinGrams = Double($0); goals.updatedAt = Date() }
                        ), unit: "g", range: 20...500, step: 5)

                        GoalRow(label: "Carbs", value: Binding(
                            get: { Int(goals.carbsGrams) },
                            set: { goals.carbsGrams = Double($0); goals.updatedAt = Date() }
                        ), unit: "g", range: 20...500, step: 5)

                        GoalRow(label: "Fat", value: Binding(
                            get: { Int(goals.fatGrams) },
                            set: { goals.fatGrams = Double($0); goals.updatedAt = Date() }
                        ), unit: "g", range: 10...300, step: 5)

                        GoalRow(label: "Water", value: Binding(
                            get: { goals.waterGlasses },
                            set: { goals.waterGlasses = $0; goals.updatedAt = Date() }
                        ), unit: "glasses", range: 1...20, step: 1)
                    }
                }

                // Weight Unit
                if let goals {
                    Section("Weight") {
                        Picker("Unit", selection: Binding(
                            get: { goals.weightUnit },
                            set: { goals.weightUnit = $0 }
                        )) {
                            ForEach(WeightUnit.allCases, id: \.self) { unit in
                                Text(unit.label).tag(unit)
                            }
                        }

                        if let target = goals.targetWeight {
                            HStack {
                                Text("Target Weight")
                                Spacer()
                                Text(String(format: "%.1f %@", target, goals.weightUnit.label))
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // AI API Key
                Section("AI Food Parsing") {
                    Toggle("Show API Key", isOn: $showAPIKeyField)

                    if showAPIKeyField {
                        SecureField("Anthropic API Key", text: $apiKey)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Button("Save API Key") {
                            if !apiKey.isEmpty {
                                KeychainHelper.save(key: "anthropic_api_key", value: apiKey)
                            }
                        }
                        .disabled(apiKey.isEmpty)
                    }

                    Text("Used for AI-powered food parsing. Your key is stored securely in the Keychain.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Health
                Section("Apple Health") {
                    Toggle("Sync to Health", isOn: $healthEnabled)
                        .onChange(of: healthEnabled) { _, enabled in
                            if enabled {
                                Task {
                                    try? await HealthKitService.shared.requestAuthorization()
                                }
                            }
                        }

                    Text("Write calories, macros, and weight to Apple Health.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // iCloud
                Section("iCloud Sync") {
                    @Bindable var state = appState
                    Toggle("iCloud Sync", isOn: $state.cloudKitEnabled)

                    Text("Sync your data across all your Apple devices.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }

                // Demo
                #if DEBUG
                Section("Developer") {
                    Button("Load Demo Data") {
                        loadDemoData()
                    }
                    .foregroundStyle(.fuelOrange)

                    Button("Clear All Data", role: .destructive) {
                        clearAllData()
                    }
                }
                #endif
            }
            .navigationTitle("Settings")
            .alert("Demo Data Loaded", isPresented: $showDemoAlert) {
                Button("OK") {}
            } message: {
                Text("A full day of meals, water, and weight data has been added.")
            }
            .onAppear {
                goals = appState.currentGoals(context: context)
                if let saved = KeychainHelper.load(key: "anthropic_api_key") {
                    apiKey = saved
                }
            }
        }
    }

    #if DEBUG
    private func loadDemoData() {
        // Clear existing data first
        clearAllData()

        // Set up goals
        let goals = appState.currentGoals(context: context)
        goals.dailyCalories = 2400
        goals.proteinGrams = 180
        goals.carbsGrams = 240
        goals.fatGrams = 75
        goals.waterGlasses = 10
        goals.targetWeight = 175
        self.goals = goals

        // Meal templates — variety across the week
        let breakfasts: [(String, String, Int, Double, Double, Double)] = [
            ("Scrambled Eggs & Toast", "🥚", 360, 21, 28, 17.5),
            ("Overnight Oats", "🫙", 380, 14, 52, 12),
            ("Protein Pancakes", "🥞", 420, 32, 48, 10),
            ("Avocado Toast", "🥑", 340, 12, 30, 22),
            ("Smoothie Bowl", "🫐", 310, 18, 42, 8),
            ("Eggs Benedict", "🍳", 480, 24, 26, 28),
            ("Greek Yogurt Parfait", "🥛", 290, 22, 38, 6),
        ]

        let lunches: [(String, String, Int, Double, Double, Double)] = [
            ("Chicken & Rice Bowl", "🍗", 555, 50.7, 56, 8.4),
            ("Turkey Club Sandwich", "🥪", 520, 38, 42, 22),
            ("Burrito Bowl", "🌯", 580, 35, 62, 18),
            ("Salmon Poke Bowl", "🐟", 490, 36, 48, 16),
            ("Chicken Caesar Salad", "🥗", 440, 42, 18, 24),
            ("Steak Tacos", "🌮", 510, 38, 36, 22),
            ("Grilled Chicken Wrap", "🫔", 460, 40, 38, 14),
        ]

        let dinners: [(String, String, Int, Double, Double, Double)] = [
            ("Salmon & Sweet Potato", "🐟", 625, 44, 49, 27.3),
            ("Steak & Asparagus", "🥩", 580, 52, 12, 36),
            ("Chicken Stir Fry", "🍜", 520, 44, 48, 14),
            ("Shrimp Pasta", "🍝", 560, 34, 62, 18),
            ("BBQ Chicken Pizza", "🍕", 640, 38, 68, 24),
            ("Grilled Pork Chop", "🍖", 490, 46, 28, 22),
            ("Teriyaki Bowl", "🍚", 540, 38, 58, 16),
        ]

        let snackSets: [[(String, String, Int, Double, Double, Double)]] = [
            [("Almonds", "🥜", 165, 6, 6, 14), ("Protein Shake", "🥤", 160, 30, 5, 2), ("Apple", "🍎", 95, 0.5, 25, 0.3)],
            [("Trail Mix", "🥜", 210, 6, 24, 12), ("Cottage Cheese", "🧀", 120, 14, 6, 5)],
            [("Banana", "🍌", 105, 1.3, 27, 0.4), ("Protein Bar", "🍫", 230, 20, 24, 8)],
            [("Beef Jerky", "🥩", 140, 22, 6, 3), ("Mixed Berries", "🫐", 85, 1, 20, 0.5)],
            [("Hummus & Carrots", "🥕", 160, 5, 18, 8), ("String Cheese", "🧀", 80, 7, 1, 6), ("Grapes", "🍇", 62, 0.6, 16, 0.3)],
            [("Rice Cakes & PB", "🍘", 190, 7, 22, 10), ("Orange", "🍊", 62, 1.2, 15, 0.2)],
            [("Dark Chocolate", "🍫", 170, 2, 20, 10), ("Protein Shake", "🥤", 160, 30, 5, 2)],
        ]

        let waterCounts = [8, 7, 9, 6, 10, 7, 7]
        let weights: [Double] = [180.2, 179.8, 179.5, 179.9, 179.1, 178.8, 178.5]

        // Generate 7 days of data
        for dayOffset in (0..<7).reversed() {
            let date = Date.now.daysAgo(dayOffset)
            let idx = 6 - dayOffset

            let log = DailyLog(
                date: date,
                targetCalories: 2400,
                targetProtein: 180,
                targetCarbs: 240,
                targetFat: 75
            )
            context.insert(log)

            // Breakfast
            let b = breakfasts[idx]
            let breakfast = FoodEntry(name: b.0, emoji: b.1, calories: b.2, protein: b.3, carbs: b.4, fat: b.5, servingDescription: "1 serving", quantity: 1, source: .ai, mealCategory: .breakfast)
            breakfast.dailyLog = log
            context.insert(breakfast)

            // Coffee every day
            let coffee = FoodEntry(name: "Black Coffee", emoji: "☕", calories: 5, protein: 0.3, carbs: 0, fat: 0, servingDescription: "12 oz", quantity: 1, source: .ai, mealCategory: .breakfast)
            coffee.dailyLog = log
            context.insert(coffee)

            // Lunch
            let l = lunches[idx]
            let lunch = FoodEntry(name: l.0, emoji: l.1, calories: l.2, protein: l.3, carbs: l.4, fat: l.5, servingDescription: "1 serving", quantity: 1, source: .ai, mealCategory: .lunch)
            lunch.dailyLog = log
            context.insert(lunch)

            // Dinner
            let d = dinners[idx]
            let dinner = FoodEntry(name: d.0, emoji: d.1, calories: d.2, protein: d.3, carbs: d.4, fat: d.5, servingDescription: "1 serving", quantity: 1, source: .ai, mealCategory: .dinner)
            dinner.dailyLog = log
            context.insert(dinner)

            // Snacks
            for s in snackSets[idx] {
                let snack = FoodEntry(name: s.0, emoji: s.1, calories: s.2, protein: s.3, carbs: s.4, fat: s.5, servingDescription: "1 serving", quantity: 1, source: .manual, mealCategory: .snacks)
                snack.dailyLog = log
                context.insert(snack)
            }

            // Water
            log.waterGlasses = waterCounts[idx]

            // Weight (for meal days)
            let weight = WeightEntry(weight: weights[idx], unit: .lbs, date: date, source: .manual)
            context.insert(weight)
        }

        // Generate 30 days of weight history (beyond the 7 meal days)
        // Gradual decline from ~186 to ~180 over the prior 23 days
        for dayOffset in 7..<30 {
            let date = Date.now.daysAgo(dayOffset)
            let progress = Double(dayOffset - 7) / 23.0 // 0 = day 7, 1 = day 29
            let baseWeight = 180.2 + (progress * 5.8) // 180.2 → 186
            let noise = Double.random(in: -0.4...0.4)
            let w = WeightEntry(weight: baseWeight + noise, unit: .lbs, date: date, source: .manual)
            context.insert(w)
        }

        try? context.save()
        showDemoAlert = true
    }

    private func clearAllData() {
        try? context.delete(model: FoodEntry.self)
        try? context.delete(model: DailyLog.self)
        try? context.delete(model: WeightEntry.self)
        try? context.delete(model: UserGoals.self)
        try? context.save()
    }
    #endif
}

private struct GoalRow: View {
    let label: String
    @Binding var value: Int
    let unit: String
    let range: ClosedRange<Int>
    let step: Int

    var body: some View {
        HStack {
            Text(label)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    if value - step >= range.lowerBound {
                        value -= step
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Text("\(value) \(unit)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(minWidth: 80, alignment: .center)
                    .contentTransition(.numericText())

                Button {
                    if value + step <= range.upperBound {
                        value += step
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .foregroundStyle(.fuelGreen)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(try! AppState())
        .modelContainer(try! FuelModelContainer.previewContainer())
}
