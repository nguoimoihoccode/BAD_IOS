import SwiftUI

struct RegisterScreen: View {
    let onBackClick: () -> Void
    let onRegisterSuccess: () -> Void
    @ObservedObject var viewModel: AuthViewModel

    @State private var email = ""
    @State private var username = ""
    @State private var fullName = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            AppTheme.PremiumDark
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    Button(action: onBackClick) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .bold))
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create Account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("Join the community, participate in matchmaking events.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
                
                VStack(spacing: 16) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .textInputAutocapitalization(.none)
                    
                    TextField("Full Name", text: $fullName)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(AppTheme.ErrorRed)
                        .font(.system(size: 13, weight: .semibold))
                        .padding(.horizontal, 24)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.register(
                        email: email,
                        username: username,
                        password: password,
                        fullName: fullName.isEmpty ? nil : fullName,
                        onSuccess: onRegisterSuccess
                    )
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Sign Up")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(AppTheme.KineticGreen)
                    .cornerRadius(8)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
