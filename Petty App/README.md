# Petty App


**Petty App** is a community-driven iOS application designed to help pet lovers connect, discover pets up for adoption, and share knowledge about pet care.
Built with SwiftUI and Firebase, Petty App offers an intuitive interface, real-time messaging, and a variety of features for pet owners and adopters alike..

## **Overview**
Petty App provides a platform where users can:

- Explore a home feed of animals available for adoption.
- Chat with other pet owners or prospective adopters.
- Mark animals as favorites for quick reference later.
- Manage their own pet profiles (with photos, insurance info, etc.).
- Edit their personal profile (nickname, bio, and profile picture).

By bringing together pet owners and adopters, Petty App aims to streamline the adoption process and foster a friendly pet-focused community.


## **Features**

### **Authentication**
- Users can register or log in using email and password, or by nickname.
- Custom error messages for invalid credentials.

### Home View
- Browse animals by species category.
- Search for animals by name.
- Add a new animal (with image upload, insurance details, etc.).
  
### Chat
- Real-time messaging using Firestore listeners.
- Organized chat list with last message and timestamp.
- Directly initiate a chat from an animal’s detail page.
  
### Favorites
- Mark animals as favorites to quickly access them later.
- Automatically detects invalid or removed pets.
  
### Profile Management
- Change your nickname, bio, and profile picture.
- Access an owner’s public profile from their animal’s page.
  
### Settings
- Update nickname, push notifications toggle, dark mode toggle, and more.
- Quick log-out feature.
  
### Splash Screen
- Displays app branding while data and services load in the background.


## **Tech Stack**

### SwiftUI
- For building modern, reactive UIs with a declarative approach.
  
### Firebase
- **Auth** for user sign-in and registration.
- **Firestore** for real-time database storage.
- **Storage** for image uploads.

### **Swift Concurrency** (async/await) for clean Firestore interactions.
### **Xcode** for iOS development (latest version recommended).


	•	Petty App/
	•	├─ App/
	•	│  ├─ Petty_AppApp.swift          # Main entry point; handles Splash logic & app lifecycle
	•	│  ├─ AppDelegate.swift           # Firebase initialization
	•	│  └─ ...
	•	├─ Models/
	•	│  ├─ Animal.swift                # Animal data model
	•	│  ├─ Chat.swift                  # Chat data model
	•	│  ├─ Message.swift               # Message data model
	•	│  ├─ FireUser.swift              # User data model
	•	│  └─ ...
	•	├─ ViewModels/
	•	│  ├─ HomeViewModel.swift
	•	│  ├─ UserViewModel.swift
	•	│  ├─ ChatViewModel.swift
	•	│  ├─ FavoriteViewModel.swift
	•	│  └─ ...
	•	├─ Views/
	•	│  ├─ HomeView.swift
	•	│  ├─ DetailView.swift
	•	│  ├─ ChatView.swift
	•	│  ├─ ChatListView.swift
	•	│  ├─ FavoriteView.swift
	•	│  ├─ ProfileView.swift
	•	│  ├─ SettingsView.swift
	•	│  ├─ AuthenticationView.swift
	•	│  └─ ...
	•	├─ Services/
	•	│  ├─ FirebaseService.swift
	•	│  └─ ...
 	•	├─ Resources/
	•	│  ├─ Assets.xcassets             # Images & app icons
	•	│  └─ ...
	•	└─ ...


## **Screens**

| Screen           | Description                                                                 |
|-------------------|-----------------------------------------------------------------------------|
| **Splash**        | Initial screen with app logo & loading animation.                         |
| **Authentication**| Register or log in; handles email & nickname-based sign-ins.              |
| **Home**          | Displays a grid of animals, search & filter by species, plus an "Add Animal" button. |
| **Detail**        | Shows an animal’s details (image, weight, birthday, insurance info).       |
| **Chat List**     | Lists all user’s conversations with last message preview.                 |
| **Chat**          | Real-time messaging interface; send & receive text messages instantly.    |
| **Favorites**     | Manages user’s saved animals; separates valid and invalid pets.           |
| **Profile**       | View or edit your user info & see your own animals.                       |
| **Settings**      | Account details, toggles for notifications/dark mode, log out button.     |
