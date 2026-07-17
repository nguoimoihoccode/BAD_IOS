import SwiftUI

struct DashboardScreen: View {
    var userName: String = "Player"
    var hasUnreadNotifications: Bool = true
    let onNavigateToSessions: () -> Void
    let onNavigateToProfile: () -> Void
    let onNavigateToMatches: () -> Void
    let onNavigateToCommunity: () -> Void
    let onNavigateToPayments: () -> Void
    let onNotificationsClick: () -> Void
    var onLeaderboardClick: () -> Void = {}
    var onMatchmakingClick: () -> Void = {}
    var onCreateMatchClick: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                statsRow

                outstandingDuesAlert

                VStack(alignment: .leading, spacing: 8) {
                    Text("Upcoming Match")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                    nextSessionHeroCard
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Quick Shortcuts")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                    shortcutsGrid
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(userName)! 👋")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Text("Ready for some matches today?")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.gray)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onNotificationsClick) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.gray)
                            .frame(width: 36, height: 36)

                        if hasUnreadNotifications {
                            Circle()
                                .fill(AppTheme.ErrorRed)
                                .frame(width: 9, height: 9)
                                .offset(x: -4, y: 4)
                        }
                    }
                }

                Button(action: onNavigateToProfile) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.KineticGreen.opacity(0.12))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Circle()
                                    .stroke(AppTheme.primaryContainer, lineWidth: 2)
                            )
                        Text(String(userName.prefix(1)).uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.KineticGreen)
                    }
                }
            }
        }
        .padding(.top, 16)
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            StatCard(value: "18", label: "Matches", systemImage: "figure.badminton", iconColor: AppTheme.primary)
            StatCard(value: "32h", label: "Court Time", systemImage: "clock.fill", iconColor: AppTheme.SecondaryGreen)
            StatCard(value: "68%", label: "Win Rate", systemImage: "chart.line.uptrend.xyaxis", iconColor: AppTheme.accent)
        }
    }

    private var outstandingDuesAlert: some View {
        Button(action: onNavigateToPayments) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppTheme.ErrorRed)
                        .frame(width: 36, height: 36)
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Outstanding Dues Alert")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.ErrorRed)
                    Text("You have a pending invoice of 150.000đ. Tap to pay now.")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.ErrorRed)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppTheme.ErrorRed)
            }
            .padding(16)
            .background(AppTheme.ErrorRed.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.ErrorRed.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var nextSessionHeroCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 10))
                    Text("City Arena • Court 2")
                        .font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.white.opacity(0.15))
                .cornerRadius(50)

                Spacer()

                Text("IN 2 HOURS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(AppTheme.primaryContainer)
                    .kerning(0.5)
            }

            Spacer().frame(height: 20)

            Text("Standard Court Session")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            Spacer().frame(height: 4)

            Text("Today, 6:00 PM - 8:00 PM")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(0.7))

            Spacer().frame(height: 16)

            Divider()
                .background(Color.white.opacity(0.24))

            Spacer().frame(height: 16)

            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 12))
                    Text("4 Players registered")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(.white.opacity(0.7))

                Spacer()

                Button(action: onNavigateToSessions) {
                    Text("View Details")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .underline()
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [AppTheme.primary, Color(red: 0, green: 0.3, blue: 0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(12)
    }

    private var shortcutsGrid: some View {
        let items: [(String, String, () -> Void)] = [
            ("Book Court", "figure.badminton", onNavigateToSessions),
            ("Invoices", "creditcard.fill", onNavigateToPayments),
            ("Community", "person.3.fill", onNavigateToCommunity),
            ("Matchmaking", "person.2.wave.2.fill", onMatchmakingClick),
            ("New Match", "trophy.fill", onCreateMatchClick),
            ("My Stats", "person.fill", onNavigateToProfile),
        ]

        return VStack(spacing: 8) {
            ForEach(0..<2, id: \.self) { row in
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { col in
                        let index = row * 3 + col
                        let item = items[index]
                        ShortcutGridItem(label: item.0, systemImage: item.1, action: item.2)
                    }
                }
            }
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let systemImage: String
    var iconColor: Color = AppTheme.KineticGreen

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.08))
                    .frame(width: 36, height: 36)
                Image(systemName: systemImage)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)
            }

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppTheme.PremiumDark)

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.gray)
                .kerning(0.5)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.OutlineGray.opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(12)
    }
}

struct AlertItem: View {
    let title: String
    let description: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 24))
                    .foregroundColor(color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(color)
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(16)
            .background(color.opacity(0.08))
            .cornerRadius(12)
        }
    }
}

struct ShortcutItem: View {
    let label: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .foregroundColor(AppTheme.KineticGreen)
                Text(label)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
}

struct ShortcutGridItem: View {
    let label: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 22))
                    .foregroundColor(AppTheme.primary)
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1.1, contentMode: .fit)
            .padding(8)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.OutlineGray.opacity(0.5), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
