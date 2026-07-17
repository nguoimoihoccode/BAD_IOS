import SwiftUI

struct MainNavigation: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var sessionsViewModel = SessionsViewModel()
    @StateObject private var paymentViewModel = PaymentViewModel()
    @StateObject private var communityViewModel = CommunityViewModel()
    @StateObject private var matchViewModel = MatchViewModel()
    @StateObject private var notificationsViewModel = NotificationsViewModel()
    @StateObject private var adminViewModel = AdminViewModel()
    @StateObject private var playerProfileViewModel = PlayerProfileViewModel()

    @State private var navigationPath = NavigationPath()
    @State private var isFirstTime: Bool = UserDefaults.standard.object(forKey: "is_first_time") == nil ? true : UserDefaults.standard.bool(forKey: "is_first_time")
    @State private var didRestoreSession = false

    var body: some View {
        if isFirstTime {
            OnboardingScreen(onGetStarted: {
                UserDefaults.standard.set(false, forKey: "is_first_time")
                withAnimation {
                    isFirstTime = false
                }
            })
        } else {
            NavigationStack(path: $navigationPath) {
                Group {
                    if authViewModel.isRestoringSession && !didRestoreSession {
                        ZStack {
                            AppTheme.PremiumDark.ignoresSafeArea()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                        }
                    } else if authViewModel.currentUser != nil {
                        mainScreen
                    } else {
                        WelcomeScreen(
                            onSignInClick: { navigationPath.append("login") },
                            onCreateAccountClick: { navigationPath.append("register") }
                        )
                    }
                }
                .navigationDestination(for: String.self) { route in
                    destination(for: route)
                }
            }
            .task {
                await authViewModel.restoreSession()
                didRestoreSession = true
            }
            .onReceive(authViewModel.$currentUser) { user in
                if user == nil {
                    navigationPath = NavigationPath()
                }
            }
        }
    }

    private var mainScreen: some View {
        ResponsiveContainer {
            MainScreen(
                onSessionClick: { sessionId in navigationPath.append("session_details/\(sessionId)") },
                onMatchClick: { matchId in navigationPath.append("match_score_entry/\(matchId)") },
                onCreateMatchClick: { navigationPath.append("match_creator") },
                onMatchmakingClick: { navigationPath.append("matchmaking") },
                onLeaderboardClick: { navigationPath.append("leaderboard") },
                onPlayerClick: { playerId in navigationPath.append("player_profile/\(playerId)") },
                onNotificationsClick: { navigationPath.append("notifications") },
                onNavigateToMemberManagement: { navigationPath.append("member_management") },
                onNavigateToJoinRequests: { navigationPath.append("join_requests") },
                onLogoutSuccess: {
                    navigationPath = NavigationPath()
                },
                onNavigateToDeviceSessions: { navigationPath.append("device_sessions") },
                authViewModel: authViewModel,
                sessionsViewModel: sessionsViewModel,
                paymentViewModel: paymentViewModel,
                communityViewModel: communityViewModel,
                matchViewModel: matchViewModel
            )
        }
    }

    @ViewBuilder
    private func destination(for route: String) -> some View {
        switch route {
        case "login":
            LoginScreen(
                onBackClick: { navigationPath.removeLast() },
                onLoginSuccess: {
                    navigationPath = NavigationPath()
                },
                viewModel: authViewModel
            )
        case "register":
            RegisterScreen(
                onBackClick: { navigationPath.removeLast() },
                onRegisterSuccess: {
                    navigationPath = NavigationPath()
                },
                viewModel: authViewModel
            )
        case "main":
            mainScreen
                .navigationBarBackButtonHidden(true)
        case "match_creator":
            MatchCreatorScreen(
                onBackClick: { navigationPath.removeLast() },
                onMatchCreated: { matchId in
                    navigationPath.append("match_score_entry/\(matchId)")
                },
                viewModel: matchViewModel
            )
        case "notifications":
            NotificationsScreen(
                onBackClick: { navigationPath.removeLast() },
                viewModel: notificationsViewModel
            )
        case "member_management":
            MemberManagementScreen(
                onBackClick: { navigationPath.removeLast() },
                viewModel: adminViewModel
            )
        case "join_requests":
            JoinRequestsScreen(
                onBackClick: { navigationPath.removeLast() },
                viewModel: adminViewModel
            )
        case "device_sessions":
            DeviceSessionsScreen(
                onBackClick: { navigationPath.removeLast() },
                viewModel: authViewModel
            )
        case "matchmaking":
            MatchmakingScreen(
                onBackClick: { navigationPath.removeLast() },
                onChallengeClick: { opponentId in
                    navigationPath.append("match_creator/\(opponentId)")
                },
                viewModel: matchViewModel
            )
        case "leaderboard":
            LeaderboardScreen(
                onBackClick: { navigationPath.removeLast() },
                onPlayerClick: { playerId in navigationPath.append("player_profile/\(playerId)") },
                viewModel: playerProfileViewModel
            )
        default:
            if route.hasPrefix("session_details/") {
                let sessionId = String(route.dropFirst("session_details/".count))
                SessionDetailsScreen(
                    sessionId: sessionId,
                    onBackClick: { navigationPath.removeLast() },
                    viewModel: sessionsViewModel
                )
            } else if route.hasPrefix("match_creator/") {
                let opponentId = String(route.dropFirst("match_creator/".count))
                MatchCreatorScreen(
                    preselectedOpponentId: opponentId.isEmpty ? nil : opponentId,
                    onBackClick: { navigationPath.removeLast() },
                    onMatchCreated: { matchId in
                        navigationPath.append("match_score_entry/\(matchId)")
                    },
                    viewModel: matchViewModel
                )
            } else if route.hasPrefix("match_score_entry/") {
                let matchId = String(route.dropFirst("match_score_entry/".count))
                MatchScoreEntryScreen(
                    matchId: matchId,
                    onBackClick: { navigationPath.removeLast() },
                    onScoreSaved: { id in
                        navigationPath.append("match_result/\(id)")
                    },
                    viewModel: matchViewModel
                )
            } else if route.hasPrefix("match_result/") {
                let matchId = String(route.dropFirst("match_result/".count))
                MatchResultScreen(
                    matchId: matchId,
                    onBackClick: { navigationPath.removeLast() },
                    onBackHome: {
                        navigationPath = NavigationPath()
                    },
                    viewModel: matchViewModel
                )
            } else if route.hasPrefix("player_profile/") {
                let playerId = String(route.dropFirst("player_profile/".count))
                PlayerProfileDetailScreen(
                    playerId: playerId,
                    onBackClick: { navigationPath.removeLast() },
                    onRateClick: { id in navigationPath.append("rate_player/\(id)") },
                    viewModel: playerProfileViewModel
                )
            } else if route.hasPrefix("rate_player/") {
                let playerId = String(route.dropFirst("rate_player/".count))
                RatePlayerScreen(
                    playerId: playerId,
                    onBackClick: { navigationPath.removeLast() },
                    viewModel: playerProfileViewModel
                )
            } else {
                EmptyView()
            }
        }
    }
}
