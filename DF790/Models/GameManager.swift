//
//  GameManager.swift
//  DF790
//

import Foundation
import SwiftUI
import Combine

class GameManager: ObservableObject {
    static let shared = GameManager()
    
    @Published var hasCompletedOnboarding: Bool {
        didSet { saveOnboardingState() }
    }
    @Published var levelProgress: [LevelProgress] = []
    @Published var rewards: Rewards = Rewards()
    @Published var statistics: Statistics = Statistics()
    @Published var sessions: [GameSession] = []
    
    private let onboardingKey = "hasCompletedOnboarding"
    private let progressKey = "levelProgress"
    private let rewardsKey = "rewards"
    private let statisticsKey = "statistics"
    private let sessionsKey = "gameSessions"
    
    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        loadData()
    }
    
    // MARK: - Data Loading
    private func loadData() {
        if let progressData = UserDefaults.standard.data(forKey: progressKey),
           let progress = try? JSONDecoder().decode([LevelProgress].self, from: progressData) {
            levelProgress = progress
        } else {
            initializeLevelProgress()
        }
        
        if let rewardsData = UserDefaults.standard.data(forKey: rewardsKey),
           let loadedRewards = try? JSONDecoder().decode(Rewards.self, from: rewardsData) {
            rewards = loadedRewards
        }
        
        if let statsData = UserDefaults.standard.data(forKey: statisticsKey),
           let stats = try? JSONDecoder().decode(Statistics.self, from: statsData) {
            statistics = stats
        }
        
        if let sessionsData = UserDefaults.standard.data(forKey: sessionsKey),
           let loadedSessions = try? JSONDecoder().decode([GameSession].self, from: sessionsData) {
            sessions = loadedSessions
        }
    }
    
    private func initializeLevelProgress() {
        levelProgress = []
        for game in GameType.allCases {
            for difficulty in Difficulty.allCases {
                for level in 1...difficulty.levelCount {
                    levelProgress.append(LevelProgress(
                        gameType: game,
                        difficulty: difficulty,
                        level: level
                    ))
                }
            }
        }
        saveProgress()
    }
    
    // MARK: - Progress Queries
    func progress(for gameType: GameType, difficulty: Difficulty, level: Int) -> LevelProgress? {
        levelProgress.first { $0.gameType == gameType.rawValue && $0.difficulty == difficulty.rawValue && $0.level == level }
    }
    
    func completedLevels(for gameType: GameType, difficulty: Difficulty) -> Int {
        levelProgress.filter { $0.gameType == gameType.rawValue && $0.difficulty == difficulty.rawValue && $0.completed }.count
    }
    
    func totalCompletedLevels(for gameType: GameType) -> Int {
        levelProgress.filter { $0.gameType == gameType.rawValue && $0.completed }.count
    }
    
    func totalLevels(for gameType: GameType) -> Int {
        Difficulty.allCases.reduce(0) { $0 + $1.levelCount }
    }
    
    func masteryPercentage(for gameType: GameType) -> Double {
        let completed = Double(totalCompletedLevels(for: gameType))
        let total = Double(totalLevels(for: gameType))
        return total > 0 ? (completed / total) * 100 : 0
    }
    
    func isLevelUnlocked(gameType: GameType, difficulty: Difficulty, level: Int) -> Bool {
        if level == 1 {
            if difficulty == .easy { return true }
            let previousDifficulty = difficulty == .medium ? Difficulty.easy : Difficulty.medium
            return completedLevels(for: gameType, difficulty: previousDifficulty) >= 3
        }
        return progress(for: gameType, difficulty: difficulty, level: level - 1)?.completed ?? false
    }
    
    // MARK: - Game Completion
    func completeLevel(gameType: GameType, difficulty: Difficulty, level: Int, score: Int) {
        if let index = levelProgress.firstIndex(where: {
            $0.gameType == gameType.rawValue && $0.difficulty == difficulty.rawValue && $0.level == level
        }) {
            // Create a new copy to trigger SwiftUI update
            var updatedProgress = levelProgress[index]
            updatedProgress.completed = true
            updatedProgress.attempts += 1
            if score > updatedProgress.bestScore {
                updatedProgress.bestScore = score
            }
            levelProgress[index] = updatedProgress
        }
        
        let rewardAmount = Int(Double(score) * difficulty.multiplier * 0.1)
        rewards.add(for: gameType, amount: max(rewardAmount, 1))
        
        let session = GameSession(gameType: gameType, difficulty: difficulty, level: level, score: score, completed: true)
        sessions.append(session)
        statistics.recordSession(for: gameType)
        
        saveAll()
        
        // Force UI update by reassigning array
        objectWillChange.send()
    }
    
    func recordAttempt(gameType: GameType, difficulty: Difficulty, level: Int, score: Int) {
        if let index = levelProgress.firstIndex(where: {
            $0.gameType == gameType.rawValue && $0.difficulty == difficulty.rawValue && $0.level == level
        }) {
            var updatedProgress = levelProgress[index]
            updatedProgress.attempts += 1
            levelProgress[index] = updatedProgress
        }
        
        let session = GameSession(gameType: gameType, difficulty: difficulty, level: level, score: score, completed: false)
        sessions.append(session)
        statistics.recordSession(for: gameType)
        
        saveAll()
    }
    
    // MARK: - Persistence
    private func saveOnboardingState() {
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: onboardingKey)
    }
    
    private func saveProgress() {
        if let data = try? JSONEncoder().encode(levelProgress) {
            UserDefaults.standard.set(data, forKey: progressKey)
        }
    }
    
    private func saveRewards() {
        if let data = try? JSONEncoder().encode(rewards) {
            UserDefaults.standard.set(data, forKey: rewardsKey)
        }
    }
    
    private func saveStatistics() {
        if let data = try? JSONEncoder().encode(statistics) {
            UserDefaults.standard.set(data, forKey: statisticsKey)
        }
    }
    
    private func saveSessions() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: sessionsKey)
        }
    }
    
    private func saveAll() {
        saveProgress()
        saveRewards()
        saveStatistics()
        saveSessions()
    }
    
    func resetProgress() {
        levelProgress = []
        rewards = Rewards()
        statistics = Statistics()
        sessions = []
        initializeLevelProgress()
        saveAll()
    }
}

