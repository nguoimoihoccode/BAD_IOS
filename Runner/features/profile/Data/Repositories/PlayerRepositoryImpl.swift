import Foundation

final class PlayerRepositoryImpl: PlayerRepository {
    private var mockProfiles: [PlayerProfile] = [
        PlayerProfile(
            id: "m1",
            fullName: "Trần Nguyễn Tiến",
            username: "tientran",
            avatarUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80",
            skillLevel: "Advanced",
            bio: "Đam mê cầu lông, thích giao lưu nâng cao trình độ. Rất mong được cọ xát với các bạn!",
            matchesPlayed: 42,
            wins: 35,
            losses: 7,
            fairPlayRating: 4.8,
            skillRating: 4.7,
            email: "tientran@gmail.com",
            phone: "0901234567"
        ),
        PlayerProfile(
            id: "m2",
            fullName: "Nguyễn Thức Phúc",
            username: "phucnguyen",
            avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=150&q=80",
            skillLevel: "Advanced",
            bio: "Thích đánh đôi nam và đôi nam nữ. Hay ra sân vào các buổi tối thứ 2, 4, 6.",
            matchesPlayed: 38,
            wins: 28,
            losses: 10,
            fairPlayRating: 4.9,
            skillRating: 4.6,
            email: "phucnguyen@gmail.com",
            phone: "0912345678"
        ),
        PlayerProfile(
            id: "m3",
            fullName: "Lê Hoài Nam",
            username: "namle",
            avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=150&q=80",
            skillLevel: "Intermediate",
            bio: "Chơi vui là chính, rèn luyện sức khoẻ là mười. Đánh đôi hay đơn đều chơi được tuốt!",
            matchesPlayed: 25,
            wins: 15,
            losses: 10,
            fairPlayRating: 4.7,
            skillRating: 3.8,
            email: "namle@gmail.com",
            phone: "0987654321"
        ),
        PlayerProfile(
            id: "m4",
            fullName: "Phạm Minh Trí",
            username: "tripham",
            avatarUrl: "https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=150&q=80",
            skillLevel: "Beginner",
            bio: "Mới gia nhập câu lạc bộ. Rất mong được các anh chị đi trước chỉ bảo thêm.",
            matchesPlayed: 12,
            wins: 4,
            losses: 8,
            fairPlayRating: 4.5,
            skillRating: 2.5,
            email: "tripham@gmail.com",
            phone: "0934567890"
        ),
    ]

    func getPlayerProfile(playerId: String) async -> Result<PlayerProfile, Error> {
        try? await Task.sleep(nanoseconds: 400_000_000)
        let profile = mockProfiles.first(where: { $0.id == playerId }) ?? mockProfiles[0]
        return .success(profile)
    }

    func ratePlayer(playerId: String, skillRating: Double, fairPlayRating: Double) async -> Result<Void, Error> {
        try? await Task.sleep(nanoseconds: 300_000_000)
        if let index = mockProfiles.firstIndex(where: { $0.id == playerId }) {
            let p = mockProfiles[index]
            let newSkill = ((p.skillRating * 4) + skillRating) / 5
            let newFair = ((p.fairPlayRating * 4) + fairPlayRating) / 5
            mockProfiles[index] = PlayerProfile(
                id: p.id,
                fullName: p.fullName,
                username: p.username,
                avatarUrl: p.avatarUrl,
                skillLevel: p.skillLevel,
                bio: p.bio,
                matchesPlayed: p.matchesPlayed,
                wins: p.wins,
                losses: p.losses,
                fairPlayRating: (newFair * 10).rounded() / 10,
                skillRating: (newSkill * 10).rounded() / 10,
                email: p.email,
                phone: p.phone
            )
        }
        return .success(())
    }

    func getLeaderboard() async -> Result<[PlayerProfile], Error> {
        try? await Task.sleep(nanoseconds: 500_000_000)
        let list = mockProfiles.sorted { $0.wins > $1.wins }
        return .success(list)
    }
}
