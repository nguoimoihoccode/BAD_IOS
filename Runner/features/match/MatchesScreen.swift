import SwiftUI

struct MatchesScreen: View {
    let onMatchClick: (String) -> Void
    let onCreateMatchClick: () -> Void
    @ObservedObject var viewModel: MatchViewModel

    @State private var selectedTab = 0

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "d/M/yyyy"
        return f
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("Scheduled").tag(0)
                    Text("Results").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                    Spacer()
                } else {
                    let matches = selectedTab == 0 ? viewModel.scheduledMatches : viewModel.completedMatches

                    if matches.isEmpty {
                        Spacer()
                        Text("No matches found")
                            .foregroundColor(.gray)
                        Spacer()
                    } else {
                        List(matches) { match in
                            MatchRow(match: match, dateLabel: dateFormatter.string(from: match.date))
                                .onTapGesture {
                                    if !match.isCompleted {
                                        onMatchClick(match.id)
                                    }
                                }
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }

            Button(action: onCreateMatchClick) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(AppTheme.KineticGreen)
                    .clipShape(Circle())
                    .shadow(color: AppTheme.KineticGreen.opacity(0.3), radius: 4, x: 0, y: 4)
            }
            .padding(24)
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .onAppear {
            viewModel.loadMatchData()
        }
    }
}

struct MatchRow: View {
    let match: MatchItem
    let dateLabel: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(match.courtName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(AppTheme.KineticGreen)
                Spacer()
                Text(dateLabel)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(match.player1Name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                    Text(match.player2Name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                }

                Spacer()

                if match.isCompleted {
                    VStack(alignment: .trailing, spacing: 4) {
                        ForEach(match.setScores) { set in
                            Text("\(set.p1) - \(set.p2)")
                                .font(.system(size: 14, weight: .black))
                                .foregroundColor(set.p1 > set.p2 ? AppTheme.KineticGreen : .gray)
                        }
                    }
                } else {
                    Text("Record Score")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.vertical, 4)
    }
}
