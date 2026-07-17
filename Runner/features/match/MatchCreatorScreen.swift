import SwiftUI

struct MatchCreatorScreen: View {
    var preselectedOpponentId: String? = nil
    let onBackClick: () -> Void
    let onMatchCreated: (String) -> Void
    @ObservedObject var viewModel: MatchViewModel

    private let opponentsList: [(id: String, name: String)] = [
        ("m1", "Trần Nguyễn Tiến (Advanced)"),
        ("m3", "Lê Hoài Nam (Intermediate)"),
        ("m4", "Phạm Minh Trí (Beginner)"),
    ]

    private let courtsList = [
        "City Arena • Court 1",
        "City Arena • Court 2",
        "City Arena • Court 3",
        "Standard Club • Court 5",
    ]

    @State private var selectedOpponentId: String = "m1"
    @State private var selectedCourt = "City Arena • Court 2"
    @State private var selectedDate = Calendar.current.date(
        bySettingHour: 18, minute: 0, second: 0, of: Date()
    ) ?? Date()
    @State private var didApplyPreselect = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.PremiumDark)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
                Text("Create Singles Match")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding()
            .background(Color.white)

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Opponent")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.PremiumDark)

                        Picker("Opponent", selection: $selectedOpponentId) {
                            ForEach(opponentsList, id: \.id) { opp in
                                Text(opp.name).tag(opp.id)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Select Court Venue")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.PremiumDark)

                        Picker("Court", selection: $selectedCourt) {
                            ForEach(courtsList, id: \.self) { court in
                                Text(court).tag(court)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date & Time")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.PremiumDark)

                        DatePicker(
                            "",
                            selection: $selectedDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }

                    Button(action: {
                        viewModel.createMatch(
                            opponentId: selectedOpponentId,
                            courtName: selectedCourt,
                            date: selectedDate,
                            onSuccess: { match in onMatchCreated(match.id) }
                        )
                    }) {
                        Group {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Create & Enter Score")
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
                }
                .padding(24)
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onAppear {
            guard !didApplyPreselect else { return }
            didApplyPreselect = true
            if let id = preselectedOpponentId, opponentsList.contains(where: { $0.id == id }) {
                selectedOpponentId = id
            }
        }
    }
}
