import SwiftUI
import FuelKit

struct StreakBannerView: View {
    let streak: Int

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundStyle(.streakOrange)

            VStack(alignment: .leading, spacing: 1) {
                Text("\(streak)-day streak!")
                    .font(.subheadline)
                    .fontWeight(.bold)

                Text("Keep logging to maintain your streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.streakOrange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.streakOrange.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    VStack {
        StreakBannerView(streak: 7)
        StreakBannerView(streak: 30)
    }
    .padding()
}
