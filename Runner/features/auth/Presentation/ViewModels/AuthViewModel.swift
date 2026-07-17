import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var currentUser: User? = nil
    @Published var deviceSessions: [DeviceSession] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published var isRestoringSession = false

    private let repository: AuthRepository
    private var sessionExpiredObserver: NSObjectProtocol?

    init(repository: AuthRepository = ServiceLocator.shared.authRepository) {
        self.repository = repository
        sessionExpiredObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("SessionExpired"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.logout()
            }
        }
    }

    deinit {
        if let sessionExpiredObserver {
            NotificationCenter.default.removeObserver(sessionExpiredObserver)
        }
    }

    func restoreSession() async {
        guard repository.isAuthenticated() else {
            currentUser = nil
            return
        }
        isRestoringSession = true
        switch await repository.getMe() {
        case .success(let user):
            currentUser = user
        case .failure:
            _ = await repository.logout()
            currentUser = nil
        }
        isRestoringSession = false
    }

    func login(email: String, password: String, onSuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        Task {
            let res = await repository.login(email: email, password: password)
            isLoading = false
            switch res {
            case .success(let user):
                self.currentUser = user
                onSuccess()
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }

    func register(email: String, username: String, password: String, fullName: String?, onSuccess: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        Task {
            let res = await repository.register(email: email, username: username, password: password, fullName: fullName)
            isLoading = false
            switch res {
            case .success(let user):
                self.currentUser = user
                onSuccess()
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }

    func loadDeviceSessions() {
        isLoading = true
        Task {
            let res = await repository.getDeviceSessions()
            isLoading = false
            switch res {
            case .success(let devices):
                self.deviceSessions = devices
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }

    func deleteDevice(id: String) {
        Task {
            let _ = await repository.deleteDeviceSession(id: id)
            loadDeviceSessions()
        }
    }

    func logout() async {
        _ = await repository.logout()
        currentUser = nil
    }
}
