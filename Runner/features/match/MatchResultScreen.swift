import SwiftUI

struct MatchResultScreen: View {
    let matchId: String
    let onBackClick: () -> Void
    let onBackHome: () -> Void
    @ObservedObject var viewModel: MatchViewModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.PremiumDark)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
                Text("Match Results")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding()
            .background(Color.white)

            if viewModel.isDetailLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                Spacer()
            } else if let error = viewModel.detailError {
                Spacer()
                Text(error)
                    .foregroundColor(AppTheme.ErrorRed)
                    .padding()
                Spacer()
            } else if let match = viewModel.currentMatch {
                MatchResultContent(match: match, onBackHome: onBackHome)
            } else {
                Spacer()
                Text("Match not found")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.loadMatchDetail(matchId: matchId)
        }
    }
}

private struct MatchResultContent: View {
    let match: MatchItem
    let onBackHome: () -> Void

    private var stats: (p1Sets: Int, p2Sets: Int, p1Points: Int, p2Points: Int, p1Wins: Bool) {
        var p1Sets = 0
        var p2Sets = 0
        var p1Points = 0
        var p2Points = 0
        for set in match.setScores {
            p1Points += set.p1
            p2Points += set.p2
            if set.p1 > set.p2 { p1Sets += 1 }
            else if set.p2 > set.p1 { p2Sets += 1 }
        }
        return (p1Sets, p2Sets, p1Points, p2Points, p1Sets > p2Sets)
    }

    private var dateLabel: String {
        let f = DateFormatter()
        f.dateFormat = "d/M/yyyy"
        return f.string(from: match.date)
    }

    var body: some View {
        let s = stats
        let winnerName = s.p1Wins ? match.player1Name : match.player2Name

        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 48))
                        .foregroundColor(AppTheme.KineticGreen)
                    Text("MATCH COMPLETED")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.KineticGreen)
                        .tracking(1.5)
                    Text("\(winnerName) wins the match!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(AppTheme.KineticGreen.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.KineticGreen.opacity(0.2), lineWidth: 1)
                )
                .cornerRadius(12)

                HStack {
                    PlayerColumn(name: match.player1Name, isWinner: s.p1Wins)
                    Spacer()
                    Text("\(s.p1Sets) - \(s.p2Sets)")
                        .font(.system(size: 28, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.12))
                        .cornerRadius(12)
                    Spacer()
                    PlayerColumn(name: match.player2Name, isWinner: !s.p1Wins)
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(12)

                Text("Sets Scoreboard")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)

                ForEach(Array(match.setScores.enumerated()), id: \.offset) { index, set in
                    SetScoreRow(setNum: index + 1, p1: set.p1, p2: set.p2)
                }

                VStack(spacing: 0) {
                    DetailRow(icon: "mappin.and.ellipse", label: "Venue", value: match.courtName)
                    Divider().padding(.vertical, 12)
                    DetailRow(icon: "calendar", label: "Played Date", value: dateLabel)
                    Divider().padding(.vertical, 12)
                    DetailRow(icon: "chart.bar.fill", label: "Total Points Won", value: "\(s.p1Points) - \(s.p2Points)")
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)

                Button(action: onBackHome) {
                    Text("Back to Dashboard")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.KineticGreen)
                        .cornerRadius(8)
                }
                .padding(.top, 16)
            }
            .padding(16)
        }
    }
}

private struct PlayerColumn: View {
    let name: String
    let isWinner: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(AppTheme.KineticGreen.opacity(0.1))
                    .frame(width: 52, height: 52)
                Text(String(name.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.KineticGreen)
            }
            Text(name)
                .font(.system(size: 13, weight: isWinner ? .bold : .medium))
                .foregroundColor(AppTheme.PremiumDark)
                .lineLimit(1)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SetScoreRow: View {
    let setNum: Int
    let p1: Int
    let p2: Int

    private var p1Wins: Bool { p1 > p2 }

    var body: some View {
        HStack {
            Text("Set \(setNum)")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)
            Spacer()
            Text("\(p1)")
                .font(.system(size: 16, weight: p1Wins ? .bold : .medium))
                .foregroundColor(p1Wins ? AppTheme.KineticGreen : AppTheme.PremiumDark)
            Text("vs")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.gray)
                .padding(.horizontal, 24)
            Text("\(p2)")
                .font(.system(size: 16, weight: !p1Wins ? .bold : .medium))
                .foregroundColor(!p1Wins ? AppTheme.KineticGreen : AppTheme.PremiumDark)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
    }
}

private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppTheme.KineticGreen)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(AppTheme.PremiumDark)
        }
    }
}
