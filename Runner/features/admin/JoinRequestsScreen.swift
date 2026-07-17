import SwiftUI

struct JoinRequestsScreen: View {
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
                Text("Join Requests")
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
                if viewModel.requests.isEmpty {
                    Spacer()
                    Text("No pending join requests")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(viewModel.requests) { request in
                        JoinRequestRow(
                            request: request,
                            onApprove: { viewModel.approveRequest(requestId: request.id) },
                            onReject: { viewModel.rejectRequest(requestId: request.id) }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
    }
}

struct JoinRequestRow: View {
    let request: JoinRequestItem
    let onApprove: () -> Void
    let onReject: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.fullName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(AppTheme.PremiumDark)
                    Text("@\(request.username) • Level: \(request.skillLevel)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()

                HStack(spacing: 8) {
                    Button(action: onReject) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.ErrorRed)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.ErrorRed.opacity(0.08))
                            .clipShape(Circle())
                    }
                    
                    Button(action: onApprove) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.KineticGreen)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.KineticGreen.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
            }

            Text("\"\(request.message)\"")
                .font(.system(size: 13, weight: .regular))
                .italic()
                .foregroundColor(.gray)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.SoftGray)
                .cornerRadius(8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.vertical, 4)
    }
}
