//
//  MainHubView.swift
//  DF790
//

import SwiftUI

struct MainHubView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showGameSelection = false
    @State private var showProgress = false
    @State private var showSettings = false
    @State private var titleOpacity: Double = 0
    @State private var buttonsOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 30
    
    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedBackground()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: UIScreen.main.bounds.height * 0.15)
                        
                        // Hero section
                        VStack(spacing: 20) {
                            // Abstract icon
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color("NeonRed").opacity(0.3),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 20,
                                            endRadius: 60
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: "arrow.up.forward")
                                    .font(.system(size: 44, weight: .medium))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color("NeonRed"), Color("SoftGold")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            
                            VStack(spacing: 12) {
                                Text("Precision Arcade")
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(Color("WarmWhite"))
                                
                                Text("Timing • Focus • Mastery")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("SubtleGray"))
                                    .tracking(2)
                            }
                        }
                        .opacity(titleOpacity)
                        
                        Spacer()
                            .frame(height: 60)
                        
                        // Stats preview
                        HStack(spacing: 20) {
                            StatBadge(
                                value: "\(gameManager.statistics.totalSessions)",
                                label: "Sessions",
                                color: Color("NeonRed")
                            )
                            
                            StatBadge(
                                value: "\(gameManager.rewards.total)",
                                label: "Rewards",
                                color: Color("SoftGold")
                            )
                            
                            StatBadge(
                                value: "\(Int(averageMastery))%",
                                label: "Mastery",
                                color: Color("MutedRedGlow")
                            )
                        }
                        .opacity(titleOpacity)
                        
                        Spacer()
                            .frame(height: 50)
                        
                        // Main buttons
                        VStack(spacing: 16) {
                            PrimaryButton(title: "Play", action: {
                                showGameSelection = true
                            })
                            
                            SecondaryButton(title: "Progress", action: {
                                showProgress = true
                            })
                            
                            SecondaryButton(title: "Settings", action: {
                                showSettings = true
                            })
                        }
                        .padding(.horizontal, 40)
                        .opacity(buttonsOpacity)
                        .offset(y: buttonsOffset)
                        
                        Spacer()
                            .frame(height: 60)
                    }
                }
            }
            .navigationDestination(isPresented: $showGameSelection) {
                GameSelectionView(gameManager: gameManager)
            }
            .navigationDestination(isPresented: $showProgress) {
                ProgressView_(gameManager: gameManager)
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView(gameManager: gameManager)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                titleOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                buttonsOpacity = 1
                buttonsOffset = 0
            }
        }
    }
    
    private var averageMastery: Double {
        let masteries = GameType.allCases.map { gameManager.masteryPercentage(for: $0) }
        return masteries.reduce(0, +) / Double(masteries.count)
    }
}

struct StatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color("SubtleGray"))
        }
        .frame(width: 90, height: 70)
        .background(Color("DarkGraphite").opacity(0.6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Game Selection View
struct GameSelectionView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGame: GameType?
    @State private var cardsOpacity: Double = 0
    @State private var cardsOffset: CGFloat = 30
    
    var body: some View {
        ZStack {
            Color("DeepBlack").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    Text("Choose Your Challenge")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(Color("WarmWhite"))
                    
                    Text("Each game tests a different skill")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color("SubtleGray"))
                    
                    Spacer()
                        .frame(height: 20)
                    
                    ForEach(GameType.allCases) { game in
                        GameCard(
                            gameType: game,
                            mastery: gameManager.masteryPercentage(for: game),
                            rewards: gameManager.rewards.value(for: game)
                        ) {
                            selectedGame = game
                        }
                    }
                    .opacity(cardsOpacity)
                    .offset(y: cardsOffset)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color("NeonRed"))
                }
            }
        }
        .navigationDestination(item: $selectedGame) { game in
            DifficultySelectionView(gameManager: gameManager, gameType: game)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                cardsOpacity = 1
                cardsOffset = 0
            }
        }
    }
}

struct GameCard: View {
    let gameType: GameType
    let mastery: Double
    let rewards: Int
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color("NeonRed").opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: gameType.iconName)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(Color("NeonRed"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(gameType.displayName)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color("WarmWhite"))
                        
                        Text(gameType.description)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Color("SubtleGray"))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color("SubtleGray"))
                }
                
                // Progress bar
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Mastery")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color("SubtleGray"))
                        
                        Spacer()
                        
                        Text("\(Int(mastery))%")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(Color("SoftGold"))
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color("DeepBlack"))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(
                                    LinearGradient(
                                        colors: [Color("NeonRed"), Color("SoftGold")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * (mastery / 100), height: 6)
                        }
                    }
                    .frame(height: 6)
                }
                
                // Rewards
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundColor(Color("SoftGold"))
                    
                    Text("\(rewards) \(gameType.rewardName)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SoftGold").opacity(0.8))
                }
            }
            .padding(20)
            .background(Color("DarkGraphite"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("NeonRed").opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color("NeonRed").opacity(0.1), radius: 15, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Difficulty Selection
struct DifficultySelectionView: View {
    @ObservedObject var gameManager: GameManager
    let gameType: GameType
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDifficulty: Difficulty?
    
    var body: some View {
        ZStack {
            Color("DeepBlack").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Game header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color("NeonRed").opacity(0.2))
                                .frame(width: 70, height: 70)
                            
                            Image(systemName: gameType.iconName)
                                .font(.system(size: 30, weight: .medium))
                                .foregroundColor(Color("NeonRed"))
                        }
                        
                        Text(gameType.displayName)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color("WarmWhite"))
                        
                        Text("Select Difficulty")
                            .font(.system(size: 15, weight: .regular, design: .rounded))
                            .foregroundColor(Color("SubtleGray"))
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    // Difficulty cards
                    ForEach(Difficulty.allCases) { difficulty in
                        DifficultyCard(
                            difficulty: difficulty,
                            completedLevels: gameManager.completedLevels(for: gameType, difficulty: difficulty),
                            isUnlocked: isDifficultyUnlocked(difficulty),
                            previousDifficultyCompleted: previousDifficultyCompleted(for: difficulty)
                        ) {
                            selectedDifficulty = difficulty
                        }
                    }
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color("NeonRed"))
                }
            }
        }
        .navigationDestination(item: $selectedDifficulty) { difficulty in
            LevelSelectionView(gameManager: gameManager, gameType: gameType, difficulty: difficulty)
        }
    }
    
    private func isDifficultyUnlocked(_ difficulty: Difficulty) -> Bool {
        switch difficulty {
        case .easy: return true
        case .medium: return gameManager.completedLevels(for: gameType, difficulty: .easy) >= 3
        case .hard: return gameManager.completedLevels(for: gameType, difficulty: .medium) >= 3
        }
    }
    
    private func previousDifficultyCompleted(for difficulty: Difficulty) -> Int {
        switch difficulty {
        case .easy: return 0
        case .medium: return gameManager.completedLevels(for: gameType, difficulty: .easy)
        case .hard: return gameManager.completedLevels(for: gameType, difficulty: .medium)
        }
    }
}

struct DifficultyCard: View {
    let difficulty: Difficulty
    let completedLevels: Int
    let isUnlocked: Bool
    let previousDifficultyCompleted: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                action()
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(isUnlocked ? Color("WarmWhite") : Color("SubtleGray"))
                    
                    if isUnlocked {
                        Text("\(completedLevels)/\(difficulty.levelCount) levels")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color("SubtleGray"))
                    } else {
                        Text("Complete \(3 - previousDifficultyCompleted) more \(difficulty == .medium ? "Easy" : "Medium") levels")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(Color("SubtleGray"))
                    }
                }
                
                Spacer()
                
                if isUnlocked {
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(Color("DeepBlack"), lineWidth: 4)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(completedLevels) / CGFloat(difficulty.levelCount))
                            .stroke(difficulty.accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(completedLevels)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(difficulty.accentColor)
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("SubtleGray"))
                }
            }
            .padding(20)
            .background(Color("DarkGraphite").opacity(isUnlocked ? 1 : 0.5))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(difficulty.accentColor.opacity(isUnlocked ? 0.3 : 0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

// MARK: - Level Selection
struct LevelSelectionView: View {
    @ObservedObject var gameManager: GameManager
    let gameType: GameType
    let difficulty: Difficulty
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLevel: Int?
    @State private var navigateToGame = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            Color("DeepBlack").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer()
                        .frame(height: 20)
                    
                    Text("\(gameType.displayName) - \(difficulty.rawValue)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("WarmWhite"))
                    
                    Text("Select a level to play")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color("SubtleGray"))
                    
                    Spacer()
                        .frame(height: 20)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(1...difficulty.levelCount, id: \.self) { level in
                            LevelButton(
                                level: level,
                                isCompleted: gameManager.progress(for: gameType, difficulty: difficulty, level: level)?.completed ?? false,
                                isUnlocked: gameManager.isLevelUnlocked(gameType: gameType, difficulty: difficulty, level: level),
                                accentColor: difficulty.accentColor
                            ) {
                                selectedLevel = level
                                navigateToGame = true
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(Color("NeonRed"))
                }
            }
        }
        .navigationDestination(isPresented: $navigateToGame) {
            if let level = selectedLevel {
                gameView(for: gameType, difficulty: difficulty, level: level)
            }
        }
    }
    
    @ViewBuilder
    private func gameView(for gameType: GameType, difficulty: Difficulty, level: Int) -> some View {
        switch gameType {
        case .pulseLine:
            PulseLineGameView(gameManager: gameManager, difficulty: difficulty, level: level)
        case .pathSplit:
            PathSplitGameView(gameManager: gameManager, difficulty: difficulty, level: level)
        case .timingGrid:
            TimingGridGameView(gameManager: gameManager, difficulty: difficulty, level: level)
        }
    }
}

struct LevelButton: View {
    let level: Int
    let isCompleted: Bool
    let isUnlocked: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                action()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? accentColor.opacity(0.3) : Color("DarkGraphite"))
                    .frame(width: 56, height: 56)
                
                if isUnlocked {
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(accentColor)
                    } else {
                        Text("\(level)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color("WarmWhite"))
                    }
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color("SubtleGray").opacity(0.5))
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isCompleted ? accentColor.opacity(0.5) : Color("SubtleGray").opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isUnlocked)
    }
}

#Preview {
    MainHubView(gameManager: GameManager.shared)
}

