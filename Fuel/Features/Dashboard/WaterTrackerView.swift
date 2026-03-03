import SwiftUI
import FuelKit

struct WaterTrackerView: View {
    let glasses: Int
    let target: Int
    var onAdd: (() -> Void)? = nil
    var onRemove: (() -> Void)? = nil

    var body: some View {
        FuelCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    FuelSectionHeader(title: "Water", icon: "drop.fill")

                    Spacer()

                    Text("\(glasses)/\(target)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.waterBlue)
                        .contentTransition(.numericText())
                }

                // Glass grid
                HStack(spacing: 6) {
                    ForEach(0..<target, id: \.self) { index in
                        WaterGlass(filled: index < glasses)
                            .onTapGesture {
                                if index < glasses {
                                    onRemove?()
                                } else {
                                    onAdd?()
                                }
                            }
                    }

                    // Extra add button if all glasses are filled
                    if glasses >= target {
                        Button {
                            onAdd?()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.waterBlue)
                        }
                    }
                }

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.waterBlue.opacity(0.15))

                        Capsule()
                            .fill(Color.waterBlue)
                            .frame(width: geo.size.width * min(Double(glasses) / Double(max(target, 1)), 1.0))
                            .animation(.easeOut(duration: 0.3), value: glasses)
                    }
                }
                .frame(height: 6)
            }
        }
    }
}

private struct WaterGlass: View {
    let filled: Bool

    var body: some View {
        Image(systemName: filled ? "drop.fill" : "drop")
            .font(.title3)
            .foregroundStyle(filled ? Color.waterBlue : Color.gray.opacity(0.3))
            .scaleEffect(filled ? 1.0 : 0.85)
            .animation(.spring(response: 0.3), value: filled)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: filled)
    }
}

#Preview {
    VStack {
        WaterTrackerView(glasses: 4, target: 8)
        WaterTrackerView(glasses: 8, target: 8)
    }
    .padding()
}
