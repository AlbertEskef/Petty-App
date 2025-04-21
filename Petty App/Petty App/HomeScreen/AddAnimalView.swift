//
//  AddAnimalView.swift
//  Petty App
//
//  Created by Albert Eskef on 08.01.25.
//

import SwiftUI

struct AddAnimalView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name: String = ""
    @State private var species: String = ""
    @State private var gender: String = "Male"
    @State private var weight: String = ""
    @State private var birthday: Date = Date()
    @State private var selectedImage: UIImage? = nil
    @State private var insuranceProvider: String = ""
    @State private var policyNumber: String = ""
    @State private var isUploading = false
    @State private var isImagePickerPresented = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BackgroundView()
                
                Form {
                    Section(header: Text("Basic Info")) {
                        TextField("Nickname", text: $name)
                        Picker("Species", selection: $species) {
                            ForEach(viewModel.speciesList.map { $0.species }, id: \.self) { species in
                                Text(species).tag(species)
                            }
                        }
                        Picker("Gender", selection: $gender) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                        }
                        TextField("Weight (kg)", text: $weight)
                            .keyboardType(.decimalPad)
                        
                        DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                    
                    Section(header: Text("Image")) {
                        if let selectedImage = selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            Text("No image selected")
                                .foregroundColor(.gray)
                        }
                        
                        Button("Select Image") {
                            isImagePickerPresented = true
                        }
                        .sheet(isPresented: $isImagePickerPresented) {
                            ImagePicker(selectedImage: $selectedImage)
                        }
                    }
                    
                    Section(header: Text("Insurance")) {
                        TextField("Provider", text: $insuranceProvider)
                        TextField("Policy Number", text: $policyNumber)
                            .keyboardType(.numberPad)
                        
                    }
                    
                    Button(action: saveAnimal) {
                        if isUploading {
                            ProgressView()
                        } else {
                            Text("Save Animal")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .foregroundColor(.white)
                    .background(isUploading ? Color.gray : Color.blue)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                    .disabled(isUploading)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Animal")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func saveAnimal() {
        guard !name.isEmpty, let selectedImage = selectedImage else {
            print("Name and Image are required!")
            return
        }
        
        isUploading = true
        let speciesToSave = species.isEmpty ? (viewModel.speciesList.first?.species ?? "Unknown") : species
        
        FirebaseService.shared.uploadImage(selectedImage, path: "animals/\(UUID().uuidString).jpg") { result in
            switch result {
            case .success(let imageUrl):
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let formattedBirthday = dateFormatter.string(from: birthday)
                
                let newAnimal = Animal(
                    name: name,
                    species: speciesToSave,
                    gender: gender,
                    weight: Double(weight),
                    birthday: formattedBirthday,
                    imageUrl: imageUrl,
                    insuranceProvider: insuranceProvider.isEmpty ? "None provided" : insuranceProvider,
                    policyNumber: policyNumber.isEmpty ? "None provided" : policyNumber,
                    email: userViewModel.user?.email ?? "unknown@example.com"
                )
                viewModel.saveNewAnimal(animal: newAnimal) { saveResult in
                    isUploading = false
                    switch saveResult {
                    case .success:
                        presentationMode.wrappedValue.dismiss()
                    case .failure(let error):
                        print("Error saving animal: \(error.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                isUploading = false
                print("Error uploading image: \(error.localizedDescription)")
            }
        }
    }
}
