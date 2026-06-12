//
//  ContentView.swift
//  iosapplication

import SwiftUI

// Extends colors to support hex color codes

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

struct ContentView: View {
    @State private var tapCount: Int = 0
    @State private var elapsedSeconds: Int = 0
    @State private var isRunning: Bool = false
    @State private var timer: Timer? = nil
    @State private var isAnimating: Bool = false

// Convert total seconds to HH:MM:SS format
    var formattedTime: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // Full screen background color
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "#1a1a2e"), Color(hex: "#16213e")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 40) {

                // Tap Counter Box
                VStack(spacing: 8) {
                    Text("TAPS")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(4)

                    // spring effect animation
                    Text("\(tapCount)")
                        .font(.system(size: 64, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: tapCount)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "#4f46e5").opacity(0.5), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 32)

                Spacer()

                // Tap Button
                ZStack {
                    Button(action: handleTap) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [Color(hex: "#6366f1"), Color(hex: "#4f46e5")],
                                        center: .center,
                                        startRadius: 10,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .shadow(color: Color(hex: "#6366f1").opacity(0.6), radius: isAnimating ? 30 : 15)

                            Circle()
                                .stroke(Color(hex: "#818cf8").opacity(isAnimating ? 0 : 0.5), lineWidth: 2)
                                .frame(width: isAnimating ? 200 : 160, height: isAnimating ? 200 : 160)
                                .animation(.easeOut(duration: 0.4), value: isAnimating)

                            Text("TAP")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(3)
                        }
                    }
                    .scaleEffect(isAnimating ? 0.92 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isAnimating)
                }
                .frame(width: 220, height: 220)

                Spacer()

                // Timer Box
                VStack(spacing: 16) {
                    Text("ELAPSED TIME")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "#a0a0c0"))
                        .tracking(4)

                    Text(formattedTime)
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(isRunning ? Color(hex: "#34d399") : Color(hex: "#94a3b8"))
                        .contentTransition(.numericText())
                        .animation(.linear, value: elapsedSeconds)

                    // Start / Reset buttons
                    HStack(spacing: 16) {
                        Button(action: toggleTimer) {
                            Text(isRunning ? "STOP" : "START")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .tracking(2)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(isRunning ? Color(hex: "#ef4444") : Color(hex: "#22c55e"))
                                )
                        }

                        Button(action: resetAll) {
                            Text("RESET")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .tracking(2)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.15))
                                )
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.07))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "#34d399").opacity(0.3), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 40)

            }
            .padding(.top, 60)

        }
    }

    func handleTap() {
        guard isRunning else { return }
        tapCount += 1
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            isAnimating = false
        }
    }

    func toggleTimer() {
        if isRunning {
            timer?.invalidate()
            timer = nil
            isRunning = false
        } else {
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                elapsedSeconds += 1
            }
        }
    }

    func resetAll() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        elapsedSeconds = 0
        tapCount = 0
    }
}

#Preview {
    ContentView()
}
