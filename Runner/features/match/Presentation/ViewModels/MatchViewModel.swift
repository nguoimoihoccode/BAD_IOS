import Foundation
import Combine

@MainActor
class MatchViewModel: ObservableObject {
    @Published var scheduledMatches: [MatchItem] = []
    @Published var completedMatches: [MatchItem] = []
    @Published var opponents: [OpponentCandidate] = []
    @Published var matchmakingCandidates: [OpponentCandidate] = []
    @Published var currentMatch: MatchItem?
    @Published var isLoading = false
    @Published var isMatchmakingLoading = false
    @Published var isDetailLoading = false
    @Published var isSubmitting = false
    @Published var errorMessage: String? = nil
    @Published var matchmakingError: String? = nil
    @Published var detailError: String? = nil

    private let repository: MatchRepository

    init(repository: MatchRepository = ServiceLocator.shared.matchRepository) {
        self.repository = repository
        loadMatchData()
    }

    func loadMatchData() {
        isLoading = true
        errorMessage = nil
        Task {
            let resScheduled = await repository.getScheduledMatches()
            let resCompleted = await repository.getCompletedMatches()
            let resOpps = await repository.findMatchmakingOpponents()
            isLoading = false

            if case .success(let sched) = resScheduled,
               case .success(let comp) = resCompleted {
                self.scheduledMatches = sched
                self.completedMatches = comp
                if case .success(let oppList) = resOpps {
                    self.opponents = oppList
                }
            } else {
                self.errorMessage = "Failed to load match listings"
            }
        }
    }

    func loadMatchmakingCandidates() {
        isMatchmakingLoading = true
        matchmakingError = nil
        Task {
            let res = await repository.findMatchmakingOpponents()
            isMatchmakingLoading = false
            switch res {
            case .success(let candidates):
                self.matchmakingCandidates = candidates
                self.opponents = candidates
            case .failure(let error):
                self.matchmakingError = error.localizedDescription
            }
        }
    }

    func loadMatchDetail(matchId: String) {
        isDetailLoading = true
        detailError = nil
        currentMatch = nil
        Task {
            let res = await repository.getMatchDetail(matchId: matchId)
            isDetailLoading = false
            switch res {
            case .success(let match):
                self.currentMatch = match
            case .failure(let error):
                self.detailError = error.localizedDescription
            }
        }
    }

    func createMatch(
        opponentId: String,
        courtName: String,
        date: Date,
        onSuccess: @escaping (MatchItem) -> Void,
        onError: @escaping (String) -> Void = { _ in }
    ) {
        isSubmitting = true
        Task {
            let res = await repository.createMatch(opponentId: opponentId, courtName: courtName, date: date)
            isSubmitting = false
            switch res {
            case .success(let match):
                loadMatchData()
                onSuccess(match)
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }

    func enterMatchScore(
        matchId: String,
        setScores: [ScoreSet],
        onSuccess: @escaping () -> Void,
        onError: @escaping (String) -> Void = { _ in }
    ) {
        isSubmitting = true
        Task {
            let res = await repository.enterMatchScore(matchId: matchId, setScores: setScores)
            isSubmitting = false
            switch res {
            case .success:
                loadMatchData()
                onSuccess()
            case .failure(let error):
                onError(error.localizedDescription)
            }
        }
    }
}
