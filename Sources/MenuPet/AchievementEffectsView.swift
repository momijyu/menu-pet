import SwiftUI

struct NightStarsView: View {
    let count: Int
    @State private var glowing = false

    private let positions: [(CGFloat, CGFloat)] = [
        (0.17, 0.18), (0.72, 0.12), (0.45, 0.31), (0.87, 0.27)
    ]

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<min(count, positions.count), id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: CGFloat(7 + index * 2)))
                    .foregroundStyle(Color.white.opacity(glowing ? 0.9 : 0.3))
                    .shadow(color: .white.opacity(glowing ? 0.7 : 0), radius: 5)
                    .position(
                        x: geometry.size.width * positions[index].0,
                        y: geometry.size.height * positions[index].1
                    )
                    .animation(
                        .easeInOut(duration: 1.8 + Double(index) * 0.4)
                            .repeatForever(autoreverses: true),
                        value: glowing
                    )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
        .onAppear { glowing = true }
    }
}
