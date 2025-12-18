//
//  PulseLineGameView.swift
//  DF790
//

import SwiftUI

struct PulseLineGameView: View {
    @ObservedObject var gameManager: GameManager
    let difficulty: Difficulty
    let level: Int
    @Environment(\.dismiss) private var dismiss
    
    // Game state
    @State private var gameState: GameState = .ready
    @State private var score: Int = 0
    @State private var currentRound: Int = 0
    @State private var totalRounds: Int = 5
    
    // Pulse animation - using timer for accurate position tracking
    @State private var pulsePosition: CGFloat = 0
    @State private var targetPosition: CGFloat = 0.5
    @State private var pulseSpeed: Double = 2.0
    @State private var targetWidth: CGFloat = 0.15
    @State private var isMovingRight = true
    @State private var animationTimer: Timer?
    @State private var animationStartTime: Date = Date()
    
    // Feedback
    @State private var showFeedback = false
    @State private var feedbackSuccess = false
    @State private var feedbackText = ""
    @State private var glowIntensity: Double = 0
    
    enum GameState {
        case ready
        case playing
        case roundEnd
        case gameOver
        case victory
    }
    
    var body: some View {
        ZStack {
            Color("DeepBlack").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                gameHeader
                
                Spacer()
                
                // Game area
                gameArea
                
                Spacer()
                
                // Bottom controls
                bottomControls
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            
            // Feedback overlay
            if showFeedback {
                feedbackOverlay
            }
            
            // Game over / Victory overlay
            if gameState == .gameOver || gameState == .victory {
                resultOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { 
                    stopAnimation()
                    dismiss() 
                }) {
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
        .onDisappear {
            stopAnimation()
        }
    }
    
    // MARK: - Game Header
    private var gameHeader: some View {
        VStack(spacing: 16) {
            Text("Level \(level)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Color("SubtleGray"))
            
            Text("Neon Strike")
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
        GeometryReader { geometry in
            ZStack {
                // Track background
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("DarkGraphite"))
                    .frame(height: 60)
                
                // Target zone
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("NeonRed").opacity(0.3))
                    .frame(width: geometry.size.width * targetWidth, height: 52)
                    .position(x: geometry.size.width * targetPosition, y: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color("NeonRed"), lineWidth: 2)
                            .frame(width: geometry.size.width * targetWidth, height: 52)
                            .position(x: geometry.size.width * targetPosition, y: 30)
                            .shadow(color: Color("NeonRed").opacity(glowIntensity), radius: 10)
                    )
                
                // Moving pulse
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color("SoftGold"), Color("SoftGold").opacity(0.5)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 20
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(color: Color("SoftGold").opacity(0.8), radius: 15)
                    .position(x: geometry.size.width * pulsePosition, y: 30)
            }
            .frame(height: 60)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .frame(height: 200)
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        VStack(spacing: 20) {
            if gameState == .ready {
                Text("Tap when the pulse aligns with the target zone")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SubtleGray"))
                    .multilineTextAlignment(.center)
                
                PrimaryButton(title: "Start", action: startGame)
                    .frame(width: 200)
            } else if gameState == .playing {
                Button(action: tapAction) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color("NeonRed"), Color("MutedRedGlow")],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: Color("NeonRed").opacity(0.5), radius: 20)
                        
                        Text("TAP")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color("DeepBlack"))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 150)
    }
    
    // MARK: - Feedback Overlay
    private var feedbackOverlay: some View {
        VStack {
            Text(feedbackText)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(feedbackSuccess ? Color("SoftGold") : Color("MutedRedGlow"))
                .shadow(color: feedbackSuccess ? Color("SoftGold").opacity(0.5) : Color("MutedRedGlow").opacity(0.5), radius: 20)
        }
        .transition(.scale.combined(with: .opacity))
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
                        Text("+\(Int(Double(score) * difficulty.multiplier * 0.1)) Energy Shards")
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
                        stopAnimation()
                        dismiss()
                    })
                    .frame(width: 200)
                }
            }
        }
    }
    
    // MARK: - Game Logic
    private func setupGame() {
        // Adjust difficulty parameters
        switch difficulty {
        case .easy:
            pulseSpeed = 2.5 - Double(level - 1) * 0.15
            targetWidth = 0.18 - CGFloat(level - 1) * 0.008
            totalRounds = 5
        case .medium:
            pulseSpeed = 2.0 - Double(level - 1) * 0.12
            targetWidth = 0.14 - CGFloat(level - 1) * 0.006
            totalRounds = 6
        case .hard:
            pulseSpeed = 1.5 - Double(level - 1) * 0.08
            targetWidth = 0.10 - CGFloat(level - 1) * 0.004
            totalRounds = 7
        }
        
        // Ensure minimum values
        pulseSpeed = max(pulseSpeed, 0.8)
        targetWidth = max(targetWidth, 0.06)
        
        randomizeTarget()
    }
    
    private func startGame() {
        gameState = .playing
        currentRound = 1
        score = 0
        startPulseAnimation()
        startGlowAnimation()
    }
    
    private func startPulseAnimation() {
        pulsePosition = 0
        isMovingRight = true
        animationStartTime = Date()
        
        // Use a timer to update position for accurate hit detection
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in
            updatePulsePosition()
        }
    }
    
    private func updatePulsePosition() {
        guard gameState == .playing else {
            stopAnimation()
            return
        }
        
        let elapsed = Date().timeIntervalSince(animationStartTime)
        let cycleTime = pulseSpeed
        let cycleProgress = elapsed.truncatingRemainder(dividingBy: cycleTime * 2)
        
        if cycleProgress < cycleTime {
            // Moving right (0 to 1)
            pulsePosition = CGFloat(cycleProgress / cycleTime)
            isMovingRight = true
        } else {
            // Moving left (1 to 0)
            pulsePosition = CGFloat(1 - (cycleProgress - cycleTime) / cycleTime)
            isMovingRight = false
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            glowIntensity = 0.8
        }
    }
    
    private func tapAction() {
        guard gameState == .playing else { return }
        
        // Check if pulse is within target zone
        let targetStart = targetPosition - targetWidth / 2
        let targetEnd = targetPosition + targetWidth / 2
        
        let distance = abs(pulsePosition - targetPosition)
        let maxDistance = targetWidth / 2
        
        if pulsePosition >= targetStart && pulsePosition <= targetEnd {
            // Success - calculate score based on accuracy
            let accuracy = 1 - (distance / maxDistance)
            let roundScore = Int(100 * accuracy * difficulty.multiplier)
            score += roundScore
            
            feedbackSuccess = true
            if accuracy > 0.8 {
                feedbackText = "Perfect!"
            } else if accuracy > 0.5 {
                feedbackText = "Great!"
            } else {
                feedbackText = "Good"
            }
        } else {
            feedbackSuccess = false
            feedbackText = "Miss"
        }
        
        // Show feedback
        withAnimation(.spring(response: 0.3)) {
            showFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                self.showFeedback = false
            }
            self.nextRound()
        }
    }
    
    private func nextRound() {
        if currentRound >= totalRounds {
            endGame()
        } else {
            currentRound += 1
            randomizeTarget()
        }
    }
    
    private func randomizeTarget() {
        targetPosition = CGFloat.random(in: 0.25...0.75)
    }
    
    private func endGame() {
        stopAnimation()
        glowIntensity = 0
        
        // Victory if scored in at least half the rounds
        let requiredScore = Int(Double(totalRounds) * 50 * difficulty.multiplier * 0.5)
        
        if score >= requiredScore {
            gameState = .victory
            gameManager.completeLevel(gameType: .pulseLine, difficulty: difficulty, level: level, score: score)
        } else {
            gameState = .gameOver
            gameManager.recordAttempt(gameType: .pulseLine, difficulty: difficulty, level: level, score: score)
        }
    }
    
    private func resetGame() {
        gameState = .ready
        score = 0
        currentRound = 0
        pulsePosition = 0
        setupGame()
    }
}

#Preview {
    NavigationStack {
        PulseLineGameView(gameManager: GameManager.shared, difficulty: .easy, level: 1)
    }
}
