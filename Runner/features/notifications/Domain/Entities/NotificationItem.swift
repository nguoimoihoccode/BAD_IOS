import Foundation

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let body: String
    let createdAt: Date
    var isRead: Bool
    let type: String // 'booking', 'announcement', 'payment'
}
