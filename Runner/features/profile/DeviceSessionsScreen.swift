import SwiftUI

struct DeviceSessionsScreen: View {
    let onBackClick: () -> Void
    @ObservedObject var viewModel: AuthViewModel

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
                Text("Device Sessions")
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
                List(viewModel.deviceSessions) { device in
                    HStack {
                        Image(systemName: "laptopcomputer.and.iphone")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.KineticGreen)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.KineticGreen.opacity(0.08))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(device.deviceName)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AppTheme.PremiumDark)
                                if device.isCurrent {
                                    Text("THIS DEVICE")
                                        .font(.system(size: 8, weight: .bold))
                                        .foregroundColor(AppTheme.KineticGreen)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(AppTheme.KineticGreen.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                            Text(device.lastActive)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 8)
                        
                        Spacer()
                        
                        if !device.isCurrent {
                            Button(action: {
                                viewModel.deleteDevice(id: device.id)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(AppTheme.ErrorRed)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .listRowBackground(Color.white)
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(AppTheme.SoftGray.ignoresSafeArea())
        .onAppear {
            viewModel.loadDeviceSessions()
        }
        .navigationBarBackButtonHidden(true)
    }
}
