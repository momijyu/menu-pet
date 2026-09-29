import SwiftUI

struct CreatureView: View{
    var size: CGFloat = 40
    var activityLevel: Double
    var caution: Double
    var onTap: () -> Void 
    let awakeColor = Color(
        hue: 0.35,
        saturation: 0.7,
        brightness: 0.85
    )

    let sleepingColor = Color(
        hue: 0.35,
        saturation: 0.35,
        brightness: 0.6
    )
    @State private var isSleeping = false
    @State private var isSquished = false
    @State private var positionX: CGFloat = 0
    var movementDuration: Double {
        4.0 - activityLevel * 2.5
    }

    var body: some View{
        ZStack{
            Circle()
                .fill(isSleeping ? sleepingColor : awakeColor)
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

                let nextX: CGFloat = positionX < 0 ? 40 : -40
                withAnimation(.easeInOut(duration: movementDuration)) {
                    positionX = nextX
                }

                do {
                    try await Task.sleep(for: .seconds(movementDuration))
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
