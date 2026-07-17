import SwiftUI

struct MatchmakingScreen: View {
    let onBackClick: () -> Void
    let onChallengeClick: (String) -> Void
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
                Text("Matchmaking")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding()
            .background(Color.white)

            if viewModel.isMatchmakingLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                Spacer()
            } else if let error = viewModel.matchmakingError {
                Spacer()
                Text(error)
                    .foregroundColor(AppTheme.ErrorRed)
                    .padding()
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(AppTheme.KineticGreen)
                                    .frame(width: 70, height: 70)
                                    .shadow(color: AppTheme.KineticGreen.opacity(0.3), radius: 8, x: 0, y: 2)
                                Image(systemName: "sportscourt.fill")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 16)

                        Text("Recommended Opponents")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.PremiumDark)

                        ForEach(viewModel.matchmakingCandidates) { opp in
                            OpponentCard(
                                opponent: opp,
                                onChallenge: { onChallengeClick(opp.id) }
                            )
                        }
                    }
                    .padding(16)
                }
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            viewModel.loadMatchmakingCandidates()
        }
    }
}

private struct OpponentCard: View {
    let opponent: OpponentCandidate
    let onChallenge: () -> Void

    private var isCompatible: Bool { opponent.compatibilityScore >= 80 }
    private var compatColor: Color { isCompatible ? AppTheme.KineticGreen : Color.orange }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppTheme.KineticGreen.opacity(0.1))
                    .frame(width: 48, height: 48)
                Text(String(opponent.fullName.prefix(1)).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.KineticGreen)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(opponent.fullName)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Text("@\(opponent.username) • \(opponent.skillLevel)")
                    .font(.system(size: 11))
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 6)
                            Capsule()
                                .fill(compatColor)
                                .frame(width: geo.size.width * CGFloat(opponent.compatibilityScore) / 100, height: 6)
                        }
                    }
                    .frame(width: 80, height: 6)

                    Text("\(opponent.compatibilityScore)% match")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(compatColor)
                }
            }

            Spacer(minLength: 8)

            Button(action: onChallenge) {
                Text("Challenge")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(AppTheme.KineticGreen)
                    .cornerRadius(8)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}
