import SwiftUI

struct CreatureView: View{
    private struct MovementTaskID: Equatable {
        let isSleeping: Bool
        let activityStep: Int
        let floatinessStep: Int
    }

    var size: CGFloat = 40
    var activityLevel: Double
    var caution: Double
    var hue: Double
    var mossiness: Double
    var bodyShape: Double
    var spaceJump: Double
    var floatiness: Double
    var sleepProfile: SleepProfile
    var onTap: () -> Void 
    var awakeColor: Color {
        Color(hue: hue, saturation: 0.7, brightness: 0.85)
    }
    var sleepingColor: Color {
        Color(hue: hue, saturation: 0.35, brightness: 0.6)
    }
    @State private var isSleeping = false
    @State private var isSquished = false
    @State private var isDashing = false
    @State private var isJumping = false
    @State private var gazeOffset: CGFloat = 0
    @State private var awakeUntil: Date?
    @State private var firstDeepSleepTapAt: Date?
    @State private var positionX: CGFloat = 0
    @State private var positionY: CGFloat = 0
    @State private var travelY: CGFloat = 0
    @State private var floatingStepsRemaining = 0
    var movementSpeed: Double {
        12 + activityLevel * 28
    }
    var movementRange: CGFloat {
        20 + CGFloat(activityLevel) * 50
    }
    var mossHalo: CGFloat {
        size * (0.02 + 0.13 * CGFloat(mossiness))
    }
    private var drawingSize: CGFloat {
        size + mossHalo * 2 + 16
    }
    private var movementTaskID: MovementTaskID {
        MovementTaskID(
            isSleeping: isSleeping,
            activityStep: Int((activityLevel * 20).rounded()),
            floatinessStep: Int((floatiness * 20).rounded())
        )
    }

    var body: some View{
        ZStack{
            ZStack {
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
                    .scaleEffect(
                        x: 1 + CGFloat(bodyShape) * 0.12,
                        y: 1 - CGFloat(bodyShape) * 0.12
                    )
                HStack {
                    EyeView(size: size, isSleeping: isSleeping, gazeOffset: gazeOffset)
                    EyeView(size: size, isSleeping: isSleeping, gazeOffset: gazeOffset)
                }
                .offset(y: -size * 0.08)
            }
            .frame(width: drawingSize, height: drawingSize)
            .drawingGroup()

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
        .offset(y: travelY)
        .offset(x: positionX)
        .scaleEffect(
            x: (isSleeping ? 1.1 : 1.0) * (isSquished ? 1.2 : 1.0),
            y: (isSleeping ? 0.85 : 1.0) * (isSquished ? 0.8 : 1.0)
        )
        .onTapGesture {
            onTap()
            respondToTap()
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
            updateSleepState()
        }
        .task(id: sleepProfile) {
            while !Task.isCancelled {
                updateSleepState()
                do {
                    try await Task.sleep(for: .seconds(0.5))
                } catch {
                    return
                }
            }
        }
        .task(id: movementTaskID) {
            floatingStepsRemaining = 0
            gazeOffset = 0
            while !Task.isCancelled {

                if isSleeping {
                    do {
                        try await Task.sleep(for: .seconds(0.5))
                    } catch {
                        return
                    }
                    continue
                }

                let restingTime = 0.5 + caution * 2
                    + max(0, 0.5 - activityLevel) * 3
                do {
                    try await Task.sleep(for: .seconds(restingTime))
                } catch {
                    return
                }
                guard !isSleeping else { continue }

                let nextX = positionX < 0 ? movementRange : -movementRange
                let dashChance = max(0, activityLevel - 0.4) * 0.7
                let shouldDash = !isJumping
                    && Double.random(in: 0..<1) < dashChance
                let nextY: CGFloat
                let explorationChance = min(max((activityLevel - 0.25) / 0.5, 0), 1)
                if shouldDash {
                    nextY = travelY
                } else if floatingStepsRemaining > 0 {
                    floatingStepsRemaining -= 1
                    nextY = -CGFloat(65 + floatiness * 55)
                        + CGFloat.random(in: -8...8)
                } else if Double.random(in: 0..<1) < explorationChance {
                    let upperRange = CGFloat(25 + activityLevel * 55 + floatiness * 25)
                    let lowerRange = CGFloat(10 + activityLevel * 20)
                    nextY = CGFloat.random(in: -upperRange...lowerRange)
                } else if Double.random(in: 0..<1) < 0.05 + floatiness * 0.07 {
                    floatingStepsRemaining = 2
                    nextY = -CGFloat(65 + floatiness * 55)
                } else {
                    nextY = -CGFloat.random(in: 0...12)
                }

                let distance = hypot(
                    Double(nextX - positionX),
                    Double(nextY - travelY)
                )
                let speed = movementSpeed
                let verticalShare = abs(Double(nextY - travelY)) / distance
                let duration = distance / speed * (1 + verticalShare * 0.3)

                let gazeDirection: CGFloat = nextX > positionX ? 1 : -1
                withAnimation(.easeInOut(duration: 0.2)) {
                    gazeOffset = gazeDirection * size * 0.055
                }
                let lookAheadTime = 0.25 + caution * 0.5
                do {
                    try await Task.sleep(for: .seconds(lookAheadTime))
                } catch {
                    return
                }
                guard !isSleeping else { continue }

                if shouldDash {
                    isDashing = true
                    defer { isDashing = false }
                    withAnimation(.timingCurve(0.2, 0.5, 0.6, 1, duration: duration)) {
                        positionX = nextX
                        travelY = nextY
                    }
                    do {
                        try await Task.sleep(for: .seconds(duration))
                    } catch {
                        return
                    }
                } else {
                    let startX = positionX
                    let startY = travelY
                    let steps = 12
                    let stepDuration = duration / Double(steps)

                    for step in 1...steps {
                        guard !Task.isCancelled else { return }
                        let progress = Double(step) / Double(steps)
                        let eased = progress * progress * (3 - 2 * progress)
                        // 始点と終点では揺れを0にして、次の移動へ滑らかにつなぐ。
                        let sway = step == steps ? 0 : CGFloat(sin(eased * 2 * .pi) * 6)
                        withAnimation(.linear(duration: stepDuration)) {
                            positionX = startX + (nextX - startX) * eased
                            travelY = startY + (nextY - startY) * eased + sway
                        }
                        do {
                            try await Task.sleep(for: .seconds(stepDuration))
                        } catch {
                            return
                        }
                    }
                }
                withAnimation(.easeInOut(duration: 0.25)) {
                    gazeOffset = 0
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
                guard !isSleeping, !isDashing, spaceJump > 0 else { continue }

                isJumping = true
                positionY = -(2 + CGFloat(spaceJump) * 8)
                do {
                    try await Task.sleep(for: .milliseconds(220))
                } catch {
                    isJumping = false
                    positionY = 0
                    return
                }
                positionY = 0
                do {
                    try await Task.sleep(for: .milliseconds(450))
                } catch {
                    isJumping = false
                    return
                }
                isJumping = false
            }
        }
    }

    private func respondToTap() {
        let now = Date()
        if isSleeping && sleepProfile.trait == .deep {
            guard let previous = firstDeepSleepTapAt,
                  now.timeIntervalSince(previous) <= 4 else {
                firstDeepSleepTapAt = now
                return
            }
        }

        firstDeepSleepTapAt = nil
        if isSleeping || sleepProfile.isSleeping(at: now) {
            awakeUntil = now.addingTimeInterval(sleepProfile.wakeDuration)
        }
        updateSleepState()
    }

    private func updateSleepState() {
        let now = Date()
        let shouldSleep = sleepProfile.isSleeping(at: now)
            && (awakeUntil.map { now >= $0 } ?? true)
        guard isSleeping != shouldSleep else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            isSleeping = shouldSleep
            if shouldSleep {
                positionX = 0
                positionY = 0
                travelY = 0
                gazeOffset = 0
                floatingStepsRemaining = 0
                isJumping = false
            }
        }
    }
}

struct EyeView: View {
    var size: CGFloat
    var isSleeping: Bool
    var gazeOffset: CGFloat

    var body: some View {
        Ellipse()
            .fill(.black)
            .frame(
                width: size * 0.1,
                height: isSleeping ? size * 0.025 : size * 0.1
            )
            .offset(x: isSleeping ? 0 : gazeOffset)
    }
}
