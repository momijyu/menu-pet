import SwiftUI

struct WaterPlantView: View {
    @State private var swaysRight = false

    var body: some View {
        ZStack {
            blade(baseX: 23, tipX: 5, tipY: 30, color: Color(red: 0.16, green: 0.52, blue: 0.39))
            blade(baseX: 35, tipX: 28, tipY: 8, color: Color(red: 0.18, green: 0.65, blue: 0.44))
            blade(baseX: 47, tipX: 65, tipY: 23, color: Color(red: 0.12, green: 0.56, blue: 0.39))
            blade(baseX: 57, tipX: 74, tipY: 48, color: Color(red: 0.24, green: 0.68, blue: 0.47))
        }
        .frame(width: 80, height: 105)
        .rotationEffect(.degrees(swaysRight ? 3 : -3), anchor: .bottom)
        .animation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true), value: swaysRight)
        .onAppear { swaysRight = true }
    }

    private func blade(baseX: CGFloat, tipX: CGFloat, tipY: CGFloat, color: Color) -> some View {
        Path { path in
            path.move(to: CGPoint(x: baseX - 4, y: 105))
            path.addQuadCurve(to: CGPoint(x: tipX, y: tipY),
                              control: CGPoint(x: baseX - 12, y: 55))
            path.addQuadCurve(to: CGPoint(x: baseX + 4, y: 105),
                              control: CGPoint(x: tipX + 16, y: 65))
            path.closeSubpath()
        }
        .fill(color.opacity(0.8))
    }
}

struct AquaticGrassView: View {
    let compact: Bool
    @State private var swaysRight = false

    private var leaves: [(base: CGFloat, tip: CGFloat, height: CGFloat, width: CGFloat)] {
        compact
            ? [(0.20, 0.03, 0.60, 0.11), (0.32, 0.24, 0.92, 0.13),
               (0.47, 0.55, 0.98, 0.11), (0.60, 0.85, 0.86, 0.10),
               (0.72, 0.97, 0.52, 0.09)]
            : [(0.18, 0.02, 0.53, 0.07), (0.27, 0.28, 0.84, 0.055),
               (0.36, 0.15, 0.99, 0.07), (0.43, 0.63, 0.73, 0.085),
               (0.51, 0.74, 0.93, 0.055), (0.62, 0.97, 0.48, 0.075)]
    }

    var body: some View {
        ZStack {
            ForEach(leaves.indices, id: \.self) { index in
                let leaf = leaves[index]
                GrassBlade(baseX: leaf.base, tipX: leaf.tip, height: leaf.height,
                           width: leaf.width,
                           sway: (swaysRight ? 3 : -3)
                               * (index.isMultiple(of: 2) ? 1 : -0.65))
                    .fill(LinearGradient(
                        colors: [Color(red: 0.10, green: 0.34, blue: 0.24),
                                 Color(red: 0.20 + Double(index % 3) * 0.025,
                                       green: 0.52 + Double(index % 2) * 0.05, blue: 0.34)],
                        startPoint: .bottom, endPoint: .top
                    ))
                    .animation(
                        .easeInOut(duration: 3.8 + Double(index) * 0.3)
                            .repeatForever(autoreverses: true), value: swaysRight
                    )
            }
        }
        .onAppear { swaysRight = true }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

private struct GrassBlade: Shape {
    let baseX: CGFloat
    let tipX: CGFloat
    let height: CGFloat
    let width: CGFloat
    var sway: CGFloat

    var animatableData: CGFloat {
        get { sway }
        set { sway = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let root = CGPoint(x: rect.minX + rect.width * baseX, y: rect.maxY)
        let tip = CGPoint(x: rect.minX + rect.width * tipX + sway,
                          y: rect.maxY - rect.height * height)
        let halfWidth = rect.width * width / 2
        let bendX = root.x + (tip.x - root.x) * 0.4
        var path = Path()
        path.move(to: CGPoint(x: root.x - halfWidth, y: root.y))
        path.addCurve(to: tip,
                      control1: CGPoint(x: bendX - halfWidth, y: root.y - rect.height * height * 0.4),
                      control2: CGPoint(x: tip.x - halfWidth, y: tip.y + rect.height * height * 0.25))
        path.addCurve(to: CGPoint(x: root.x + halfWidth, y: root.y),
                      control1: CGPoint(x: tip.x + halfWidth, y: tip.y + rect.height * height * 0.3),
                      control2: CGPoint(x: bendX + halfWidth, y: root.y - rect.height * height * 0.35))
        path.closeSubpath()
        return path
    }
}
