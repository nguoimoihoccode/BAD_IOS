import SwiftUI

struct SessionsScreen: View {
    let onSessionClick: (String) -> Void
    @ObservedObject var viewModel: SessionsViewModel

    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Upcoming").tag(0)
                Text("Past").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                Spacer()
            } else {
                let sessions = selectedTab == 0 ? viewModel.upcomingSessions : viewModel.pastSessions

                if sessions.isEmpty {
                    Spacer()
                    Text("No sessions found")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(sessions) { session in
                        SessionRow(session: session)
                            .onTapGesture {
                                onSessionClick(session.id)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .onAppear {
            viewModel.loadSessions()
        }
    }
}

struct SessionRow: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(session.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                Text("\(Int(session.totalFee).formattedWithSeparator())đ")
                    .font(.system(size: 16, weight: .black))
                    .foregroundColor(AppTheme.KineticGreen)
            }

            Text("\(session.date) • \(session.time)")
                .font(.system(size: 12))
                .foregroundColor(.gray)

            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.gray)
                Text(session.location)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Spacer()
                
                if session.isJoined {
                    Text("JOINED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.KineticGreen)
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

extension Int {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = "."
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
