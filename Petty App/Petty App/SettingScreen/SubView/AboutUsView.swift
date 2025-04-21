//
//  AboutUsView.swift
//  Petty App
//
//  Created by AlbertoOoXking on 27.01.25.
//

import SwiftUI

struct AboutUsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("About Petty App")
                    .font(.title)
                    .bold()

                Text("""
                Welcome to Petty App, the ultimate community for pet lovers! Whether you're looking to adopt a furry friend, connect with other pet owners, or learn more about pet care, Petty App is here to make your life easier.

                Our goal is to create a platform where pet owners can share knowledge, find local services, and build meaningful connections.

                Thank you for being part of our community. Together, we can make every pet's life happier and healthier.
                """)
                    .font(.body)
                    .foregroundColor(.secondary)

                Text("Features")
                    .font(.title2)
                    .bold()

                Text("""
                - Chat with other pet owners.
                - Manage adoption applications.
                - Access pet care resources and tips.
                - Find shelters and local pet services.
                """)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .background(BackgroundView())
        .navigationTitle("About Us")
        .navigationBarTitleDisplayMode(.inline)
    }
}
