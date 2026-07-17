import Foundation
import Combine

@MainActor
class NotificationsViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let repository: NotificationRepository

    init(repository: NotificationRepository = ServiceLocator.shared.notificationRepository) {
        self.repository = repository
        loadNotifications()
    }

    func loadNotifications() {
        isLoading = true
        errorMessage = nil
        Task {
            let res = await repository.getNotifications()
            isLoading = false
            switch res {
            case .success(let list):
                self.notifications = list
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }

    func markAsRead(id: String) {
        Task {
            let _ = await repository.markAsRead(notificationId: id)
            loadNotifications()
        }
    }

    func markAllAsRead() {
        Task {
            let _ = await repository.markAllAsRead()
            loadNotifications()
        }
    }
}
