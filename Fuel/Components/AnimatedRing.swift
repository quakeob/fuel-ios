import SwiftUI
import FuelKit

struct AnimatedRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let gradient: [Color]
    let size: CGFloat

    @State private var animatedProgress: Double = 0

    init(
        progress: Double,
        lineWidth: CGFloat = 16,
        gradient: [Color] = [.fuelGreen, .fuelGreen.opacity(0.7)],
        size: CGFloat = 180
    ) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.gradient = gradient
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    gradient.first?.opacity(0.15) ?? Color.gray.opacity(0.15),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // Progress ring
            Circle()
                .trim(from: 0, to: min(animatedProgress, 1.0))
                .stroke(
                    AngularGradient(
                        colors: gradient,
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360 * min(animatedProgress, 1.0))
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            // Overage indicator
            if animatedProgress > 1.0 {
                Circle()
                    .trim(from: 0, to: min(animatedProgress - 1.0, 1.0))
                    .stroke(
                        Color.fuelRed.opacity(0.6),
                        style: StrokeStyle(lineWidth: lineWidth * 0.6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
}

struct AnimatedRingWithLabel: View {
    let current: Int
    let target: Int
    let unit: String
    let lineWidth: CGFloat
    let size: CGFloat

    var progress: Double {
        guard target > 0 else { return 0 }
        return Double(current) / Double(target)
    }

    var body: some View {
        AnimatedRing(
            progress: progress,
            lineWidth: lineWidth,
            size: size
        )
        .overlay {
            VStack(spacing: 2) {
                Text("\(current)")
                    .font(.system(size: size * 0.2, weight: .bold, design: .rounded))
                    .contentTransition(.numericText())

                Text(unit)
                    .font(.system(size: size * 0.07, weight: .medium))
                    .foregroundStyle(.secondary)

                Text("of \(target)")
                    .font(.system(size: size * 0.08, weight: .regular, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 30) {
        AnimatedRingWithLabel(current: 1450, target: 2000, unit: "cal", lineWidth: 18, size: 200)
        AnimatedRingWithLabel(current: 2200, target: 2000, unit: "cal", lineWidth: 18, size: 200)
    }
}
