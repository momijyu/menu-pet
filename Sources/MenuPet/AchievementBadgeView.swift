import SwiftUI

struct AchievementBadgeView: View {
    let symbol: String
    let tier: Int
    let isUnlocked: Bool

    private let names = ["銅", "銀", "金", "特別"]

    private var medalColors: [Color] {
        switch tier {
        case 0: return [Color(red: 0.95, green: 0.72, blue: 0.48), Color(red: 0.52, green: 0.28, blue: 0.15)]
        case 1: return [Color(red: 0.97, green: 0.99, blue: 1.0), Color(red: 0.53, green: 0.65, blue: 0.72)]
        default: return [Color(red: 1.0, green: 0.94, blue: 0.55), Color(red: 0.80, green: 0.53, blue: 0.14)]
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                if tier == 3 {
                    waterDropTrophy
                } else {
                    medal
                }
            }
            .frame(width: 60, height: 65)
            .saturation(isUnlocked ? 1 : 0)
            .opacity(isUnlocked ? 1 : 0.35)
            Text(isUnlocked ? names[tier] : "???")
                .font(.caption.bold())
                .foregroundStyle(isUnlocked ? Color.primary : Color.secondary)
        }
    }

    private var medal: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: medalColors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .overlay(Circle().strokeBorder(.white.opacity(0.7), lineWidth: 2))
                .overlay(Circle().strokeBorder(.black.opacity(0.18), lineWidth: 1).padding(7))
                .frame(width: 54, height: 54)
            Text(symbol)
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.72))
            if tier == 2 {
                Image(systemName: "sparkle")
                    .font(.system(size: 12))
                    .foregroundStyle(.white)
                    .offset(x: 23, y: -22)
            }
        }
        .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
    }

    private var waterDropTrophy: some View {
        VStack(spacing: -4) {
            ZStack {
                Image(systemName: "drop.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(LinearGradient(
                        colors: [Color(red: 0.82, green: 1.0, blue: 0.98), Color(red: 0.23, green: 0.69, blue: 0.79)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 47, height: 55)
                Text(symbol)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.07, green: 0.35, blue: 0.42))
                    .offset(y: -7)
                Circle()
                    .fill(Color(red: 0.22, green: 0.78, blue: 0.36))
                    .frame(width: 15, height: 15)
                    .overlay {
                        HStack(spacing: 4) {
                            Circle().frame(width: 2, height: 2)
                            Circle().frame(width: 2, height: 2)
                        }
                        .foregroundStyle(.black)
                    }
                    .offset(y: 13)
            }
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.17, green: 0.52, blue: 0.59))
                .frame(width: 27, height: 5)
        }
        .shadow(color: .cyan.opacity(0.3), radius: 4, y: 2)
    }
}
