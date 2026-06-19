//
//  LightupView.swift
//  ios_application
//
//  Created by student5 on 2026-06-19.
//

import SwiftUI
internal import Combine

enum Level: Equatable {
    case l1, l2, l3, l4

    // Number of cards on screen at this level
    var gridSize: Int {
        switch self {
        case .l1: return 3
        case .l2: return 4
        case .l3: return 6
        case .l4: return 9
        }
    }

    // Grid columns for the LazyVGrid
    var columns: Int {
        switch self {
        case .l1: return 3
        case .l2: return 2
        case .l3: return 3
        case .l4: return 3
        }
    }

    // How long a card stays lit before it goes dark
    var litWindow: Double {
        switch self {
        case .l1: return 1.5
        case .l2: return 1.2
        case .l3: return 1.0
        case .l4: return 0.8
        }
    }

    // L4 lights two cards at once
    var litCount: Int {
        self == .l4 ? 2 : 1
    }

    var label: String {
        switch self {
        case .l1: return "LEVEL 1"
        case .l2: return "LEVEL 2"
        case .l3: return "LEVEL 3"
        case .l4: return "LEVEL 4"
        }
    }

    // Which level applies at a given number of seconds into the round
    static func level(at elapsed: Double) -> Level {
        switch elapsed {
        case ..<15: return .l1
        case 15..<30: return .l2
        case 30..<45: return .l3
        default: return .l4
        }
    }
}

struct Card: Identifiable {
    let id = UUID()
    var isLit = false
}

struct LightupView: View {

    @AppStorage("lightItUpHighScore") private var highScore = 0

    @State private var score = 0
    @State private var roundTime: Double = 60
    @State private var level: Level = .l1
    @State private var cards: [Card] = []
    @State private var isPlaying = false
    @State private var gameOver = false
    @State private var isNewHighScore = false
    @State private var lightTimer: Timer?

    let roundTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Color(hex: "#1a1a2e")
                .ignoresSafeArea()

            VStack(spacing: 24) {

                HStack(spacing: 16) {
                    statBox(label: "SCORE", value: "\(score)", borderHex: "#3a3a5c", valueHex: "#ffffff")
                    statBox(label: "TIME LEFT", value: "\(Int(roundTime))", borderHex: "#2e4a3f", valueHex: roundTime <= 10 ? "#ef4444" : "#34d399")
                }
                .padding(.horizontal, 24)

                VStack(spacing: 4) {
                    Text(level.label)
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "#9494ab"))
                        .tracking(3)

                    Text("BEST: \(highScore)")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "#9494ab"))
                }

                Spacer()

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: level.columns), spacing: 12) {
                    ForEach(cards) { card in
                        cardView(card)
                    }
                }
                .padding(.horizontal, 32)

                Spacer()
            }
            .padding(.top, 30)

            // Round over overlay
            if gameOver {
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture { startRound() }

                VStack(spacing: 14) {
                    Text("ROUND OVER")
                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .tracking(2)

                    Text("\(score) POINTS")
                        .font(.system(size: 38, weight: .bold, design: .monospaced))
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
                .onTapGesture { startRound() }
            }
        }
        .navigationTitle("Light It Up")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startRound() }
        .onDisappear { lightTimer?.invalidate() }
        .onReceive(roundTimer) { _ in handleRoundTick() }
    }

    func statBox(label: String, value: String, borderHex: String, valueHex: String) -> some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(Color(hex: "#9494ab"))
                .tracking(2)

            Text(value)
                .font(.system(size: 30, weight: .bold, design: .monospaced))
                .foregroundColor(Color(hex: valueHex))
                .contentTransition(.numericText())
                .animation(.easeInOut, value: value)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(hex: "#20203a"))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(hex: borderHex), lineWidth: 1)
                )
        )
    }

    func cardView(_ card: Card) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(card.isLit ? Color(hex: "#4f46e5") : Color(hex: "#20203a"))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(hex: "#3a3a5c"), lineWidth: 1)
            )
            .frame(height: 78)
            .scaleEffect(card.isLit ? 1.05 : 1.0)
            .animation(.easeOut(duration: 0.15), value: card.isLit)
            .onTapGesture { handleTap(card) }
    }

    func startRound() {
        score = 0
        roundTime = 60
        level = .l1
        isPlaying = true
        gameOver = false
        setupCards(for: .l1)
        startLightTimer()
    }

    func setupCards(for level: Level) {
        cards = (0..<level.gridSize).map { _ in Card() }
    }

    func handleRoundTick() {
        guard isPlaying else { return }
        roundTime -= 1

        let elapsed = 60 - roundTime
        let newLevel = Level.level(at: elapsed)
        if newLevel != level {
            level = newLevel
            setupCards(for: newLevel)
            startLightTimer()
        }

        if roundTime <= 0 {
            endRound()
        }
    }

    // Restarts the lighting cycle at the current level's interval.
    // Called on round start and every time the level changes.
    func startLightTimer() {
        lightTimer?.invalidate()
        tickLights()
        lightTimer = Timer.scheduledTimer(withTimeInterval: level.litWindow, repeats: true) { _ in
            tickLights()
        }
    }

    func tickLights() {
        guard isPlaying else { return }

        // Any card still lit from the previous window was missed
        for index in cards.indices where cards[index].isLit {
            score = max(0, score - 1)
            cards[index].isLit = false
        }

        let indices = Array(cards.indices).shuffled().prefix(level.litCount)
        for i in indices {
            withAnimation { cards[i].isLit = true }
        }
    }

    func handleTap(_ card: Card) {
        guard isPlaying, let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[index].isLit {
            score += 1
            withAnimation { cards[index].isLit = false }
        } else {
            score = max(0, score - 1)
        }
    }

    func endRound() {
        isPlaying = false
        lightTimer?.invalidate()
        isNewHighScore = score > highScore
        if score > highScore {
            highScore = score
        }
        withAnimation(.easeInOut(duration: 0.3)) {
            gameOver = true
        }
    }
}

#Preview {
    LightupView()
}
