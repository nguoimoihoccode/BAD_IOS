import Foundation

class ServiceLocator {
    static let shared = ServiceLocator()
    
    private init() {}
    
    lazy var authRepository: AuthRepository = AuthRepositoryImpl()
    lazy var sessionRepository: SessionRepository = SessionRepositoryImpl()
    lazy var paymentRepository: PaymentRepository = PaymentRepositoryImpl()
    lazy var communityRepository: CommunityRepository = CommunityRepositoryImpl()
    lazy var matchRepository: MatchRepository = MatchRepositoryImpl()
    lazy var notificationRepository: NotificationRepository = NotificationRepositoryImpl()
    lazy var adminRepository: AdminRepository = AdminRepositoryImpl()
    lazy var playerRepository: PlayerRepository = PlayerRepositoryImpl()
}
