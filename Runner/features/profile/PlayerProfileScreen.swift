import SwiftUI

struct PlayerProfileScreen: View {
    let onNavigateToDeviceSessions: () -> Void
    var onNavigateToMemberManagement: () -> Void = {}
    var onNavigateToJoinRequests: () -> Void = {}
    let onLogoutSuccess: () -> Void
    @ObservedObject var authViewModel: AuthViewModel

    @AppStorage("pref_push_notifications") private var notificationsEnabled = true
    @AppStorage("pref_sound_effects") private var soundEnabled = false

    private var displayName: String {
        authViewModel.currentUser?.fullName?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
            ?? authViewModel.currentUser?.username
            ?? "Player"
    }

    private var email: String {
        authViewModel.currentUser?.email ?? "player@courtside.com"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer().frame(height: 8)

                profileHeader

                skillStatsCard

                settingsCard

                logoutButton
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.KineticGreen.opacity(0.1))
                    .frame(width: 76, height: 76)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.primaryContainer, lineWidth: 2)
                    )
                Text(String(displayName.prefix(1)).uppercased())
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(AppTheme.KineticGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Text(email)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    Text("Gold Level")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(Color(red: 0.98, green: 0.66, blue: 0.15))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(red: 1, green: 0.98, blue: 0.77))
                        .cornerRadius(50)

                    Text("Intermediate")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(AppTheme.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppTheme.primaryContainer.opacity(0.1))
                        .cornerRadius(50)
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.OutlineGray.opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private var skillStatsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.primary)
                Text("Badminton Skill Stats")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
            }

            SkillRow(skillName: "Smashing", value: 0.85, barColor: AppTheme.accent)
            SkillRow(skillName: "Stamina", value: 0.75, barColor: AppTheme.SecondaryGreen)
            SkillRow(skillName: "Speed", value: 0.80, barColor: AppTheme.primaryContainer)
            SkillRow(skillName: "Control", value: 0.90, barColor: AppTheme.primary)
            SkillRow(skillName: "Backhand", value: 0.70, barColor: AppTheme.tertiary)
        }
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.OutlineGray.opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private var settingsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.SecondaryGreen)
                Text("Settings & Preferences")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Push Notifications")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                    Text("Receive session alerts & tournament news")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                Toggle("", isOn: $notificationsEnabled)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryContainer))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("App Sound Effects")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                    Text("Enable haptics and game audio triggers")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
                Toggle("", isOn: $soundEnabled)
                    .labelsHidden()
                    .toggleStyle(SwitchToggleStyle(tint: AppTheme.primaryContainer))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            Divider()

            Button(action: onNavigateToDeviceSessions) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Device Sessions")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.PremiumDark)
                        Text("Manage active login devices and security")
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppTheme.OutlineGray.opacity(0.5), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    private var logoutButton: some View {
        Button(action: {
            Task {
                await authViewModel.logout()
                onLogoutSuccess()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                Text("Log Out Account")
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(AppTheme.ErrorRed)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(AppTheme.ErrorRed.opacity(0.08))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.ErrorRed.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct SkillRow: View {
    let skillName: String
    let value: Float
    let barColor: Color

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(skillName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.gray)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.OutlineGray.opacity(0.35))
                        .frame(height: 6)
                    Capsule()
                        .fill(barColor)
                        .frame(width: geo.size.width * CGFloat(value), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(.bottom, 8)
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
