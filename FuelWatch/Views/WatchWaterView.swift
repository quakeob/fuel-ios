import SwiftUI
import FuelKit

struct WatchWaterView: View {
    @Environment(WatchSessionManager.self) private var session

    var body: some View {
        VStack(spacing: 16) {
            Text("\(session.waterGlasses)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.waterBlue)

            Text("of \(session.waterTarget) glasses")
                .font(.caption)
                .foregroundStyle(.secondary)

            // Water drops
            HStack(spacing: 4) {
                ForEach(0..<session.waterTarget, id: \.self) { i in
                    Image(systemName: i < session.waterGlasses ? "drop.fill" : "drop")
                        .font(.caption)
                        .foregroundStyle(i < session.waterGlasses ? Color.waterBlue : .gray.opacity(0.3))
                }
            }

            HStack(spacing: 20) {
                Button {
                    session.removeWater()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .disabled(session.waterGlasses <= 0)

                Button {
                    session.addWater()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.waterBlue)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle("Water")
    }
}
