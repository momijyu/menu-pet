import SwiftUI

struct AquariumMoonView: View {
    var body: some View {
        Image(systemName: "moon.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(Color(red: 0.96, green: 0.96, blue: 0.82))
            .opacity(0.6)
            .blur(radius: 2.5)
            .shadow(color: .white.opacity(0.2), radius: 10)
            .frame(width: 44, height: 44)
            .padding(.top, 18)
            .padding(.leading, 72)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}

struct SandSparklesView: View {
    let level: Int
    @State private var glowing = false

    var body: some View {
        GeometryReader { geometry in
            ForEach(0..<(min(max(level, 0), 4) * 3), id: \.self) { index in
                Image(systemName: "sparkle")
                    .font(.system(size: index.isMultiple(of: 3) ? 6 : 4))
                    .foregroundStyle(Color(red: 1, green: 0.88, blue: 0.48))
                    .opacity(glowing ? 0.9 : 0.15)
                    .scaleEffect(glowing ? 1 : 0.6)
                    .position(
                        x: geometry.size.width * CGFloat((index * 31 + 17) % 100) / 100,
                        y: 6 + (geometry.size.height - 12)
                            * CGFloat((index * 13 + 9) % 40) / 40
                    )
                    .animation(
                        .easeInOut(duration: 1.2 + Double(index % 3) * 0.3)
                            .delay(Double(index) * 0.15)
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
