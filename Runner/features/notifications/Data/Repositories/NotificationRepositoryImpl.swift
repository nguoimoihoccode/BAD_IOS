import Foundation

class NotificationRepositoryImpl: NotificationRepository {
    private var notifications = [
        NotificationItem(id: "n1", title: "Sân số 3 đã được đặt thành công", body: "Buổi tập lúc 18:00 ngày mai tại sân cỏ nhân tạo đã được ghi nhận. Chuẩn bị ra sân nhé!", createdAt: Date(timeIntervalSinceNow: -600), isRead: false, type: "booking"),
        NotificationItem(id: "n2", title: "Có thông báo mới từ ban quản trị", body: "Lịch thi đấu đơn nam/nữ giải Maxton Open đã được công bố. Vui lòng kiểm tra tab Cộng đồng để biết thêm chi tiết.", createdAt: Date(timeIntervalSinceNow: -7200), isRead: false, type: "announcement"),
        NotificationItem(id: "n3", title: "Yêu cầu thanh toán chi phí buổi tập", body: "Hoá đơn chi phí buổi tập ngày 05/07 đang chờ xử lý. Vui lòng thanh toán số tiền 120,000đ.", createdAt: Date(timeIntervalSinceNow: -86400), isRead: true, type: "payment"),
        NotificationItem(id: "n4", title: "Xác nhận thành viên mới gia nhập", body: "Thành viên Nguyễn Văn A vừa được phê duyệt tham gia câu lạc bộ.", createdAt: Date(timeIntervalSinceNow: -259200), isRead: true, type: "announcement")
    ]

    func getNotifications() async -> Result<[NotificationItem], Error> {
        return .success(notifications)
    }

    func markAsRead(notificationId: String) async -> Result<Void, Error> {
        if let idx = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[idx].isRead = true
        }
        return .success(())
    }

    func markAllAsRead() async -> Result<Void, Error> {
        for idx in 0..<notifications.count {
            notifications[idx].isRead = true
        }
        return .success(())
    }
}
