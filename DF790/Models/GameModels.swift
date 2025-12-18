//
//  GameModels.swift
//  DF790
//

import Foundation
import SwiftUI

// MARK: - Game Types
enum GameType: String, CaseIterable, Identifiable {
    case pulseLine = "pulseLine"
    case pathSplit = "pathSplit"
    case timingGrid = "timingGrid"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .pulseLine:
            return "Neon Strike"
        case .pathSplit:
            return "Signal Chase"
        case .timingGrid:
            return "Rhythm Matrix"
        }
    }
    
    var description: String {
        switch self {
        case .pulseLine:
            return "Tap when the pulse aligns"
        case .pathSplit:
            return "Predict the stable path"
        case .timingGrid:
            return "Match the rhythm pattern"
        }
    }
    
    var rewardName: String {
        switch self {
        case .pulseLine:
            return "Energy Shards"
        case .pathSplit:
            return "Signal Fragments"
        case .timingGrid:
            return "Focus Marks"
        }
    }
    
    var iconName: String {
        switch self {
        case .pulseLine:
            return "waveform.path"
        case .pathSplit:
            return "arrow.triangle.branch"
        case .timingGrid:
            return "square.grid.3x3"
        }
    }
}

// MARK: - Difficulty
enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var id: String { rawValue }
    
    var levelCount: Int { 10 }
    
    var multiplier: Double {
        switch self {
        case .easy: return 1.0
        case .medium: return 1.5
        case .hard: return 2.0
        }
    }
    
    var accentColor: Color {
        switch self {
        case .easy: return Color("SoftGold")
        case .medium: return Color("NeonRed")
        case .hard: return Color("MutedRedGlow")
        }
    }
}

// MARK: - Level Progress
struct LevelProgress: Codable, Identifiable {
    var id: String { "\(gameType)_\(difficulty)_\(level)" }
    let gameType: String
    let difficulty: String
    let level: Int
    var completed: Bool
    var bestScore: Int
    var attempts: Int
    
    init(gameType: GameType, difficulty: Difficulty, level: Int, completed: Bool = false, bestScore: Int = 0, attempts: Int = 0) {
        self.gameType = gameType.rawValue
        self.difficulty = difficulty.rawValue
        self.level = level
        self.completed = completed
        self.bestScore = bestScore
        self.attempts = attempts
    }
}

// MARK: - Rewards
struct Rewards: Codable {
    var energyShards: Int = 0
    var signalFragments: Int = 0
    var focusMarks: Int = 0
    
    var total: Int {
        energyShards + signalFragments + focusMarks
    }
    
    mutating func add(for gameType: GameType, amount: Int) {
        switch gameType {
        case .pulseLine:
            energyShards += amount
        case .pathSplit:
            signalFragments += amount
        case .timingGrid:
            focusMarks += amount
        }
    }
    
    func value(for gameType: GameType) -> Int {
        switch gameType {
        case .pulseLine:
            return energyShards
        case .pathSplit:
            return signalFragments
        case .timingGrid:
            return focusMarks
        }
    }
}

// MARK: - Game Session
struct GameSession: Codable {
    let id: UUID
    let gameType: String
    let difficulty: String
    let level: Int
    let score: Int
    let completed: Bool
    let date: Date
    
    init(gameType: GameType, difficulty: Difficulty, level: Int, score: Int, completed: Bool) {
        self.id = UUID()
        self.gameType = gameType.rawValue
        self.difficulty = difficulty.rawValue
        self.level = level
        self.score = score
        self.completed = completed
        self.date = Date()
    }
}

// MARK: - Statistics
struct Statistics: Codable {
    var totalSessions: Int = 0
    var totalPlayTime: TimeInterval = 0
    var sessionsPerGame: [String: Int] = [:]
    
    mutating func recordSession(for gameType: GameType) {
        totalSessions += 1
        sessionsPerGame[gameType.rawValue, default: 0] += 1
    }
}

