import SwiftUI

struct CreatureView: View{
    var size: CGFloat = 40
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
        .scaleEffect(
            x: isSleeping ? 1.1 : 1.0, 
            y: isSleeping ? 0.85 : 1.0
        )
        .onTapGesture {
            onTap()
            withAnimation(.easeInOut(duration: 0.25)) {
                isSleeping.toggle()
            }
        }
        .onAppear{
            let hour = Calendar.current.component(.hour, from: Date())
            isSleeping = hour >= 23 || hour < 7
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