import Foundation

class AdminRepositoryImpl: AdminRepository {
    private var members = [
        MemberItem(id: "m1", fullName: "Trần Nguyễn Tiến", username: "tientran", avatarUrl: nil, role: "admin", skillLevel: "Advanced", isBlocked: false),
        MemberItem(id: "m2", fullName: "Nguyễn Thức Phúc", username: "phucnguyen", avatarUrl: nil, role: "admin", skillLevel: "Advanced", isBlocked: false),
        MemberItem(id: "m3", fullName: "Lê Hoài Nam", username: "namle", avatarUrl: nil, role: "member", skillLevel: "Intermediate", isBlocked: false),
        MemberItem(id: "m4", fullName: "Phạm Minh Trí", username: "tripham", avatarUrl: nil, role: "member", skillLevel: "Beginner", isBlocked: false),
        MemberItem(id: "m5", fullName: "Hoàng Kim Chi", username: "chinhoang", avatarUrl: nil, role: "member", skillLevel: "Intermediate", isBlocked: true)
    ]

    private var requests = [
        JoinRequestItem(id: "r1", fullName: "Đặng Tuấn Anh", username: "anhdang", avatarUrl: nil, skillLevel: "Advanced", message: "Xin chào, mình đánh được 3 năm rồi, muốn tìm nhóm giao lưu nâng cao trình độ vào cuối tuần!", requestedAt: Date(timeIntervalSinceNow: -10800)),
        JoinRequestItem(id: "r2", fullName: "Vũ Thu Trang", username: "trangvu", avatarUrl: nil, skillLevel: "Beginner", message: "Mình mới tập chơi được 3 tháng, muốn tìm nhóm vui vẻ để rèn luyện sức khoẻ ạ.", requestedAt: Date(timeIntervalSinceNow: -172800))
    ]

    func getMembers() async -> Result<[MemberItem], Error> { return .success(members) }
    func getJoinRequests() async -> Result<[JoinRequestItem], Error> { return .success(requests) }

    func approveRequest(requestId: String) async -> Result<Void, Error> {
        if let idx = requests.firstIndex(where: { $0.id == requestId }) {
            let req = requests.remove(at: idx)
            members.append(MemberItem(id: "m-\(Date().timeIntervalSince1970)", fullName: req.fullName, username: req.username, avatarUrl: nil, role: "member", skillLevel: req.skillLevel, isBlocked: false))
        }
        return .success(())
    }

    func rejectRequest(requestId: String) async -> Result<Void, Error> {
        requests.removeAll { $0.id == requestId }
        return .success(())
    }

    func changeMemberRole(memberId: String, newRole: String) async -> Result<Void, Error> {
        if let idx = members.firstIndex(where: { $0.id == memberId }) {
            members[idx].role = newRole
        }
        return .success(())
    }

    func toggleBlockMember(memberId: String) async -> Result<Void, Error> {
        if let idx = members.firstIndex(where: { $0.id == memberId }) {
            members[idx].isBlocked.toggle()
        }
        return .success(())
    }
}
