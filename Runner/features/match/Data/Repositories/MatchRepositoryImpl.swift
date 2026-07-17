import Foundation

class MatchRepositoryImpl: MatchRepository {
    private let mockOpponents: [OpponentCandidate] = [
        OpponentCandidate(
            id: "m1",
            fullName: "Trần Nguyễn Tiến",
            username: "tientran",
            avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80",
            skillLevel: "Advanced",
            compatibilityScore: 98
        ),
        OpponentCandidate(
            id: "m3",
            fullName: "Lê Hoài Nam",
            username: "namle",
            avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80",
            skillLevel: "Intermediate",
            compatibilityScore: 85
        ),
        OpponentCandidate(
            id: "m4",
            fullName: "Phạm Minh Trí",
            username: "tripham",
            avatarUrl: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80",
            skillLevel: "Beginner",
            compatibilityScore: 60
        ),
    ]

    private var matches: [MatchItem] = [
        MatchItem(
            id: "match_init",
            player1Name: "Nguyễn Thức Phúc",
            player2Name: "Trần Nguyễn Tiến",
            player1Avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80",
            player2Avatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80",
            setScores: [
                ScoreSet(p1: 21, p2: 18),
                ScoreSet(p1: 15, p2: 21),
                ScoreSet(p1: 21, p2: 19),
            ],
            date: Date().addingTimeInterval(-24 * 60 * 60),
            courtName: "City Arena • Court 2",
            isCompleted: true
        ),
    ]

    func findMatchmakingOpponents() async -> Result<[OpponentCandidate], Error> {
        try? await Task.sleep(nanoseconds: 600_000_000)
        return .success(mockOpponents)
    }

    func createMatch(opponentId: String, courtName: String, date: Date) async -> Result<MatchItem, Error> {
        try? await Task.sleep(nanoseconds: 500_000_000)
        guard let opp = mockOpponents.first(where: { $0.id == opponentId }) else {
            return .failure(NSError(domain: "Match", code: 404, userInfo: [NSLocalizedDescriptionKey: "Opponent not found."]))
        }

        let newMatch = MatchItem(
            id: "match_\(Int(Date().timeIntervalSince1970 * 1000))",
            player1Name: "Nguyễn Thức Phúc",
            player2Name: opp.fullName,
            player1Avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80",
            player2Avatar: opp.avatarUrl,
            setScores: [],
            date: date,
            courtName: courtName,
            isCompleted: false
        )
        matches.append(newMatch)
        return .success(newMatch)
    }

    func enterMatchScore(matchId: String, setScores: [ScoreSet]) async -> Result<Void, Error> {
        try? await Task.sleep(nanoseconds: 400_000_000)
        guard let index = matches.firstIndex(where: { $0.id == matchId }) else {
            return .failure(NSError(domain: "Match", code: 404, userInfo: [NSLocalizedDescriptionKey: "Match not found."]))
        }
        matches[index] = matches[index].copyWith(setScores: setScores, isCompleted: true)
        return .success(())
    }

    func getMatchDetail(matchId: String) async -> Result<MatchItem, Error> {
        try? await Task.sleep(nanoseconds: 300_000_000)
        let match = matches.first(where: { $0.id == matchId }) ?? matches.first!
        return .success(match)
    }

    func getScheduledMatches() async -> Result<[MatchItem], Error> {
        try? await Task.sleep(nanoseconds: 200_000_000)
        return .success(matches.filter { !$0.isCompleted })
    }

    func getCompletedMatches() async -> Result<[MatchItem], Error> {
        try? await Task.sleep(nanoseconds: 200_000_000)
        return .success(matches.filter { $0.isCompleted })
    }
}
