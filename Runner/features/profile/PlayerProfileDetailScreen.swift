import SwiftUI

struct PlayerProfileDetailScreen: View {
    let playerId: String
    let onBackClick: () -> Void
    let onRateClick: (String) -> Void
    @ObservedObject var viewModel: PlayerProfileViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.PremiumDark)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
                Text("Player Profile")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding()
            .background(Color.white)

            switch viewModel.uiState {
            case .loading, .ratingSuccess, .leaderboardLoaded:
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                Spacer()
            case .error(let message):
                Spacer()
                Text(message)
                    .foregroundColor(AppTheme.ErrorRed)
                    .padding()
                Spacer()
            case .profileLoaded(let profile):
                ScrollView {
                    ProfileBody(
                        profile: profile,
                        onRateClick: { onRateClick(profile.id) }
                    )
                    .padding(16)
                }
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.loadPlayerProfile(playerId: playerId)
        }
    }
}

private struct ProfileBody: View {
    let profile: PlayerProfile
    let onRateClick: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.KineticGreen.opacity(0.1))
                    .frame(width: 96, height: 96)
                Text(String(profile.fullName.prefix(1)).uppercased())
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(AppTheme.KineticGreen)
            }

            Text(profile.fullName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppTheme.PremiumDark)

            Text("@\(profile.username)")
                .font(.system(size: 13))
                .foregroundColor(.gray)

            Text(profile.skillLevel.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppTheme.KineticGreen)
                .tracking(0.5)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(AppTheme.KineticGreen.opacity(0.1))
                .clipShape(Capsule())

            HStack {
                StatBox(label: "Matches", value: "\(profile.matchesPlayed)")
                StatBox(label: "Wins", value: "\(profile.wins)", color: AppTheme.KineticGreen)
                StatBox(label: "Losses", value: "\(profile.losses)", color: AppTheme.ErrorRed)
                StatBox(label: "Win Rate", value: "\(profile.winRate)%")
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)

            sectionTitle("Community Ratings")
            VStack(spacing: 12) {
                RatingRow(label: "Skill Rating", rating: profile.skillRating)
                Divider()
                RatingRow(label: "Fairplay Rating", rating: profile.fairPlayRating)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)

            sectionTitle("Bio")
            Text(profile.bio)
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)

            sectionTitle("Contact Information")
            VStack(alignment: .leading, spacing: 12) {
                ContactRow(systemImage: "envelope.fill", value: profile.email)
                Divider()
                ContactRow(systemImage: "phone.fill", value: profile.phone)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .cornerRadius(12)

            Button(action: onRateClick) {
                Text("Rate Player Performance")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppTheme.KineticGreen)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(AppTheme.PremiumDark)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct StatBox: View {
    let label: String
    let value: String
    var color: Color = AppTheme.PremiumDark

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct RatingRow: View {
    let label: String
    let rating: Double

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.PremiumDark)
            Spacer()
            HStack(spacing: 2) {
                ForEach(0..<5, id: \.self) { index in
                    let remaining = rating - Double(index)
                    Image(systemName: remaining >= 1 ? "star.fill" : (remaining > 0 ? "star.leadinghalf.filled" : "star"))
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 1, green: 0.757, blue: 0.027))
                }
            }
            Text(String(format: "%.1f", rating))
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.PremiumDark)
                .padding(.leading, 4)
        }
    }
}

private struct ContactRow: View {
    let systemImage: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundColor(AppTheme.KineticGreen)
                .font(.system(size: 16))
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(AppTheme.PremiumDark)
        }
    }
}
