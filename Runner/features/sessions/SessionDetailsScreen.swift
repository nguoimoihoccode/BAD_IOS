import SwiftUI

struct SessionDetailsScreen: View {
    let sessionId: String
    let onBackClick: () -> Void
    @ObservedObject var viewModel: SessionsViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Appbar Header
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.PremiumDark)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
                Text("Session Details")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding()
            .background(Color.white)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                Spacer()
            } else if let session = viewModel.selectedSession {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text(session.title)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(AppTheme.PremiumDark)
                            
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.gray)
                                Text(session.date)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                Text(session.time)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.gray)
                                Text(session.location)
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(12)

                        // Cost Breakdown
                        VStack(alignment: .leading, spacing: 12) {
                            Text("COST BREAKDOWN")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.gray)
                            
                            HStack {
                                Text("Court Fee")
                                Spacer()
                                Text("\(Int(session.courtFee).formattedWithSeparator())đ")
                            }
                            HStack {
                                Text("Shuttlecock Fee")
                                Spacer()
                                Text("\(Int(session.shuttlecockFee).formattedWithSeparator())đ")
                            }
                            
                            Divider()
                            
                            HStack {
                                Text("Total Estimated Cost")
                                    .fontWeight(.bold)
                                Spacer()
                                Text("\(Int(session.totalFee).formattedWithSeparator())đ")
                                    .font(.system(size: 18, weight: .black))
                                    .foregroundColor(AppTheme.KineticGreen)
                            }
                            
                            HStack {
                                Text("Payment Status")
                                    .font(.system(size: 13, weight: .medium))
                                Spacer()
                                Text(session.paymentStatus)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(session.paymentStatus == "PAID" ? AppTheme.KineticGreen : AppTheme.ErrorRed)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                        // Participants
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("PARTICIPANTS")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("\(session.participants.count)/\(session.maxParticipants)")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(AppTheme.KineticGreen)
                            }
                            
                            ForEach(session.participants) { participant in
                                HStack(spacing: 12) {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                        .foregroundColor(AppTheme.KineticGreen.opacity(0.3))
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(participant.name)
                                            .font(.system(size: 14, weight: .medium))
                                        Text("Level: \(participant.level)")
                                            .font(.system(size: 11))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    if participant.isHost {
                                        Image(systemName: "checkmark.seal.fill")
                                            .foregroundColor(AppTheme.KineticGreen)
                                            .font(.system(size: 14))
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)

                        // Actions
                        Button(action: {
                            if session.isJoined {
                                viewModel.leaveSession(id: session.id)
                            } else {
                                viewModel.joinSession(id: session.id)
                            }
                        }) {
                            Text(session.isJoined ? "Leave Session" : "Join Session")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(session.isJoined ? AppTheme.ErrorRed : AppTheme.KineticGreen)
                                .cornerRadius(8)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .onAppear {
            viewModel.loadSessionDetails(id: sessionId)
        }
        .navigationBarBackButtonHidden(true)
    }
}
