//
//  BackgroundView.swift
//  Petty App
//
//  Created by AlbertoOoXking on 13.01.25.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Color.blue.opacity(0.25),
                    Color.gray.opacity(0.25)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all)
    }
}
