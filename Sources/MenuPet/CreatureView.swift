import SwiftUI

struct CreatureView: View{
    var size: CGFloat = 40
    var activityLevel: Double
    var caution: Double
    var hue: Double
    var mossiness: Double
    var spaceJump: Double
    var onTap: () -> Void 
    var awakeColor: Color {
        Color(hue: hue, saturation: 0.7, brightness: 0.85)
    }
    var sleepingColor: Color {
        Color(hue: hue, saturation: 0.35, brightness: 0.6)
    }
    @State private var isSleeping = false
    @State private var isSquished = false
    @State private var positionX: CGFloat = 0
    @State private var positionY: CGFloat = 0
    var movementSpeed: Double {
        12 + activityLevel * 28
    }
    var movementRange: CGFloat {
        20 + CGFloat(activityLevel) * 50
    }
    var mossHalo: CGFloat {
        size * (0.02 + 0.13 * CGFloat(mossiness))
    }

    var body: some View{
        ZStack{
            Circle()
                .fill(isSleeping ? sleepingColor : awakeColor)
                .frame(width: size, height: size)
                .background {
                    Canvas { context, canvasSize in
                        let center = CGPoint(
                            x: canvasSize.width / 2,
                            y: canvasSize.height / 2
                        )
                        let color = isSleeping ? sleepingColor : awakeColor
                        let dotCount = 220

                        for index in 0..<dotCount {
                            let angle = CGFloat(index) * 2 * .pi / CGFloat(dotCount)
                            let variation = CGFloat((index * 37) % 101) / 100
                            let radius = size / 2 + mossHalo * (variation - 0.25)
                            let dotSize = (0.6 + variation * 1.1)
                                * (0.3 + CGFloat(mossiness) * 0.7)
                            let point = CGPoint(
                                x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius
                            )
                            let dot = Path(ellipseIn: CGRect(
                                x: point.x - dotSize / 2,
                                y: point.y - dotSize / 2,
                                width: dotSize,
                                height: dotSize
                            ))
                            context.fill(
                                dot,
                                with: .color(color.opacity(Double(0.2 + variation * 0.35)))
                            )
                        }
                    }
                    .frame(width: size + mossHalo * 2 + 4,
                           height: size + mossHalo * 2 + 4)
                    .blur(radius: 1)
                }
            HStack{
                EyeView(size: size, isSleeping: isSleeping)
                EyeView(size: size, isSleeping: isSleeping)
            }
            .offset(y: -size * 0.08)
            if isSleeping {
                Text("Zzz...")
                    .font(.system(size: size * 0.25))
                    .foregroundStyle(.secondary)
                    .offset(x: size * 0.65, y: -size * 0.65)
            }
        }
        .frame(width: size, height: size)
        .offset(y: positionY)
        .animation(
            positionY == 0
                ? .spring(response: 0.45, dampingFraction: 0.55)
                : .easeOut(duration: 0.22),
            value: positionY
        )
        .offset(x: positionX)
        .scaleEffect(
            x: (isSleeping ? 1.1 : 1.0) * (isSquished ? 1.2 : 1.0),
            y: (isSleeping ? 0.85 : 1.0) * (isSquished ? 0.8 : 1.0)
        )
        .onTapGesture {
            onTap()
            withAnimation(.easeOut(duration: 0.1)) {
                isSquished = true
            }
        }
        .task(id: isSquished) {
            guard isSquished else { return }
            do {
                try await Task.sleep(for: .milliseconds(100))
            } catch {
                return
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.4)) {
                isSquished = false
            }
        }
        .onAppear{
            let hour = Calendar.current.component(.hour, from: Date())
            isSleeping = hour >= 23 || hour < 7
        }
        .task {
            while !Task.isCancelled {
                let hour = Calendar.current.component(.hour, from: Date())
                let shouldSleep = hour >= 23 || hour < 7
                if isSleeping != shouldSleep {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSleeping = shouldSleep
                    }
                }

                if isSleeping {
                    do {
                        try await Task.sleep(for: .seconds(0.5))
                    } catch {
                        return
                    }
                    continue
                }

                do {
                    try await Task.sleep(for: .seconds(0.5 + caution * 2))
                } catch {
                    return
                }
                guard !isSleeping else { continue }

                let nextX = positionX < 0 ? movementRange : -movementRange
                let distance = abs(nextX - positionX)
                let dashChance = max(0, activityLevel - 0.4) * 0.7
                let shouldDash = Double.random(in: 0..<1) < dashChance
                let speed = movementSpeed * (shouldDash ? 2.5 : 1)
                let duration = Double(distance) / speed
                let animation: Animation = shouldDash
                    ? .linear(duration: duration)
                    : .easeInOut(duration: duration)
                withAnimation(animation) {
                    positionX = nextX
                }

                do {
                    try await Task.sleep(for: .seconds(duration))
                } catch {
                    return
                }
            }
        }
        .task {
            while !Task.isCancelled {
                do {
                    try await Task.sleep(for: .seconds(8 - spaceJump * 5))
                } catch {
                    return
                }
                guard !isSleeping, spaceJump > 0 else { continue }

                positionY = -(2 + CGFloat(spaceJump) * 8)
                do {
                    try await Task.sleep(for: .milliseconds(220))
                } catch {
                    return
                }
                positionY = 0
                do {
                    try await Task.sleep(for: .milliseconds(450))
                } catch {
                    return
                }
            }
        }
    }
}

struct EyeView: View {
    var size: CGFloat
    var isSleeping: Bool

    var body: some View {
        Ellipse()
            .fill(.black)
            .frame(
                width: size * 0.1,
                height: isSleeping ? size * 0.025 : size * 0.1
            )
    }
}
