import Foundation

protocol SessionRepository {
    func getUpcomingSessions() async -> Result<[Session], Error>
    func getPastSessions() async -> Result<[Session], Error>
    func getSessionDetails(id: String) async -> Result<Session, Error>
    func joinSession(id: String) async -> Result<Void, Error>
    func leaveSession(id: String) async -> Result<Void, Error>
}
