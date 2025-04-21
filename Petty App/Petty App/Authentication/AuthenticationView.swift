//
//  AuthenticationView.swift
//  Petty App
//
//  Created by Albert Eskef on 05.01.25.
//

import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    @State private var identifier: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var nickname: String = ""
    @State private var isRegistering: Bool = true
    @EnvironmentObject var userViewModel: UserViewModel

    var body: some View {
        ZStack {
            BackgroundView() 

            VStack {
                Spacer()

                Image("Petty")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .padding(.bottom, 20)

                VStack(spacing: 15) {
                    if let errorMessage = userViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .multilineTextAlignment(.center)
                    }

                    if isRegistering {
                        TextField("Nickname", text: $nickname)
                            .modifier(FormFieldStyle())
                    }

                    TextField(
                        isRegistering ? "Email" : "Email or Nickname",
                        text: $identifier
                    )
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .modifier(FormFieldStyle())

                    SecureField("Password", text: $password)
                        .modifier(FormFieldStyle())

                    if isRegistering {
                        SecureField("Confirm Password", text: $confirmPassword)
                            .modifier(FormFieldStyle())
                    }

                    Button(action: handleSubmit) {
                        Text(isRegistering ? "Register" : "Login")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.customBackgroundColor1.opacity(0.9),
                                        Color.customBackgroundColor1
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 4)
                    }
                    .padding(.top, 5)
                    .padding(.horizontal, 20)

                    Button(action: {
                        withAnimation {
                            isRegistering.toggle()
                            userViewModel.errorMessage = nil
                        }
                    }) {
                        Text(isRegistering
                             ? "Already registered? Login"
                             : "Not registered yet? Register")
                            .font(.subheadline)
                            .foregroundColor(.customBackgroundColor1)
                    }
                    .padding(.bottom, 5)
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                .background(
                    Color.white.opacity(0.9)
                        .cornerRadius(15)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 30)

                Spacer()
            }
        }
    }

    private func handleSubmit() {
        withAnimation {
            if isRegistering {
                guard !nickname.isEmpty else {
                    userViewModel.errorMessage = "Nickname cannot be empty."
                    return
                }
                guard !identifier.isEmpty else {
                    userViewModel.errorMessage = "Email cannot be empty."
                    return
                }
                guard !password.isEmpty else {
                    userViewModel.errorMessage = "Password cannot be empty."
                    return
                }
                guard password == confirmPassword else {
                    userViewModel.errorMessage = "Passwords do not match."
                    return
                }
                userViewModel.signIn(email: identifier, password: password, nickname: nickname)
            } else {
                userViewModel.login(identifier: identifier, password: password)
            }
        }
    }
}


fileprivate struct FormFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
            .padding(.horizontal, 20)
    }
}

extension Color {
    static let customBackgroundColor1 = Color(
        red: 110/255,
        green: 139/255,
        blue: 252/255
    )
    static let customBackgroundColor2 = Color(
        red: 131/255,
        green: 238/255,
        blue: 252/255
    )
    static let customBackgroundColor3 = Color(
        red: 116/255,
        green: 165/255,
        blue: 252/255
    )
}
