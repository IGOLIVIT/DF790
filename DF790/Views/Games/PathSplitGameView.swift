//
//  PathSplitGameView.swift
//  DF790
//

import SwiftUI

struct PathSplitGameView: View {
    @ObservedObject var gameManager: GameManager
    let difficulty: Difficulty
    let level: Int
    @Environment(\.dismiss) private var dismiss
    
    // Game state
    @State private var gameState: GameState = .ready
    @State private var score: Int = 0
    @State private var currentRound: Int = 0
    @State private var totalRounds: Int = 5
    
    // Path data
    @State private var pathCount: Int = 3
    @State private var correctPath: Int = 0
    @State private var selectedPath: Int? = nil
    @State private var pathStates: [PathState] = []
    @State private var showingHint = false
    @State private var hintPhase: Int = 0
    @State private var revealedPath: Bool = false
    
    enum GameState {
        case ready
        case hinting
        case choosing
        case revealing
        case roundEnd
        case gameOver
        case victory
    }
    
    enum PathState {
        case neutral
        case hinting
        case stable
        case breaking
        case selected
    }
    
    var body: some View {
        ZStack {
            Color("DeepBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                gameHeader
                
                Spacer()
                
                gameArea
                
                Spacer()
                
                bottomArea
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            
            if gameState == .gameOver || gameState == .victory {
                resultOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(Color("SubtleGray"))
                }
            }
        }
        .onAppear {
            setupGame()
        }
    }
    
    // MARK: - Game Header
    private var gameHeader: some View {
        VStack(spacing: 16) {
            Text("Level \(level)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color("SubtleGray"))
            
            Text("Signal Chase")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color("WarmWhite"))
            
            HStack(spacing: 30) {
                VStack(spacing: 4) {
                    Text("Score")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SubtleGray"))
                    Text("\(score)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("SoftGold"))
                }
                
                VStack(spacing: 4) {
                    Text("Round")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SubtleGray"))
                    Text("\(currentRound)/\(totalRounds)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("NeonRed"))
                }
            }
        }
    }
    
    // MARK: - Game Area
    private var gameArea: some View {
        VStack(spacing: 24) {
            // Status text
            Text(statusText)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("SubtleGray"))
                .frame(height: 24)
            
            // Paths
            HStack(spacing: 16) {
                ForEach(0..<pathCount, id: \.self) { index in
                    PathView(
                        index: index,
                        state: pathStates.indices.contains(index) ? pathStates[index] : .neutral,
                        isCorrect: index == correctPath && revealedPath,
                        canSelect: gameState == .choosing
                    ) {
                        selectPath(index)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var statusText: String {
        switch gameState {
        case .ready:
            return "Watch the paths carefully"
        case .hinting:
            return "Observe the signals..."
        case .choosing:
            return "Choose the stable path!"
        case .revealing:
            return revealedPath ? (selectedPath == correctPath ? "Correct!" : "Wrong path!") : ""
        default:
            return ""
        }
    }
    
    // MARK: - Bottom Area
    private var bottomArea: some View {
        VStack(spacing: 20) {
            if gameState == .ready {
                Text("The stable path will show subtle hints.\nWatch carefully, then choose wisely.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color("SubtleGray"))
                    .multilineTextAlignment(.center)
                
                PrimaryButton(title: "Start", action: startGame)
                    .frame(width: 200)
            }
        }
        .frame(height: 120)
    }
    
    // MARK: - Result Overlay
    private var resultOverlay: some View {
        ZStack {
            Color("DeepBlack").opacity(0.9).ignoresSafeArea()
            
            VStack(spacing: 30) {
                if gameState == .victory {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("SoftGold"))
                        .shadow(color: Color("SoftGold").opacity(0.5), radius: 20)
                    
                    Text("Level Complete!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color("WarmWhite"))
                } else {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color("MutedRedGlow"))
                    
                    Text("Try Again")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color("WarmWhite"))
                }
                
                VStack(spacing: 8) {
                    Text("Score: \(score)")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("SoftGold"))
                    
                    if gameState == .victory {
                        Text("+\(Int(Double(score) * difficulty.multiplier * 0.1)) Signal Fragments")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color("SubtleGray"))
                    }
                }
                
                VStack(spacing: 12) {
                    if gameState == .gameOver {
                        PrimaryButton(title: "Retry", action: resetGame)
                            .frame(width: 200)
                    }
                    
                    SecondaryButton(title: gameState == .victory ? "Continue" : "Exit", action: {
                        dismiss()
                    })
                    .frame(width: 200)
                }
            }
        }
    }
    
    // MARK: - Game Logic
    private func setupGame() {
        switch difficulty {
        case .easy:
            pathCount = 3
            totalRounds = 5
        case .medium:
            pathCount = 3 + (level > 5 ? 1 : 0)
            totalRounds = 6
        case .hard:
            pathCount = 4 + (level > 5 ? 1 : 0)
            totalRounds = 7
        }
        
        initializePaths()
    }
    
    private func initializePaths() {
        pathStates = Array(repeating: .neutral, count: pathCount)
        correctPath = Int.random(in: 0..<pathCount)
        selectedPath = nil
        revealedPath = false
    }
    
    private func startGame() {
        currentRound = 1
        score = 0
        startRound()
    }
    
    private func startRound() {
        initializePaths()
        gameState = .hinting
        hintPhase = 0
        showHints()
    }
    
    private func showHints() {
        // Number of hints depends on difficulty
        let hintCount: Int
        let hintDuration: Double
        
        switch difficulty {
        case .easy:
            hintCount = 3
            hintDuration = 0.6
        case .medium:
            hintCount = 2
            hintDuration = 0.5
        case .hard:
            hintCount = max(1, 2 - level / 5)
            hintDuration = 0.4
        }
        
        // Show hints for the correct path
        func showNextHint(count: Int) {
            guard count > 0, gameState == .hinting else {
                transitionToChoosing()
                return
            }
            
            // Briefly highlight the correct path
            withAnimation(.easeInOut(duration: 0.2)) {
                pathStates[correctPath] = .hinting
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + hintDuration) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.pathStates[self.correctPath] = .neutral
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showNextHint(count: count - 1)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showNextHint(count: hintCount)
        }
    }
    
    private func transitionToChoosing() {
        gameState = .choosing
    }
    
    private func selectPath(_ index: Int) {
        guard gameState == .choosing else { return }
        
        selectedPath = index
        pathStates[index] = .selected
        gameState = .revealing
        
        // Reveal result after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.revealResult()
        }
    }
    
    private func revealResult() {
        revealedPath = true
        
        // Update path states
        for i in 0..<pathCount {
            if i == correctPath {
                pathStates[i] = .stable
            } else if i == selectedPath {
                pathStates[i] = .breaking
            }
        }
        
        // Calculate score
        if selectedPath == correctPath {
            let baseScore = Int(100 * difficulty.multiplier)
            score += baseScore
        }
        
        // Next round after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.nextRound()
        }
    }
    
    private func nextRound() {
        if currentRound >= totalRounds {
            endGame()
        } else {
            currentRound += 1
            startRound()
        }
    }
    
    private func endGame() {
        let requiredScore = Int(Double(totalRounds) * 50 * difficulty.multiplier)
        
        if score >= requiredScore {
            gameState = .victory
            gameManager.completeLevel(gameType: .pathSplit, difficulty: difficulty, level: level, score: score)
        } else {
            gameState = .gameOver
            gameManager.recordAttempt(gameType: .pathSplit, difficulty: difficulty, level: level, score: score)
        }
    }
    
    private func resetGame() {
        gameState = .ready
        score = 0
        currentRound = 0
        setupGame()
    }
}

// MARK: - Path View
struct PathView: View {
    let index: Int
    let state: PathSplitGameView.PathState
    let isCorrect: Bool
    let canSelect: Bool
    let action: () -> Void
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var breakOffset: CGFloat = 0
    @State private var breakOpacity: Double = 1
    
    var body: some View {
        Button(action: {
            if canSelect { action() }
        }) {
            ZStack {
                // Path track
                VStack(spacing: 0) {
                    // Top section
                    RoundedRectangle(cornerRadius: 8)
                        .fill(pathColor)
                        .frame(width: 60, height: 80)
                        .offset(y: state == .breaking ? -breakOffset : 0)
                        .opacity(state == .breaking ? breakOpacity : 1)
                    
                    // Junction point
                    Circle()
                        .fill(junctionColor)
                        .frame(width: 20, height: 20)
                        .scaleEffect(state == .hinting ? pulseScale : 1.0)
                        .shadow(color: glowColor, radius: state == .hinting || state == .stable ? 10 : 0)
                    
                    // Bottom section
                    RoundedRectangle(cornerRadius: 8)
                        .fill(pathColor)
                        .frame(width: 60, height: 80)
                        .offset(y: state == .breaking ? breakOffset : 0)
                        .opacity(state == .breaking ? breakOpacity : 1)
                }
                
                // Stable indicator
                if state == .stable {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color("SoftGold"))
                        .shadow(color: Color("SoftGold").opacity(0.5), radius: 10)
                }
                
                // Breaking indicator
                if state == .breaking {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color("MutedRedGlow"))
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!canSelect)
        .onChange(of: state) { _, newValue in
            if newValue == .hinting {
                withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                    pulseScale = 1.3
                }
            } else {
                pulseScale = 1.0
            }
            
            if newValue == .breaking {
                withAnimation(.easeIn(duration: 0.5)) {
                    breakOffset = 20
                    breakOpacity = 0.3
                }
            } else {
                breakOffset = 0
                breakOpacity = 1
            }
        }
    }
    
    private var pathColor: Color {
        switch state {
        case .neutral, .hinting:
            return Color("DarkGraphite")
        case .stable:
            return Color("SoftGold").opacity(0.3)
        case .breaking:
            return Color("MutedRedGlow").opacity(0.3)
        case .selected:
            return Color("NeonRed").opacity(0.3)
        }
    }
    
    private var junctionColor: Color {
        switch state {
        case .hinting:
            return Color("SoftGold")
        case .stable:
            return Color("SoftGold")
        case .breaking:
            return Color("MutedRedGlow")
        case .selected:
            return Color("NeonRed")
        default:
            return Color("SubtleGray")
        }
    }
    
    private var glowColor: Color {
        switch state {
        case .hinting:
            return Color("SoftGold").opacity(0.8)
        case .stable:
            return Color("SoftGold").opacity(0.6)
        default:
            return Color.clear
        }
    }
}

#Preview {
    NavigationStack {
        PathSplitGameView(gameManager: GameManager.shared, difficulty: .easy, level: 1)
    }
}

