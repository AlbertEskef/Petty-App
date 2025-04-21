//
//  SettingsRow.swift
//  Petty App
//
//  Created by AlbertoOoXking on 27.01.25.
//

import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    var detail: String? = nil
    var isEditable: Bool = false
    var action: (() -> Void)? = nil

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 25, height: 25)

            Text(title)
                .font(.body)
                .foregroundColor(.primary)

            Spacer()

            if let detail = detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            if isEditable, let action = action {
                Button(action: action) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
    }
}
