import Foundation
import Combine

@MainActor
class SessionsViewModel: ObservableObject {
    @Published var upcomingSessions: [Session] = []
    @Published var pastSessions: [Session] = []
    @Published var selectedSession: Session? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let repository: SessionRepository

    init(repository: SessionRepository = ServiceLocator.shared.sessionRepository) {
        self.repository = repository
    }

    func loadSessions() {
        isLoading = true
        errorMessage = nil
        Task {
            let resUpcoming = await repository.getUpcomingSessions()
            let resPast = await repository.getPastSessions()
            isLoading = false
            
            if case .success(let upcoming) = resUpcoming, case .success(let past) = resPast {
                self.upcomingSessions = upcoming
                self.pastSessions = past
            } else {
                self.errorMessage = "Failed to load badminton sessions"
            }
        }
    }

    func loadSessionDetails(id: String) {
        isLoading = true
        Task {
            let res = await repository.getSessionDetails(id: id)
            isLoading = false
            switch res {
            case .success(let session):
                self.selectedSession = session
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }

    func joinSession(id: String) {
        Task {
            let _ = await repository.joinSession(id: id)
            loadSessionDetails(id: id)
            loadSessions()
        }
    }

    func leaveSession(id: String) {
        Task {
            let _ = await repository.leaveSession(id: id)
            loadSessionDetails(id: id)
            loadSessions()
        }
    }
}
