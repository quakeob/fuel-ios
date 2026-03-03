import SwiftUI
import SwiftData
import FuelKit

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var currentPage = 0
    @State private var calories = 2000
    @State private var protein = 150
    @State private var carbs = 200
    @State private var fat = 65
    @State private var waterGlasses = 8
    @State private var weightUnit: WeightUnit = .lbs
    @State private var enableHealth = false

    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Page 1: Welcome
                welcomePage
                    .tag(0)

                // Page 2: Goals
                goalsPage
                    .tag(1)

                // Page 3: Health
                healthPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)
        }
        .background(Color.surfaceGrouped)
    }

    // MARK: - Welcome Page

    private var welcomePage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "flame.fill")
                .font(.system(size: 72))
                .foregroundStyle(.fuelGreen)

            Text("Welcome to Fuel")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Track your nutrition with AI-powered food logging")
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            VStack(alignment: .leading, spacing: 16) {
                featureRow(icon: "sparkles", color: .fuelGreen, title: "AI Food Parsing", subtitle: "Describe meals in plain English")
                featureRow(icon: "barcode.viewfinder", color: .fuelBlue, title: "Barcode Scanner", subtitle: "Scan packaged foods instantly")
                featureRow(icon: "chart.bar.fill", color: .fuelPurple, title: "Detailed Analytics", subtitle: "Track trends over time")
                featureRow(icon: "applewatch", color: .fuelOrange, title: "Widgets & Watch", subtitle: "Quick access everywhere")
            }
            .padding(.horizontal, 30)

            Spacer()

            Button {
                withAnimation { currentPage = 1 }
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.fuelGreen, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Goals Page

    private var goalsPage: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Set Your Goals")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Text("You can change these anytime in Settings")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 16) {
                    goalStepper("Daily Calories", value: $calories, unit: "cal", step: 50, range: 500...6000)
                    goalStepper("Protein", value: $protein, unit: "g", step: 5, range: 20...500)
                    goalStepper("Carbs", value: $carbs, unit: "g", step: 5, range: 20...500)
                    goalStepper("Fat", value: $fat, unit: "g", step: 5, range: 10...300)
                    goalStepper("Water", value: $waterGlasses, unit: "glasses", step: 1, range: 1...20)

                    Picker("Weight Unit", selection: $weightUnit) {
                        ForEach(WeightUnit.allCases, id: \.self) { unit in
                            Text(unit.label).tag(unit)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                }
                .padding()

                Button {
                    withAnimation { currentPage = 2 }
                } label: {
                    Text("Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.fuelGreen, in: RoundedRectangle(cornerRadius: 14))
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 30)
            }
        }
    }

    // MARK: - Health Page

    private var healthPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "heart.fill")
                .font(.system(size: 48))
                .foregroundStyle(.red)

            Text("Apple Health")
                .font(.title)
                .fontWeight(.bold)

            Text("Sync your nutrition and weight data with Apple Health")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Toggle("Enable Health Sync", isOn: $enableHealth)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                finishOnboarding()
            } label: {
                Text("Start Tracking")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.fuelGreen, in: RoundedRectangle(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 30)

            Button("Skip for now") {
                enableHealth = false
                finishOnboarding()
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Helpers

    private func featureRow(icon: String, color: Color, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func goalStepper(_ label: String, value: Binding<Int>, unit: String, step: Int, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)

            Spacer()

            HStack(spacing: 12) {
                Button {
                    if value.wrappedValue - step >= range.lowerBound {
                        value.wrappedValue -= step
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                Text("\(value.wrappedValue) \(unit)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(minWidth: 80)
                    .contentTransition(.numericText())

                Button {
                    if value.wrappedValue + step <= range.upperBound {
                        value.wrappedValue += step
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.fuelGreen)
                }
            }
        }
        .padding(.horizontal)
    }

    private func finishOnboarding() {
        let goals = UserGoals(
            dailyCalories: calories,
            proteinGrams: Double(protein),
            carbsGrams: Double(carbs),
            fatGrams: Double(fat),
            waterGlasses: waterGlasses,
            weightUnit: weightUnit
        )
        context.insert(goals)

        // Create today's log
        let _ = appState.ensureTodayLog(context: context)

        if enableHealth {
            Task {
                try? await HealthKitService.shared.requestAuthorization()
            }
        }

        appState.showOnboarding = false
        dismiss()
    }
}

#Preview {
    OnboardingView()
        .environment(try! AppState())
        .modelContainer(try! FuelModelContainer.previewContainer())
}
