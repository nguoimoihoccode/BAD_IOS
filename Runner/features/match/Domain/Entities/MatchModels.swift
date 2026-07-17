import Foundation

struct ScoreSet: Identifiable, Hashable {
    var id: String { "\(p1)-\(p2)" }
    let p1: Int
    let p2: Int
}

struct MatchItem: Identifiable, Equatable {
    let id: String
    let player1Name: String
    let player2Name: String
    let player1Avatar: String?
    let player2Avatar: String?
    var setScores: [ScoreSet]
    let date: Date
    let courtName: String
    var isCompleted: Bool

    func copyWith(setScores: [ScoreSet]? = nil, isCompleted: Bool? = nil) -> MatchItem {
        MatchItem(
            id: id,
            player1Name: player1Name,
            player2Name: player2Name,
            player1Avatar: player1Avatar,
            player2Avatar: player2Avatar,
            setScores: setScores ?? self.setScores,
            date: date,
            courtName: courtName,
            isCompleted: isCompleted ?? self.isCompleted
        )
    }
}

struct OpponentCandidate: Identifiable, Hashable {
    let id: String
    let fullName: String
    let username: String
    let avatarUrl: String?
    let skillLevel: String
    let compatibilityScore: Int
}
