import SwiftUI

struct MatchScoreEntryScreen: View {
    let matchId: String
    let onBackClick: () -> Void
    let onScoreSaved: (String) -> Void
    @ObservedObject var viewModel: MatchViewModel

    @State private var p1Set1 = 0
    @State private var p2Set1 = 0
    @State private var p1Set2 = 0
    @State private var p2Set2 = 0
    @State private var p1Set3 = 0
    @State private var p2Set3 = 0
    @State private var hasSet3 = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.PremiumDark)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
                Text("Enter Match Score")
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
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(match.player1Name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.KineticGreen)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                            Text("VS")
                                .font(.system(size: 11, weight: .black))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                            Text(match.player2Name)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.PremiumDark)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                        .padding(16)
                        .background(AppTheme.KineticGreen.opacity(0.03))
                        .cornerRadius(12)

                        SetCounterCard(title: "Set 1", p1: $p1Set1, p2: $p2Set1)
                        SetCounterCard(title: "Set 2", p1: $p1Set2, p2: $p2Set2)

                        Toggle(isOn: $hasSet3) {
                            Text("Play Set 3 (Tiebreaker)")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .toggleStyle(SwitchToggleStyle(tint: AppTheme.KineticGreen))

                        if hasSet3 {
                            SetCounterCard(title: "Set 3", p1: $p1Set3, p2: $p2Set3)
                        }

                        Button(action: {
                            var scores = [
                                ScoreSet(p1: p1Set1, p2: p2Set1),
                                ScoreSet(p1: p1Set2, p2: p2Set2),
                            ]
                            if hasSet3 {
                                scores.append(ScoreSet(p1: p1Set3, p2: p2Set3))
                            }
                            viewModel.enterMatchScore(
                                matchId: matchId,
                                setScores: scores,
                                onSuccess: { onScoreSaved(matchId) }
                            )
                        }) {
                            Group {
                                if viewModel.isSubmitting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Save Results")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(AppTheme.KineticGreen)
                            .cornerRadius(8)
                        }
                        .disabled(viewModel.isSubmitting)
                        .padding(.top, 16)
                    }
                    .padding(24)
                }
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

private struct SetCounterCard: View {
    let title: String
    @Binding var p1: Int
    @Binding var p2: Int

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.gray)

            HStack {
                CounterControls(value: $p1)
                Text("-")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                CounterControls(value: $p2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

private struct CounterControls: View {
    @Binding var value: Int

    var body: some View {
        HStack {
            Button(action: { if value > 0 { value -= 1 } }) {
                Image(systemName: "minus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.KineticGreen)
                    .frame(width: 36, height: 36)
            }
            .disabled(value <= 0)

            Text("\(value)")
                .font(.system(size: 24, weight: .bold))
                .frame(width: 48)
                .multilineTextAlignment(.center)

            Button(action: { value += 1 }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.KineticGreen)
                    .frame(width: 36, height: 36)
            }
        }
    }
}
