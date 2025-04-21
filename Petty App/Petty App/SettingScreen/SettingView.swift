//
//  SettingView.swift
//  Petty App
//
//  Created by Albert Eskef on 08.01.25.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @State private var showLogoutConfirmation = false
    @State private var showNicknameUpdateAlert = false
    @State private var newNickname: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    accountSection
                    preferencesSection
                    aboutSection
                    logoutButton
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .background(BackgroundView())
            .navigationBarTitle("Settings", displayMode: .inline)
            .alert("Update Nickname", isPresented: $showNicknameUpdateAlert, actions: {
                TextField("Enter new nickname", text: $newNickname)
                Button("Confirm") {
                    Task {
                        userViewModel.updateNickname(newNickname)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            showRestartAlert()
                        }
                    }
                }
                Button("Cancel", role: .cancel) {}
            }, message: {
                Text("Enter your new nickname below.")
            })
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        userViewModel.logOut()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private var accountSection: some View {
        VStack(spacing: 8) {
            SettingsRow(
                icon: "person.fill",
                title: "Nickname",
                detail: userViewModel.user?.nickname ?? "Unknown",
                isEditable: true
            ) {
                newNickname = userViewModel.user?.nickname ?? ""
                showNicknameUpdateAlert = true
            }

            SettingsRow(
                icon: "envelope.fill",
                title: "Email",
                detail: userViewModel.user?.email ?? "Unknown",
                isEditable: false
            )
        }
        .settingsSection(title: "Account")
    }

    private var preferencesSection: some View {
        VStack(spacing: 8) {
            ToggleRow(icon: "bell.fill", title: "Push Notifications", isOn: .constant(true))
            ToggleRow(icon: "moon.fill", title: "Dark Mode", isOn: .constant(false))
        }
        .settingsSection(title: "Preferences")
    }

    private var aboutSection: some View {
        VStack(spacing: 8) {
            NavigationLink(destination: AboutUsView()) {
                SettingsRow(icon: "info.circle.fill", title: "About Us")
            }
        }
        .settingsSection(title: "About")
    }

    private var logoutButton: some View {
        Button(action: {
            showLogoutConfirmation = true
        }) {
            Text("Log Out")
                .font(.headline)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.red.opacity(0.1))
                )
        }
        .padding(.top, 10)
    }

    private func showRestartAlert() {
        let alert = UIAlertController(
            title: "Restart Required",
            message: "The app needs to be restarted for the changes to take effect.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Restart Now", style: .destructive, handler: { _ in
            exit(0)
        }))
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            rootVC.present(alert, animated: true)
        }
    }
}

extension View {
    func settingsSection(title: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.horizontal)

            self
        }
    }
}
