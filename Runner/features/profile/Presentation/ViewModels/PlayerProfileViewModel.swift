import Foundation
import Combine

enum PlayerProfileUiState: Equatable {
    case loading
    case profileLoaded(PlayerProfile)
    case leaderboardLoaded([PlayerProfile])
    case ratingSuccess
    case error(String)
}

@MainActor
class PlayerProfileViewModel: ObservableObject {
    @Published var uiState: PlayerProfileUiState = .loading
    @Published var isSubmitting = false

    private let repository: PlayerRepository

    init(repository: PlayerRepository = ServiceLocator.shared.playerRepository) {
        self.repository = repository
    }

    func loadPlayerProfile(playerId: String) {
        uiState = .loading
        Task {
            let result = await repository.getPlayerProfile(playerId: playerId)
            switch result {
            case .success(let profile):
                uiState = .profileLoaded(profile)
            case .failure(let error):
                uiState = .error(error.localizedDescription)
            }
        }
    }

    func loadLeaderboard() {
        uiState = .loading
        Task {
            let result = await repository.getLeaderboard()
            switch result {
            case .success(let list):
                uiState = .leaderboardLoaded(list)
            case .failure(let error):
                uiState = .error(error.localizedDescription)
            }
        }
    }

    func submitPlayerRating(playerId: String, skillRating: Double, fairPlayRating: Double) {
        isSubmitting = true
        uiState = .loading
        Task {
            let result = await repository.ratePlayer(
                playerId: playerId,
                skillRating: skillRating,
                fairPlayRating: fairPlayRating
            )
            switch result {
            case .success:
                uiState = .ratingSuccess
            case .failure(let error):
                uiState = .error(error.localizedDescription)
            }
            isSubmitting = false
        }
    }
}
