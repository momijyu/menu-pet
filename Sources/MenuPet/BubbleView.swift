import SwiftUI

struct BubbleLayer: View {
    let count: Int
    let affection: Double
    let sparkleChance: Double

    private let bubbles: [BubbleSpec] = [
        BubbleSpec(id: 0, x: 0.15, size: 7, duration: 9, delay: 0, sway: 0),
        BubbleSpec(id: 1, x: 0.84, size: 6, duration: 12, delay: 6, sway: 5),
        BubbleSpec(id: 2, x: 0.28, size: 5, duration: 11, delay: 2, sway: 7),
        BubbleSpec(id: 3, x: 0.72, size: 9, duration: 10, delay: 4, sway: 0),
        BubbleSpec(id: 4, x: 0.08, size: 5, duration: 13, delay: 3, sway: 4),
        BubbleSpec(id: 5, x: 0.93, size: 7, duration: 10, delay: 8, sway: 6),
        BubbleSpec(id: 6, x: 0.40, size: 6, duration: 12, delay: 5, sway: 0),
        BubbleSpec(id: 7, x: 0.61, size: 8, duration: 11, delay: 9, sway: 8),
        BubbleSpec(id: 8, x: 0.51, size: 5, duration: 10, delay: 1, sway: 4),
        BubbleSpec(id: 9, x: 0.20, size: 8, duration: 13, delay: 7, sway: 0),
        BubbleSpec(id: 10, x: 0.77, size: 6, duration: 11, delay: 3, sway: 6),
        BubbleSpec(id: 11, x: 0.34, size: 7, duration: 12, delay: 10, sway: 5),
        BubbleSpec(id: 12, x: 0.67, size: 5, duration: 9, delay: 5, sway: 0),
        BubbleSpec(id: 13, x: 0.11, size: 6, duration: 11, delay: 11, sway: 7),
        BubbleSpec(id: 14, x: 0.88, size: 8, duration: 13, delay: 2, sway: 4),
        BubbleSpec(id: 15, x: 0.46, size: 7, duration: 10, delay: 8, sway: 6)
    ]

    private var heartChance: Double {
        guard affection >= 0.75 else { return 0 }
        return min(0.5, 0.3 + (affection - 0.75) * 0.8)
    }

    var body: some View {
        ZStack {
            ForEach(bubbles.prefix(count)) { bubble in
                RisingBubble(
                    x: bubble.x,
                    size: bubble.size,
                    duration: bubble.duration,
                    delay: bubble.delay,
                    sway: bubble.sway,
                    heartChance: bubble.id < 3 ? heartChance : 0,
                    sparkleChance: sparkleChance
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
    let sway: CGFloat
}

private struct RisingBubble: View {
    let x: CGFloat
    let size: CGFloat
    let duration: Double
    let delay: Double
    let sway: CGFloat
    let heartChance: Double
    let sparkleChance: Double
    @State private var isAtTop = false
    @State private var isHeart = false
    @State private var isSparkling = false
    @State private var sparklePulse = false
    @State private var swayOffset: CGFloat = 0
    @State private var currentHeartChance = 0.0
    @State private var currentSparkleChance = 0.0

    private var particleSize: CGFloat {
        isHeart ? max(size * 1.8, 10) : size
    }

    var body: some View {
        GeometryReader { geometry in
            Group {
                if isHeart {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(Color(red: 0.95, green: 0.38, blue: 0.54).opacity(0.75))
                        .frame(width: particleSize, height: particleSize)
                        .overlay(alignment: .topTrailing) {
                            if isSparkling {
                                Image(systemName: "sparkle")
                                    .font(.system(size: max(size * 1.2, 9)))
                                    .foregroundStyle(Color.yellow)
                                    .opacity(sparklePulse ? 1 : 0.2)
                                    .scaleEffect(sparklePulse ? 1.25 : 0.6)
                                    .offset(x: 4, y: -4)
                            }
                        }
                        .overlay(alignment: .bottomLeading) {
                            if isSparkling {
                                Image(systemName: "sparkle")
                                    .font(.system(size: max(size * 0.7, 6)))
                                    .foregroundStyle(Color.yellow)
                                    .opacity(sparklePulse ? 0.2 : 0.9)
                                    .scaleEffect(sparklePulse ? 0.6 : 1.15)
                                    .offset(x: -3, y: 3)
                            }
                        }
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .overlay {
                            Circle()
                                .stroke(Color(red: 0.45, green: 0.75, blue: 0.82), lineWidth: 1)
                        }
                        .frame(width: size, height: size)
                }
            }
                .position(
                    x: geometry.size.width * x,
                    y: isAtTop ? -particleSize : geometry.size.height + particleSize
                )
                .offset(x: swayOffset)
        }
        .onChange(of: heartChance) { newChance in
            currentHeartChance = newChance
        }
        .onChange(of: sparkleChance) { newChance in
            currentSparkleChance = newChance
        }
        .task(id: isSparkling) {
            var noAnimation = Transaction(animation: nil)
            noAnimation.disablesAnimations = true
            withTransaction(noAnimation) { sparklePulse = false }
            guard isSparkling else { return }

            do {
                try await Task.sleep(for: .milliseconds(50))
            } catch {
                return
            }
            withAnimation(.easeInOut(duration: 0.45).repeatForever(autoreverses: true)) {
                sparklePulse = true
            }
        }
        .task {
            currentHeartChance = heartChance
            currentSparkleChance = sparkleChance
            var noAnimation = Transaction(animation: nil)
            noAnimation.disablesAnimations = true
            withTransaction(noAnimation) {
                isAtTop = false
                isHeart = false
                isSparkling = false
                swayOffset = -sway
            }

            do {
                try await Task.sleep(for: .seconds(delay))
                if sway > 0 {
                    withAnimation(.easeInOut(duration: duration / 3).repeatForever(autoreverses: true)) {
                        swayOffset = sway
                    }
                }
                while !Task.isCancelled {
                    let showsHeart = Double.random(in: 0..<1) < currentHeartChance
                    withTransaction(noAnimation) {
                        isHeart = showsHeart
                        isSparkling = showsHeart
                            && Double.random(in: 0..<1) < currentSparkleChance
                    }
                    withAnimation(.linear(duration: duration)) {
                        isAtTop = true
                    }
                    try await Task.sleep(for: .seconds(duration))
                    withTransaction(noAnimation) {
                        isAtTop = false
                        isSparkling = false
                    }
                    try await Task.sleep(for: .seconds(2))
                }
            } catch {
                return
            }
        }
    }
}
