//
//  ContentView.swift
//  iosapplication

import SwiftUI
internal import Combine

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
            Color(hex: "#1a1a2e")
                .ignoresSafeArea()

            VStack(spacing: 40) {

                // Tap count box
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

                    Text("BEST: \(highScore)")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#9494ab"))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "#20203a"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "#3a3a5c"), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 32)

                Spacer()

                // Tap button
                Button(action: handleTap) {
                    Circle()
                        .fill(Color(hex: "#4f46e5"))
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "#6a61f0"), lineWidth: 1)
                        )
                        .frame(width: 160, height: 160)
                        .overlay(
                            Text("TAP")
                                .font(.system(size: 22, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                                .tracking(3)
                        )
                }
                .scaleEffect(isAnimating ? 0.94 : 1.0)
                .animation(.easeOut(duration: 0.12), value: isAnimating)
                .disabled(!isPlaying)

                Spacer()

                // Time left box
                VStack(spacing: 8) {
                    Text("TIME LEFT")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "#9494ab"))
                        .tracking(4)

                    Text("\(timeLeft)")
                        .font(.system(size: 48, weight: .bold, design: .monospaced))
                        .foregroundColor(timeLeft <= 3 ? Color(hex: "#ef4444") : Color(hex: "#34d399"))
                        .contentTransition(.numericText())
                        .animation(.easeInOut, value: timeLeft)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "#20203a"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(hex: "#2e4a3f"), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
            .padding(.top, 40)

            // Game over overlay
            if gameOver {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { startGame() }

                VStack(spacing: 14) {
                    Text("GAME OVER")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(2)

                    Text("\(tapCount) TAPS")
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(hex: "#4f46e5"))

                    Text(isNewHighScore ? "NEW HIGH SCORE" : "BEST: \(highScore)")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "#34d399"))
                        .tracking(1)

                    Text("TAP ANYWHERE TO PLAY AGAIN")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#9494ab"))
                        .padding(.top, 20)
                }
                .padding(.vertical, 36)
                .padding(.horizontal, 32)
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(hex: "#20203a"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(hex: "#3a3a5c"), lineWidth: 1)
                        )
                )
                .transition(.scale.combined(with: .opacity))
                .onTapGesture { startGame() }
            }
        }
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startGame() }
        .onReceive(countdownTimer) { _ in
            guard isPlaying else { return }
            if timeLeft > 0 {
                timeLeft -= 1
            }
            if timeLeft == 0 {
                endGame()
            }
        }
    }

    // MARK: - Game Logic

    func handleTap() {
        guard isPlaying else { return }
        tapCount += 1
        isAnimating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            isAnimating = false
        }
    }

    func startGame() {
        tapCount = 0
        timeLeft = 10
        isPlaying = true
        withAnimation(.easeInOut(duration: 0.25)) {
            gameOver = false
        }
    }

    func endGame() {
        isPlaying = false
        isNewHighScore = tapCount > highScore
        if tapCount > highScore {
            highScore = tapCount
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            gameOver = true
        }
    }
}

#Preview {
    ContentView()
}

