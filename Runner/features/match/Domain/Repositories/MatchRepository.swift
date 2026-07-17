import Foundation

protocol MatchRepository {
    func findMatchmakingOpponents() async -> Result<[OpponentCandidate], Error>
    func createMatch(opponentId: String, courtName: String, date: Date) async -> Result<MatchItem, Error>
    func enterMatchScore(matchId: String, setScores: [ScoreSet]) async -> Result<Void, Error>
    func getMatchDetail(matchId: String) async -> Result<MatchItem, Error>
    func getScheduledMatches() async -> Result<[MatchItem], Error>
    func getCompletedMatches() async -> Result<[MatchItem], Error>
}
