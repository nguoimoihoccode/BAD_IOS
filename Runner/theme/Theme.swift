import SwiftUI

struct AppTheme {
    // Flutter AppColors parity
    static let primary = Color(red: 0/255, green: 108/255, blue: 73/255)      // #006C49
    static let primaryContainer = Color(red: 16/255, green: 185/255, blue: 129/255) // #10B981
    static let accent = Color(red: 255/255, green: 126/255, blue: 45/255)     // #FF7E2D
    static let tertiary = Color(red: 157/255, green: 67/255, blue: 0/255)     // #9D4300
    static let background = Color(red: 248/255, green: 249/255, blue: 255/255) // #F8F9FF
    static let surface = background
    static let onBackground = Color(red: 11/255, green: 28/255, blue: 48/255) // #0B1C30
    static let onSurface = onBackground
    static let outline = Color(red: 108/255, green: 122/255, blue: 113/255)
    static let error = Color(red: 186/255, green: 26/255, blue: 26/255)       // #BA1A1A

    // Back-compat aliases
    static let KineticGreen = primaryContainer
    static let SecondaryGreen = Color(red: 5/255, green: 150/255, blue: 105/255)
    static let PremiumDark = onBackground
    static let SoftGray = background
    static let OutlineGray = Color(red: 229/255, green: 231/255, blue: 235/255)
    static let ErrorRed = error

    static let spaceSm: CGFloat = 8
    static let spaceMd: CGFloat = 16
    static let spaceLg: CGFloat = 24
    static let radiusMd: CGFloat = 12
    static let radiusLg: CGFloat = 16
}
