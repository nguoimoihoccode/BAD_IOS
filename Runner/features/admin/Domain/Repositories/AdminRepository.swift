import Foundation

protocol AdminRepository {
    func getMembers() async -> Result<[MemberItem], Error>
    func getJoinRequests() async -> Result<[JoinRequestItem], Error>
    func approveRequest(requestId: String) async -> Result<Void, Error>
    func rejectRequest(requestId: String) async -> Result<Void, Error>
    func changeMemberRole(memberId: String, newRole: String) async -> Result<Void, Error>
    func toggleBlockMember(memberId: String) async -> Result<Void, Error>
}
