//
//  FirebaseService.swift
//  Petty App
//
//  Created by Albert Eskef on 03.01.25.
//

import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class FirebaseService {
    static let shared = FirebaseService()
    private init() {}

    let auth = Auth.auth()
    let database = Firestore.firestore()
    let storage = Storage.storage()

    var userID: String? {
        auth.currentUser?.uid
    }

    func uploadImage(_ image: UIImage, path: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(.failure(NSError(domain: "Invalid Image", code: -1, userInfo: nil)))
            return
        }

        let storageRef = storage.reference().child(path)

        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                } else if let url = url {
                    completion(.success(url.absoluteString))
                }
            }
        }
    }
}
