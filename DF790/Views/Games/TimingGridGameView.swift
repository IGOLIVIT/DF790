//
//  TimingGridGameView.swift
//  DF790
//

import SwiftUI

struct TimingGridGameView: View {
    @ObservedObject var gameManager: GameManager
    let difficulty: Difficulty
    let level: Int
    @Environment(\.dismiss) private var dismiss
    
    // Game state
    @State private var gameState: GameState = .ready
    @State private var score: Int = 0
    @State private var currentRound: Int = 0
    @State private var totalRounds: Int = 5
    
    // Grid state
    @State private var gridSize: Int = 3
    @State private var pattern: [Int] = []
    @State private var playerInput: [Int] = []
    @State private var currentPatternIndex: Int = 0
    @State private var highlightedCell: Int? = nil
    @State private var cellStates: [CellState] = []
    
    // Timing
    @State private var beatInterval: Double = 0.8
    @State private var showingPattern = false
    
    enum GameState {
        case ready
        case showingPattern
        case playerTurn
        case roundEnd
        case gameOver
        case victory
    }
    
    enum CellState {
        case neutral
        case highlighted
        case correct
        case wrong
        case playerTap
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
            
            Text("Rhythm Matrix")
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
            
            // Status indicator
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                    .shadow(color: statusColor.opacity(0.5), radius: 5)
                
                Text(statusText)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SubtleGray"))
            }
            .padding(.top, 8)
        }
    }
    
    private var statusColor: Color {
        switch gameState {
        case .showingPattern:
            return Color("SoftGold")
        case .playerTurn:
            return Color("NeonRed")
        default:
            return Color("SubtleGray")
        }
    }
    
    private var statusText: String {
        switch gameState {
        case .ready:
            return "Ready"
        case .showingPattern:
            return "Watch the pattern"
        case .playerTurn:
            return "Repeat the pattern! (\(playerInput.count)/\(pattern.count))"
        case .roundEnd:
            return "Round complete"
        default:
            return ""
        }
    }
    
    // MARK: - Game Area
    private var gameArea: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: gridSize)
        
        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(0..<(gridSize * gridSize), id: \.self) { index in
                GridCell(
                    index: index,
                    state: cellStates.indices.contains(index) ? cellStates[index] : .neutral,
                    canTap: gameState == .playerTurn
                ) {
                    handleCellTap(index)
                }
            }
        }
        .padding(20)
        .background(Color("DarkGraphite").opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Bottom Area
    private var bottomArea: some View {
        VStack(spacing: 20) {
            if gameState == .ready {
                Text("Watch the cells light up in sequence.\nThen tap them in the same order and rhythm.")
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
                        Text("+\(Int(Double(score) * difficulty.multiplier * 0.1)) Focus Marks")
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
            gridSize = 3
            beatInterval = 0.8 - Double(level - 1) * 0.03
            totalRounds = 5
        case .medium:
            gridSize = 3
            beatInterval = 0.7 - Double(level - 1) * 0.025
            totalRounds = 6
        case .hard:
            gridSize = level > 5 ? 4 : 3
            beatInterval = 0.6 - Double(level - 1) * 0.02
            totalRounds = 7
        }
        
        beatInterval = max(beatInterval, 0.35)
        initializeGrid()
    }
    
    private func initializeGrid() {
        cellStates = Array(repeating: .neutral, count: gridSize * gridSize)
        pattern = []
        playerInput = []
        currentPatternIndex = 0
    }
    
    private func startGame() {
        currentRound = 1
        score = 0
        startRound()
    }
    
    private func startRound() {
        initializeGrid()
        generatePattern()
        gameState = .showingPattern
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showPattern()
        }
    }
    
    private func generatePattern() {
        // Pattern length increases with level and round
        let baseLength: Int
        switch difficulty {
        case .easy:
            baseLength = 3 + (level - 1) / 3
        case .medium:
            baseLength = 4 + (level - 1) / 2
        case .hard:
            baseLength = 5 + (level - 1) / 2
        }
        
        let patternLength = min(baseLength + (currentRound - 1) / 2, gridSize * gridSize)
        
        pattern = []
        var availableCells = Array(0..<(gridSize * gridSize))
        
        for _ in 0..<patternLength {
            if availableCells.isEmpty {
                availableCells = Array(0..<(gridSize * gridSize))
            }
            let randomIndex = Int.random(in: 0..<availableCells.count)
            let cell = availableCells.remove(at: randomIndex)
            pattern.append(cell)
        }
    }
    
    private func showPattern() {
        currentPatternIndex = 0
        showNextPatternCell()
    }
    
    private func showNextPatternCell() {
        guard currentPatternIndex < pattern.count else {
            // Pattern complete, player's turn
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.gameState = .playerTurn
            }
            return
        }
        
        let cellIndex = pattern[currentPatternIndex]
        
        // Highlight cell
        withAnimation(.easeInOut(duration: 0.1)) {
            cellStates[cellIndex] = .highlighted
        }
        
        // Remove highlight
        DispatchQueue.main.asyncAfter(deadline: .now() + beatInterval * 0.7) {
            withAnimation(.easeInOut(duration: 0.1)) {
                self.cellStates[cellIndex] = .neutral
            }
            
            // Show next cell
            DispatchQueue.main.asyncAfter(deadline: .now() + self.beatInterval * 0.3) {
                self.currentPatternIndex += 1
                self.showNextPatternCell()
            }
        }
    }
    
    private func handleCellTap(_ index: Int) {
        guard gameState == .playerTurn else { return }
        
        let expectedCell = pattern[playerInput.count]
        playerInput.append(index)
        
        if index == expectedCell {
            // Correct tap
            withAnimation(.easeInOut(duration: 0.1)) {
                cellStates[index] = .correct
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    self.cellStates[index] = .neutral
                }
            }
            
            // Check if pattern complete
            if playerInput.count == pattern.count {
                // Calculate score based on pattern length
                let roundScore = Int(Double(pattern.count * 20) * difficulty.multiplier)
                score += roundScore
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.nextRound()
                }
            }
        } else {
            // Wrong tap
            withAnimation(.easeInOut(duration: 0.1)) {
                cellStates[index] = .wrong
                if expectedCell < cellStates.count {
                    cellStates[expectedCell] = .highlighted
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.endGame(success: false)
            }
        }
    }
    
    private func nextRound() {
        if currentRound >= totalRounds {
            endGame(success: true)
        } else {
            currentRound += 1
            startRound()
        }
    }
    
    private func endGame(success: Bool) {
        if success {
            gameState = .victory
            gameManager.completeLevel(gameType: .timingGrid, difficulty: difficulty, level: level, score: score)
        } else {
            gameState = .gameOver
            gameManager.recordAttempt(gameType: .timingGrid, difficulty: difficulty, level: level, score: score)
        }
    }
    
    private func resetGame() {
        gameState = .ready
        score = 0
        currentRound = 0
        setupGame()
    }
}

// MARK: - Grid Cell
struct GridCell: View {
    let index: Int
    let state: TimingGridGameView.CellState
    let canTap: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if canTap {
                withAnimation(.easeInOut(duration: 0.05)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    isPressed = false
                    action()
                }
            }
        }) {
            RoundedRectangle(cornerRadius: 12)
                .fill(cellColor)
                .frame(height: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: state == .neutral ? 1 : 2)
                )
                .shadow(color: glowColor, radius: state == .highlighted ? 15 : 0)
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(!canTap)
    }
    
    private var cellColor: Color {
        switch state {
        case .neutral:
            return Color("DarkGraphite")
        case .highlighted:
            return Color("SoftGold").opacity(0.4)
        case .correct:
            return Color("SoftGold").opacity(0.3)
        case .wrong:
            return Color("MutedRedGlow").opacity(0.4)
        case .playerTap:
            return Color("NeonRed").opacity(0.3)
        }
    }
    
    private var borderColor: Color {
        switch state {
        case .neutral:
            return Color("SubtleGray").opacity(0.2)
        case .highlighted:
            return Color("SoftGold")
        case .correct:
            return Color("SoftGold")
        case .wrong:
            return Color("MutedRedGlow")
        case .playerTap:
            return Color("NeonRed")
        }
    }
    
    private var glowColor: Color {
        switch state {
        case .highlighted:
            return Color("SoftGold").opacity(0.6)
        case .correct:
            return Color("SoftGold").opacity(0.4)
        default:
            return Color.clear
        }
    }
}

#Preview {
    NavigationStack {
        TimingGridGameView(gameManager: GameManager.shared, difficulty: .easy, level: 1)
    }
}

