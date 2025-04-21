//
//  UserViewModel.swift
//  Petty App
//
//  Created by Albert Eskef on 03.01.25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class UserViewModel: ObservableObject {
    @Published private(set) var user: FireUser?
    @Published private(set) var username: String?
    @Published var errorMessage: String?

    private let firebase = FirebaseService.shared

    var isUserLoggedIn: Bool {
        self.user != nil
    }

    init() {
        if let currentUser = self.firebase.auth.currentUser {
            self.fetchFirestoreUser(withId: currentUser.uid)
        }
    }

    func login(identifier: String, password: String) {
        if identifier.contains("@") {
            firebase.auth.signIn(withEmail: identifier, password: password) { authResult, error in
                if let error = error {
                    self.handleAuthError(error)
                    return
                }
                guard let authResult = authResult else {
                    self.errorMessage = "Unexpected error: No authentication result."
                    return
                }
                self.fetchFirestoreUser(withId: authResult.user.uid)
            }
        } else {
            firebase.database.collection("users").whereField("nickname", isEqualTo: identifier).getDocuments { querySnapshot, error in
                if let error = error {
                    self.errorMessage = "Error finding user by nickname: \(error.localizedDescription)"
                    return
                }
                guard let document = querySnapshot?.documents.first else {
                    self.errorMessage = "No user found with nickname '\(identifier)'."
                    return
                }
                let data = document.data()
                let email = data["email"] as? String ?? ""
                
                self.firebase.auth.signIn(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        self.handleAuthError(error)
                        return
                    }
                    guard let authResult = authResult else {
                        self.errorMessage = "Unexpected error: No authentication result."
                        return
                    }
                    self.fetchFirestoreUser(withId: authResult.user.uid)
                }
            }
        }
    }

    func signIn(email: String, password: String, nickname: String) {
        firebase.auth.createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.handleAuthError(error)
                return
            }
            guard let authResult = authResult else {
                self.errorMessage = "Unexpected error: No authentication result."
                return
            }
            self.createFirestoreUser(id: authResult.user.uid, email: email, nickname: nickname)
            self.fetchFirestoreUser(withId: authResult.user.uid)
        }
    }

    func logOut() {
        do {
            try firebase.auth.signOut()
            self.user = nil
        } catch {
            self.errorMessage = "Error during logout: \(error.localizedDescription)"
        }
    }

    private func handleAuthError(_ error: Error) {
        let nsError = error as NSError
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            errorMessage = "The password you entered is incorrect."
        case AuthErrorCode.userNotFound.rawValue:
            errorMessage = "No account found with this email or nickname."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            errorMessage = "The email is already associated with an existing account."
        case AuthErrorCode.invalidEmail.rawValue:
            errorMessage = "The email address is not valid."
        case AuthErrorCode.weakPassword.rawValue:
            errorMessage = "The password must be at least 6 characters long."
        default:
            errorMessage = error.localizedDescription
        }
    }

    private func createFirestoreUser(id: String, email: String, nickname: String) {
        let newFireUser = FireUser(id: id, email: email, nickname: nickname, registeredAt: Date())
        do {
            try firebase.database.collection("users").document(id).setData(from: newFireUser)
        } catch {
            errorMessage = "Error saving user in Firestore: \(error.localizedDescription)"
        }
    }

    func fetchFirestoreUser(withId id: String) {
        self.firebase.database.collection("users").document(id).getDocument { document, error in
            if let error {
                self.errorMessage = "Error fetching user: \(error.localizedDescription)"
                return
            }
            guard let document else {
                self.errorMessage = "User document does not exist."
                return
            }
            do {
                let user = try document.data(as: FireUser.self)
                self.user = user
            } catch {
                self.errorMessage = "Error decoding user data: \(error.localizedDescription)"
            }
        }
    }
    
    func updateProfileImageUrl(_ url: String, completion: @escaping () -> Void) {
        guard let userId = user?.id else { return }
        FirebaseService.shared.database.collection("users").document(userId).updateData([
            "profileImageUrl": url
        ]) { error in
            if let error = error {
                print("Failed to update profile image URL: \(error.localizedDescription)")
            } else {
                self.user?.profileImageUrl = url
                completion()
            }
        }
    }
    
    func updateBio(_ bio: String) {
        guard let userId = user?.id else { return }

        firebase.database.collection("users")
            .document(userId)
            .updateData(["bio": bio]) { error in
                if let error = error {
                    print("Error updating bio: \(error.localizedDescription)")
                } else {
                    self.user?.bio = bio
                }
            }
    }
    
    func updateNickname(_ newNickname: String) {
        guard let userId = user?.id else {
            print("Error: User ID is nil.")
            return
        }

        firebase.database.collection("users")
            .document(userId)
            .updateData(["nickname": newNickname]) { error in
                if let error = error {
                    print("Error updating nickname: \(error.localizedDescription)")
                } else {
                    self.user?.nickname = newNickname
                    print("Nickname updated successfully.")
                }
            }
    }
}
