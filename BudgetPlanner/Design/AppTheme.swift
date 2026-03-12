import SwiftUI
import UIKit

enum AppTheme {
    static let primaryLavender = Color.dynamic(light: 0xF7F5FF, dark: 0x161126)
    static let lightLavender = Color.dynamic(light: 0xE8E0FA, dark: 0x2B2140)
    static let primaryPurple = Color.dynamic(light: 0xA854F7, dark: 0xBF86FF)
    static let darkPurple = Color.dynamic(light: 0x9433EB, dark: 0xA56CFF)
    static let white = Color.dynamic(light: 0xFFFFFF, dark: 0x241C37)
    static let black = Color.dynamic(light: 0x231C4D, dark: 0xF4F1FF, lightOpacity: 0.96)
    static let headerIndigo = Color.dynamic(light: 0x251C52, dark: 0xEAE3FF)
    static let glowPurple = Color.dynamic(light: 0x8A58F5, dark: 0xB88CFF)
    static let gelVioletTop = Color.dynamic(light: 0x8D4EFF, dark: 0xA776FF)
    static let gelVioletBottom = Color.dynamic(light: 0x5E22D8, dark: 0x7A42E8)
    static let gelShadow = Color.dynamic(light: 0x331070, dark: 0x09060F, lightOpacity: 1, darkOpacity: 0.72)
    static let glassFill = Color.dynamic(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.10, darkOpacity: 0.12)
    static let glassEdge = Color.dynamic(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.30, darkOpacity: 0.18)

    static let background = Color.dynamic(light: 0xF7F4FF, dark: 0x0E0A17)
    static let textPrimary = black
    static let textSecondary = Color.dynamic(light: 0x6F619C, dark: 0xC7BDDF, lightOpacity: 0.92, darkOpacity: 0.86)
    static let cardTop = primaryPurple
    static let cardBottom = Color.dynamic(light: 0xE8E0FA, dark: 0x34274E)
    static let barFill = darkPurple
    static let barTrack = Color.dynamic(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.82, darkOpacity: 0.14)
    static let positive = Color.dynamic(light: 0x24B63B, dark: 0x58D46D)
    static let budgetPositive = positive
    static let negative = Color.dynamic(light: 0xE84F6D, dark: 0xFF7E96)
    static let surface = Color.dynamic(light: 0xFFFFFF, dark: 0x1A132A, lightOpacity: 0.94, darkOpacity: 0.96)
    static let surfaceSoft = Color.dynamic(light: 0xFFFFFF, dark: 0x211934, lightOpacity: 0.90, darkOpacity: 0.94)
    static let surfaceStrong = Color.dynamic(light: 0xDADDED, dark: 0x2A223E)
    static let outline = Color.dynamic(light: 0x9433EB, dark: 0xFFFFFF, lightOpacity: 0.10, darkOpacity: 0.10)
    static let shadow = Color.dynamic(light: 0x9433EB, dark: 0x000000, lightOpacity: 0.12, darkOpacity: 0.45)
    static let successSoft = Color.dynamic(light: 0xCFE7B9, dark: 0x2B4728)
    static let gold = Color.dynamic(light: 0xE59C2B, dark: 0xFFBE55)

    static let chartMint = Color.dynamic(light: 0xDBF6C7, dark: 0x36523A)
    static let chartSky = Color.dynamic(light: 0xDDEFFF, dark: 0x30455A)
    static let chartBlush = Color.dynamic(light: 0xFDE0EA, dark: 0x533345)
    static let chartButter = Color.dynamic(light: 0xFCF4BA, dark: 0x5C5030)
    static let chartLilac = Color.dynamic(light: 0xE6D6FC, dark: 0x4C3867)
    static let chartFog = Color.dynamic(light: 0xF0F3FA, dark: 0x303343)

    static let panel = Color.dynamic(light: 0xE8E0FA, dark: 0x2A203F, lightOpacity: 0.82, darkOpacity: 0.88)
    static let deepPanel = Color.dynamic(light: 0x9433EB, dark: 0x1D1630, lightOpacity: 0.92, darkOpacity: 0.96)
}

extension Color {
    static func dynamic(light: UInt, dark: UInt, lightOpacity: Double = 1, darkOpacity: Double? = nil) -> Color {
        Color(
            uiColor: UIColor { traits in
                let isDark = traits.userInterfaceStyle == .dark
                return UIColor(
                    hex: isDark ? dark : light,
                    alpha: isDark ? (darkOpacity ?? lightOpacity) : lightOpacity
                )
            }
        )
    }

    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

private extension UIColor {
    convenience init(hex: UInt, alpha: Double = 1) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: alpha
        )
    }
}
