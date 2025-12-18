//
//  SettingsView.swift
//  DF790
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var showResetConfirmation = false
    @State private var resetConfirmed = false
    
    var body: some View {
        ZStack {
            Color("DeepBlack").ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Header
                    VStack(spacing: 12) {
                        Text("Settings")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color("WarmWhite"))
                        
                        Text("Manage your experience")
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(Color("SubtleGray"))
                    }
                    
                    // Statistics summary
                    statisticsSection
                    
                    // Reset section
                    resetSection
                    
                    Spacer()
                        .frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
            
            // Reset confirmation overlay
            if showResetConfirmation {
                resetConfirmationOverlay
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
    }
    
    // MARK: - Statistics Section
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Statistics Summary")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color("WarmWhite"))
            
            VStack(spacing: 0) {
                StatRow(label: "Total Sessions", value: "\(gameManager.statistics.totalSessions)", icon: "flame.fill", color: Color("NeonRed"))
                
                Divider()
                    .background(Color("SubtleGray").opacity(0.2))
                
                StatRow(label: "Overall Mastery", value: "\(Int(overallMastery))%", icon: "star.fill", color: Color("SoftGold"))
                
                Divider()
                    .background(Color("SubtleGray").opacity(0.2))
                
                StatRow(label: "Levels Completed", value: "\(totalCompletedLevels) / \(totalLevels)", icon: "checkmark.circle.fill", color: Color("SoftGold"))
                
                Divider()
                    .background(Color("SubtleGray").opacity(0.2))
                
                StatRow(label: "Energy Shards", value: "\(gameManager.rewards.energyShards)", icon: "bolt.fill", color: Color("NeonRed"))
                
                Divider()
                    .background(Color("SubtleGray").opacity(0.2))
                
                StatRow(label: "Signal Fragments", value: "\(gameManager.rewards.signalFragments)", icon: "waveform", color: Color("SoftGold"))
                
                Divider()
                    .background(Color("SubtleGray").opacity(0.2))
                
                StatRow(label: "Focus Marks", value: "\(gameManager.rewards.focusMarks)", icon: "scope", color: Color("MutedRedGlow"))
            }
            .padding(.vertical, 8)
            .background(Color("DarkGraphite"))
            .cornerRadius(16)
        }
    }
    
    private var overallMastery: Double {
        let masteries = GameType.allCases.map { gameManager.masteryPercentage(for: $0) }
        return masteries.reduce(0, +) / Double(max(masteries.count, 1))
    }
    
    private var totalCompletedLevels: Int {
        GameType.allCases.reduce(0) { $0 + gameManager.totalCompletedLevels(for: $1) }
    }
    
    private var totalLevels: Int {
        GameType.allCases.reduce(0) { $0 + gameManager.totalLevels(for: $1) }
    }
    
    // MARK: - Reset Section
    private var resetSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Data Management")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color("WarmWhite"))
            
            Button(action: {
                withAnimation(.spring(response: 0.3)) {
                    showResetConfirmation = true
                }
            }) {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18))
                        .foregroundColor(Color("MutedRedGlow"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reset Progress")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("WarmWhite"))
                        
                        Text("Clear all progress and start fresh")
                            .font(.system(size: 13, weight: .regular, design: .rounded))
                            .foregroundColor(Color("SubtleGray"))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color("SubtleGray"))
                }
                .padding(16)
                .background(Color("DarkGraphite"))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("MutedRedGlow").opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Reset Confirmation Overlay
    private var resetConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.3)) {
                        showResetConfirmation = false
                    }
                }
            
            VStack(spacing: 24) {
                // Warning icon
                ZStack {
                    Circle()
                        .fill(Color("MutedRedGlow").opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color("MutedRedGlow"))
                }
                
                VStack(spacing: 12) {
                    Text("Reset All Progress?")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color("WarmWhite"))
                    
                    Text("This will permanently delete all your progress, rewards, and statistics. This action cannot be undone.")
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundColor(Color("SubtleGray"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                VStack(spacing: 12) {
                    Button(action: {
                        gameManager.resetProgress()
                        withAnimation(.spring(response: 0.3)) {
                            showResetConfirmation = false
                        }
                    }) {
                        Text("Reset Everything")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("DeepBlack"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("MutedRedGlow"))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            showResetConfirmation = false
                        }
                    }) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("WarmWhite"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color("DarkGraphite"))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color("SubtleGray").opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 30)
            }
            .padding(30)
            .background(Color("DeepBlack"))
            .cornerRadius(24)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color("MutedRedGlow").opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 30)
            .shadow(color: Color("MutedRedGlow").opacity(0.2), radius: 30, x: 0, y: 10)
        }
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(Color("SubtleGray"))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(Color("WarmWhite"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        SettingsView(gameManager: GameManager.shared)
    }
}

