//
//  ProgressView_.swift
//  DF790
//

import SwiftUI

struct ProgressView_: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedGame: GameType? = nil
    @State private var animateProgress = false
    
    var body: some View {
        ZStack {
            Color("DeepBlack").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Header
                    VStack(spacing: 12) {
                        Text("Your Progress")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color("WarmWhite"))
                        
                        Text("Track your mastery journey")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color("SubtleGray"))
                    }
                    
                    // Overall stats
                    overallStatsSection
                    
                    // Game progress cards
                    VStack(spacing: 16) {
                        ForEach(GameType.allCases) { game in
                            GameProgressCard(
                                gameType: game,
                                mastery: gameManager.masteryPercentage(for: game),
                                rewards: gameManager.rewards.value(for: game),
                                completedLevels: gameManager.totalCompletedLevels(for: game),
                                totalLevels: gameManager.totalLevels(for: game),
                                animate: animateProgress
                            )
                        }
                    }
                    
                    // Rewards section
                    rewardsSection
                    
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
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animateProgress = true
            }
        }
    }
    
    // MARK: - Overall Stats Section
    private var overallStatsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                OverallStatCard(
                    icon: "flame.fill",
                    value: "\(gameManager.statistics.totalSessions)",
                    label: "Total Sessions",
                    color: Color("NeonRed")
                )
                
                OverallStatCard(
                    icon: "star.fill",
                    value: "\(Int(overallMastery))%",
                    label: "Overall Mastery",
                    color: Color("SoftGold")
                )
            }
            
            HStack(spacing: 16) {
                OverallStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(totalCompletedLevels)",
                    label: "Levels Done",
                    color: Color("SoftGold")
                )
                
                OverallStatCard(
                    icon: "sparkles",
                    value: "\(gameManager.rewards.total)",
                    label: "Total Rewards",
                    color: Color("MutedRedGlow")
                )
            }
        }
    }
    
    private var overallMastery: Double {
        let masteries = GameType.allCases.map { gameManager.masteryPercentage(for: $0) }
        return masteries.reduce(0, +) / Double(max(masteries.count, 1))
    }
    
    private var totalCompletedLevels: Int {
        GameType.allCases.reduce(0) { $0 + gameManager.totalCompletedLevels(for: $1) }
    }
    
    // MARK: - Rewards Section
    private var rewardsSection: some View {
        VStack(spacing: 16) {
            Text("Collected Rewards")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color("WarmWhite"))
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                RewardBadge(
                    name: "Energy Shards",
                    count: gameManager.rewards.energyShards,
                    icon: "bolt.fill",
                    color: Color("NeonRed")
                )
                
                RewardBadge(
                    name: "Signal Fragments",
                    count: gameManager.rewards.signalFragments,
                    icon: "waveform",
                    color: Color("SoftGold")
                )
                
                RewardBadge(
                    name: "Focus Marks",
                    count: gameManager.rewards.focusMarks,
                    icon: "scope",
                    color: Color("MutedRedGlow")
                )
            }
        }
        .padding(20)
        .background(Color("DarkGraphite"))
        .cornerRadius(20)
    }
}

// MARK: - Overall Stat Card
struct OverallStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color("WarmWhite"))
            }
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(Color("SubtleGray"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color("DarkGraphite"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Game Progress Card
struct GameProgressCard: View {
    let gameType: GameType
    let mastery: Double
    let rewards: Int
    let completedLevels: Int
    let totalLevels: Int
    let animate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                ZStack {
                    Circle()
                        .fill(Color("NeonRed").opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: gameType.iconName)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color("NeonRed"))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gameType.displayName)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(Color("WarmWhite"))
                    
                    Text("\(completedLevels)/\(totalLevels) levels completed")
                        .font(.system(size: 13, weight: .regular, design: .rounded))
                        .foregroundColor(Color("SubtleGray"))
                }
                
                Spacer()
                
                // Mastery percentage
                Text("\(Int(mastery))%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color("SoftGold"))
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color("DeepBlack"))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color("NeonRed"), Color("SoftGold")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: animate ? geometry.size.width * (mastery / 100) : 0, height: 8)
                        .animation(.easeOut(duration: 1.0), value: animate)
                }
            }
            .frame(height: 8)
            
            // Difficulty breakdown
            HStack(spacing: 20) {
                ForEach(Difficulty.allCases) { difficulty in
                    DifficultyIndicator(
                        difficulty: difficulty,
                        completed: completedForDifficulty(difficulty),
                        total: difficulty.levelCount
                    )
                }
                
                Spacer()
                
                // Rewards
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 12))
                        .foregroundColor(Color("SoftGold"))
                    
                    Text("\(rewards)")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("SoftGold"))
                }
            }
        }
        .padding(20)
        .background(Color("DarkGraphite"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color("NeonRed").opacity(0.15), lineWidth: 1)
        )
    }
    
    private func completedForDifficulty(_ difficulty: Difficulty) -> Int {
        // This would need access to GameManager, simplified for display
        return 0
    }
}

struct DifficultyIndicator: View {
    let difficulty: Difficulty
    let completed: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 4) {
            Text(difficulty.rawValue)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(difficulty.accentColor)
            
            Text("\(completed)/\(total)")
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(Color("SubtleGray"))
        }
    }
}

// MARK: - Reward Badge
struct RewardBadge: View {
    let name: String
    let count: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }
            
            Text("\(count)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(Color("WarmWhite"))
            
            Text(name)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(Color("SubtleGray"))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ProgressView_(gameManager: GameManager.shared)
    }
}

