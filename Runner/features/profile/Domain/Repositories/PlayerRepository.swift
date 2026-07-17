import Foundation

protocol PlayerRepository {
    func getPlayerProfile(playerId: String) async -> Result<PlayerProfile, Error>
    func ratePlayer(playerId: String, skillRating: Double, fairPlayRating: Double) async -> Result<Void, Error>
    func getLeaderboard() async -> Result<[PlayerProfile], Error>
}
