import SwiftUI

struct RatePlayerScreen: View {
    let playerId: String
    let onBackClick: () -> Void
    @ObservedObject var viewModel: PlayerProfileViewModel

    @State private var skillRating = 5
    @State private var fairPlayRating = 5
    @State private var showThanks = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.PremiumDark)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
                Text("Rate Player")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding()
            .background(Color.white)

            ScrollView {
                VStack(spacing: 16) {
                    Text("Share your feedback")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                        .multilineTextAlignment(.center)

                    Text("Your ratings help keep the matches fair and standard in our community.")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Text("Skill level rating")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                    RatingSelectorCard(
                        rating: skillRating,
                        label: skillRatingText(skillRating),
                        onRatingChange: { skillRating = $0 }
                    )

                    Text("Fairplay & Sportsmanship")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)

                    RatingSelectorCard(
                        rating: fairPlayRating,
                        label: fairPlayRatingText(fairPlayRating),
                        onRatingChange: { fairPlayRating = $0 }
                    )

                    Button(action: {
                        viewModel.submitPlayerRating(
                            playerId: playerId,
                            skillRating: Double(skillRating),
                            fairPlayRating: Double(fairPlayRating)
                        )
                    }) {
                        Group {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Submit Ratings")
                                    .font(.system(size: 15, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(AppTheme.KineticGreen)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isSubmitting)
                    .padding(.top, 16)
                }
                .padding(16)
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .onReceive(viewModel.$uiState) { newState in
            if newState == .ratingSuccess {
                showThanks = true
                viewModel.loadPlayerProfile(playerId: playerId)
                DispatchQueue.main.async {
                    onBackClick()
                }
            }
        }
    }

    private func skillRatingText(_ score: Int) -> String {
        switch score {
        case 1: return "Novice / Beginner"
        case 2: return "Advanced Beginner"
        case 3: return "Competent Intermediate"
        case 4: return "Advanced / High-level"
        default: return "Expert / Professional"
        }
    }

    private func fairPlayRatingText(_ score: Int) -> String {
        switch score {
        case 1: return "Poor Sportsmanship"
        case 2: return "Somewhat Impatient"
        case 3: return "Fair / Standard"
        case 4: return "Friendly & Courteous"
        default: return "Exceptional Fairplay"
        }
    }
}

private struct RatingSelectorCard: View {
    let rating: Int
    let label: String
    let onRatingChange: (Int) -> Void

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Button(action: { onRatingChange(star) }) {
                        Image(systemName: rating >= star ? "star.fill" : "star")
                            .font(.system(size: 28))
                            .foregroundColor(Color(red: 1, green: 0.757, blue: 0.027))
                    }
                }
            }
            Text(label)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.KineticGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}
