import Foundation

struct PlayerProfile: Identifiable, Equatable {
    let id: String
    let fullName: String
    let username: String
    let avatarUrl: String?
    let skillLevel: String
    let bio: String
    let matchesPlayed: Int
    let wins: Int
    let losses: Int
    let fairPlayRating: Double
    let skillRating: Double
    let email: String
    let phone: String

    var winRate: Int {
        guard matchesPlayed > 0 else { return 0 }
        return Int((Double(wins) / Double(matchesPlayed)) * 100)
    }
}
