import SwiftUI

struct MemberManagementScreen: View {
    let onBackClick: () -> Void
    @ObservedObject var viewModel: AdminViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: onBackClick) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppTheme.PremiumDark)
                        .font(.system(size: 16, weight: .bold))
                }
                Spacer()
                Text("Member Management")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.PremiumDark)
                Spacer()
                Spacer().frame(width: 24)
            }
            .padding()
            .background(Color.white)

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppTheme.KineticGreen))
                Spacer()
            } else {
                List(viewModel.members) { member in
                    MemberItemRow(
                        member: member,
                        onRoleToggle: {
                            let nextRole = member.role == "admin" ? "member" : "admin"
                            viewModel.changeMemberRole(memberId: member.id, newRole: nextRole)
                        },
                        onBlockToggle: {
                            viewModel.toggleBlockMember(memberId: member.id)
                        }
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

struct MemberItemRow: View {
    let member: MemberItem
    let onRoleToggle: () -> Void
    let onBlockToggle: () -> Void

    var body: some View {
        let isAdmin = member.role == "admin"
        let badgeColor = isAdmin ? AppTheme.KineticGreen : Color.gray

        HStack(spacing: 14) {
            Image(systemName: isAdmin ? "shield.fill" : "person.fill")
                .font(.system(size: 20))
                .foregroundColor(badgeColor)
                .frame(width: 44, height: 44)
                .background(badgeColor.opacity(0.08))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(member.fullName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                    if member.isBlocked {
                        Text("BLOCKED")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(AppTheme.ErrorRed)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.ErrorRed.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                Text("@\(member.username) • \(member.skillLevel)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Button(action: onRoleToggle) {
                    Text(isAdmin ? "Demote" : "Promote")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.KineticGreen)
                }
                
                Button(action: onBlockToggle) {
                    Text(member.isBlocked ? "Unblock" : "Block")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(member.isBlocked ? AppTheme.KineticGreen : AppTheme.ErrorRed)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.vertical, 4)
    }
}
