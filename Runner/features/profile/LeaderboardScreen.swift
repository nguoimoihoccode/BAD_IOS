import SwiftUI

struct LeaderboardScreen: View {
    let onBackClick: () -> Void
    let onPlayerClick: (String) -> Void
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
                Text("Leaderboard")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding()
            .background(Color.white)

            switch viewModel.uiState {
            case .loading, .ratingSuccess, .profileLoaded:
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
            case .leaderboardLoaded(let list):
                if list.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("Leaderboard is empty")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.PremiumDark)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(list.enumerated()), id: \.element.id) { index, player in
                                LeaderboardCard(
                                    player: player,
                                    rank: index + 1,
                                    onClick: { onPlayerClick(player.id) }
                                )
                            }
                        }
                        .padding(16)
                    }
                }
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.loadLeaderboard()
        }
    }
}

private struct LeaderboardCard: View {
    let player: PlayerProfile
    let rank: Int
    let onClick: () -> Void

    private var podiumColor: Color {
        switch rank {
        case 1: return Color(red: 1, green: 0.757, blue: 0.027)
        case 2: return Color(red: 0.741, green: 0.741, blue: 0.741)
        case 3: return Color(red: 1, green: 0.718, blue: 0.302)
        default: return AppTheme.OutlineGray
        }
    }

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(rank <= 3 ? podiumColor.opacity(0.15) : Color.clear)
                        .frame(width: 32, height: 32)
                    Text("#\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(rank <= 3 ? podiumColor : .gray)
                }

                ZStack {
                    Circle()
                        .fill(AppTheme.KineticGreen.opacity(0.1))
                        .frame(width: 40, height: 40)
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.KineticGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(player.fullName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                    Text("\(player.skillLevel) • WR: \(player.winRate)%")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(player.wins)W - \(player.losses)L")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.KineticGreen)
                    Text("\(player.matchesPlayed) matches")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(rank <= 3 ? podiumColor.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
