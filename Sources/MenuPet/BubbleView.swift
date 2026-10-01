import SwiftUI

struct BubbleLayer: View {
    let count: Int

    private let bubbles: [BubbleSpec] = [
        BubbleSpec(id: 0, x: 0.15, size: 7, duration: 9, delay: 0),
        BubbleSpec(id: 1, x: 0.84, size: 6, duration: 12, delay: 6),
        BubbleSpec(id: 2, x: 0.28, size: 5, duration: 11, delay: 2),
        BubbleSpec(id: 3, x: 0.72, size: 9, duration: 10, delay: 4),
        BubbleSpec(id: 4, x: 0.08, size: 5, duration: 13, delay: 3),
        BubbleSpec(id: 5, x: 0.93, size: 7, duration: 10, delay: 8),
        BubbleSpec(id: 6, x: 0.40, size: 6, duration: 12, delay: 5),
        BubbleSpec(id: 7, x: 0.61, size: 8, duration: 11, delay: 9)
    ]

    var body: some View {
        ZStack {
            ForEach(bubbles.prefix(count)) { bubble in
                RisingBubble(
                    x: bubble.x,
                    size: bubble.size,
                    duration: bubble.duration,
                    delay: bubble.delay
                )
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct BubbleSpec: Identifiable {
    let id: Int
    let x: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
}

private struct RisingBubble: View {
    let x: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
    @State private var isAtTop = false

    var body: some View {
        GeometryReader { geometry in
            Circle()
                .fill(Color.white.opacity(0.25))
                .overlay {
                    Circle()
                        .stroke(Color(red: 0.45, green: 0.75, blue: 0.82), lineWidth: 1)
                }
                .frame(width: size, height: size)
                .position(
                    x: geometry.size.width * x,
                    y: isAtTop ? -size : geometry.size.height + size
                )
                .task {
                    var noAnimation = Transaction(animation: nil)
                    noAnimation.disablesAnimations = true
                    withTransaction(noAnimation) { isAtTop = false }

                    do {
                        try await Task.sleep(for: .seconds(delay))
                        while !Task.isCancelled {
                            withAnimation(.linear(duration: duration)) {
                                isAtTop = true
                            }
                            try await Task.sleep(for: .seconds(duration))
                            withTransaction(noAnimation) { isAtTop = false }
                            try await Task.sleep(for: .seconds(2))
                        }
                    } catch {
                        return
                    }
                }
        }
    }
}
