//
//  HomeView.swift
//  ios_application
//
//  Created by student5 on 2026-06-19.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#1a1a2e")
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("MINI ARCADE")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "#9494ab"))
                        .tracking(4)
                        .padding(.bottom, 20)

                    NavigationLink(destination: ContentView()) {
                        modeButton(title: "TAP FRENZY", subtitle: "Tap as fast as you can")
                    }

                    NavigationLink(destination: LightupView()) {
                        modeButton(title: "LIGHT IT UP", subtitle: "Tap the card before it goes dark")
                    }
                }
                .padding(.horizontal, 32)
            }
        }
        .preferredColorScheme(.dark)
    }

    func modeButton(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 19, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(Color(hex: "#9494ab"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "#20203a"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: "#3a3a5c"), lineWidth: 1)
                )
        )
    }
}

#Preview {
    HomeView()
}
