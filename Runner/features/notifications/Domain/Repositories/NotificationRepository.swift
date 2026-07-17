import Foundation

protocol NotificationRepository {
    func getNotifications() async -> Result<[NotificationItem], Error>
    func markAsRead(notificationId: String) async -> Result<Void, Error>
    func markAllAsRead() async -> Result<Void, Error>
}
