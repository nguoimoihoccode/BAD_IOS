import Foundation

class SessionRepositoryImpl: SessionRepository {
    
    struct ParticipantDTO: Codable {
        let name: String
        let level: String
        let avatar_url: String?
        let is_host: Bool
        
        func toDomain() -> SessionParticipant {
            return SessionParticipant(
                id: name,
                name: name,
                avatarUrl: avatar_url,
                level: level,
                isHost: is_host
            )
        }
    }
    
    struct FeeDTO: Codable {
        let court_fee: Double
        let shuttlecock_fee: Double
        let total_fee: Double
    }
    
    struct SessionDTO: Codable {
        let id: String
        let title: String
        let date: String
        let time: String
        let duration: String
        let location: String
        let joined: Bool
        let max_participants: Int
        let participants: [ParticipantDTO]
        let fee: FeeDTO
        let payment_status: String?
        
        func toDomain() -> Session {
            return Session(
                id: id,
                title: title,
                date: date,
                time: time,
                location: location,
                duration: duration,
                maxParticipants: max_participants,
                courtFee: fee.court_fee,
                shuttlecockFee: fee.shuttlecock_fee,
                totalFee: fee.total_fee,
                participants: participants.map { $0.toDomain() },
                isJoined: joined,
                paymentStatus: payment_status ?? "UNPAID"
            )
        }
    }
    
    struct SessionListDTO: Codable {
        let results: [SessionDTO]
    }

    func getUpcomingSessions() async -> Result<[Session], Error> {
        let res: Result<SessionListDTO, Error> = await APIClient.shared.request(path: "/sessions?status=upcoming", method: "GET")
        
        switch res {
        case .success(let list):
            return .success(list.results.map { $0.toDomain() })
        case .failure(let error):
            return .failure(error)
        }
    }

    func getPastSessions() async -> Result<[Session], Error> {
        let res: Result<SessionListDTO, Error> = await APIClient.shared.request(path: "/sessions?status=past", method: "GET")
        
        switch res {
        case .success(let list):
            return .success(list.results.map { $0.toDomain() })
        case .failure(let error):
            return .failure(error)
        }
    }

    func getSessionDetails(id: String) async -> Result<Session, Error> {
        let res: Result<SessionDTO, Error> = await APIClient.shared.request(path: "/sessions/\(id)", method: "GET")
        
        switch res {
        case .success(let detail):
            return .success(detail.toDomain())
        case .failure(let error):
            return .failure(error)
        }
    }

    func joinSession(id: String) async -> Result<Void, Error> {
        let res: Result<SessionDTO, Error> = await APIClient.shared.request(path: "/sessions/\(id)/join", method: "POST")
        
        switch res {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }

    func leaveSession(id: String) async -> Result<Void, Error> {
        let res: Result<SessionDTO, Error> = await APIClient.shared.request(path: "/sessions/\(id)/leave", method: "POST")
        
        switch res {
        case .success:
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}
