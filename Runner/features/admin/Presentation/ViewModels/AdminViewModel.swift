import Foundation
import Combine

@MainActor
class AdminViewModel: ObservableObject {
    @Published var members: [MemberItem] = []
    @Published var requests: [JoinRequestItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    private let repository: AdminRepository

    init(repository: AdminRepository = ServiceLocator.shared.adminRepository) {
        self.repository = repository
        loadAdminData()
    }

    func loadAdminData() {
        isLoading = true
        errorMessage = nil
        Task {
            let resMembers = await repository.getMembers()
            let resRequests = await repository.getJoinRequests()
            isLoading = false
            
            if case .success(let memberList) = resMembers, case .success(let reqList) = resRequests {
                self.members = memberList
                self.requests = reqList
            } else {
                self.errorMessage = "Failed to load admin controls"
            }
        }
    }

    func approveRequest(requestId: String) {
        Task {
            let _ = await repository.approveRequest(requestId: requestId)
            loadAdminData()
        }
    }

    func rejectRequest(requestId: String) {
        Task {
            let _ = await repository.rejectRequest(requestId: requestId)
            loadAdminData()
        }
    }

    func changeMemberRole(memberId: String, newRole: String) {
        Task {
            let _ = await repository.changeMemberRole(memberId: memberId, newRole: newRole)
            loadAdminData()
        }
    }

    func toggleBlockMember(memberId: String) {
        Task {
            let _ = await repository.toggleBlockMember(memberId: memberId)
            loadAdminData()
        }
    }
}
