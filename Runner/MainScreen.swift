import SwiftUI

struct MainScreen: View {
    let onSessionClick: (String) -> Void
    let onMatchClick: (String) -> Void
    let onCreateMatchClick: () -> Void
    let onMatchmakingClick: () -> Void
    let onLeaderboardClick: () -> Void
    let onPlayerClick: (String) -> Void
    let onNotificationsClick: () -> Void
    let onNavigateToMemberManagement: () -> Void
    let onNavigateToJoinRequests: () -> Void
    let onLogoutSuccess: () -> Void
    let onNavigateToDeviceSessions: () -> Void

    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var sessionsViewModel: SessionsViewModel
    @ObservedObject var paymentViewModel: PaymentViewModel
    @ObservedObject var communityViewModel: CommunityViewModel
    @ObservedObject var matchViewModel: MatchViewModel

    @State private var selectedTab = 0

    private var userName: String {
        if let fullName = authViewModel.currentUser?.fullName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !fullName.isEmpty {
            return fullName
        }
        return authViewModel.currentUser?.username ?? "Player"
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardScreen(
                userName: userName,
                hasUnreadNotifications: true,
                onNavigateToSessions: { selectedTab = 1 },
                onNavigateToProfile: { selectedTab = 4 },
                onNavigateToMatches: onMatchmakingClick,
                onNavigateToCommunity: { selectedTab = 3 },
                onNavigateToPayments: { selectedTab = 2 },
                onNotificationsClick: onNotificationsClick,
                onLeaderboardClick: onLeaderboardClick,
                onMatchmakingClick: onMatchmakingClick,
                onCreateMatchClick: onCreateMatchClick
            )
            .tabItem {
                Label("Dashboard", systemImage: "square.grid.2x2.fill")
            }
            .tag(0)

            SessionsScreen(
                onSessionClick: onSessionClick,
                viewModel: sessionsViewModel
            )
            .tabItem {
                Label("Sessions", systemImage: "figure.badminton")
            }
            .tag(1)

            PaymentsScreen(
                viewModel: paymentViewModel
            )
            .tabItem {
                Label("Payments", systemImage: "creditcard.fill")
            }
            .tag(2)

            CommunityScreen(
                onPlayerClick: onPlayerClick,
                onLeaderboardClick: onLeaderboardClick,
                onMembersClick: onNavigateToMemberManagement,
                onJoinRequestsClick: onNavigateToJoinRequests,
                viewModel: communityViewModel
            )
            .tabItem {
                Label("Community", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(3)

            PlayerProfileScreen(
                onNavigateToDeviceSessions: onNavigateToDeviceSessions,
                onNavigateToMemberManagement: onNavigateToMemberManagement,
                onNavigateToJoinRequests: onNavigateToJoinRequests,
                onLogoutSuccess: onLogoutSuccess,
                authViewModel: authViewModel
            )
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
            .tag(4)
        }
        .tint(AppTheme.primary)
    }
}
