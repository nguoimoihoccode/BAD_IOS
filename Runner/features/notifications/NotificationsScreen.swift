import SwiftUI

struct NotificationsScreen: View {
    let onBackClick: () -> Void
    @ObservedObject var viewModel: NotificationsViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.PremiumDark)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
                Text("Notifications")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                
                let hasUnread = viewModel.notifications.contains { !$0.isRead }
                if hasUnread {
                    Button(action: { viewModel.markAllAsRead() }) {
                        Text("Mark all read")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.KineticGreen)
                    }
                } else {
                    Spacer().frame(width: 44)
                }
            }
            .padding()
            .background(Color.white)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                Spacer()
            } else {
                if viewModel.notifications.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.4))
                        Text("All caught up!")
                            .font(.system(size: 16, weight: .bold))
                        Text("No notifications yet.")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List(viewModel.notifications) { notification in
                        NotificationItemRow(notification: notification)
                            .onTapGesture {
                                viewModel.markAsRead(id: notification.id)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

struct NotificationItemRow: View {
    let notification: NotificationItem

    var body: some View {
        let cardBg = notification.isRead ? Color.white : AppTheme.KineticGreen.opacity(0.03)
        let cardBorder = notification.isRead ? AppTheme.OutlineGray.opacity(0.15) : AppTheme.KineticGreen.opacity(0.15)

        let iconName = notification.type == "booking" ? "calendar.badge.plus" : (notification.type == "payment" ? "doc.plaintext" : "megaphone.fill")
        let iconColor = notification.type == "booking" ? AppTheme.KineticGreen : (notification.type == "payment" ? AppTheme.ErrorRed : Color.orange)

        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 18))
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(iconColor.opacity(0.08))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.system(size: 14, weight: notification.isRead ? .semibold : .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                
                Text(notification.body)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(cardBg)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(cardBorder, lineWidth: 1)
        )
        .padding(.vertical, 4)
    }
}
