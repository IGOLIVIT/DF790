//
//  OnboardingView.swift
//  DF790
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject var gameManager: GameManager
    @State private var currentPage = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color("DeepBlack").ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage1(isAnimating: $isAnimating)
                    .tag(0)
                
                OnboardingPage2(isAnimating: $isAnimating)
                    .tag(1)
                
                OnboardingPage3(isAnimating: $isAnimating, onStart: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        gameManager.hasCompletedOnboarding = true
                    }
                })
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom page indicator - only show on pages 0 and 1, not on the last page with Start button
            if currentPage < 2 {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color("NeonRed") : Color("SubtleGray").opacity(0.5))
                                .frame(width: currentPage == index ? 24 : 8, height: 8)
                                .animation(.spring(response: 0.3), value: currentPage)
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Page 1: Focus and Timing
struct OnboardingPage1: View {
    @Binding var isAnimating: Bool
    @State private var shapesOpacity: [Double] = [0, 0, 0, 0]
    @State private var shapesScale: [CGFloat] = [0.5, 0.5, 0.5, 0.5]
    @State private var textOpacity: Double = 0
    @State private var assemblyProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Animated glowing shapes
                ForEach(0..<4, id: \.self) { index in
                    GlowingShape(index: index, assemblyProgress: assemblyProgress)
                        .opacity(shapesOpacity[index])
                        .scaleEffect(shapesScale[index])
                        .offset(shapeOffset(for: index, size: geometry.size, progress: assemblyProgress))
                }
                
                // Central glow when assembled
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("NeonRed").opacity(0.4 * assemblyProgress),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 20)
                
                // Text content
                VStack(spacing: 16) {
                    Spacer()
                    
                    Text("Master Your Focus")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color("WarmWhite"))
                    
                    Text("Every challenge requires precision.\nTiming is everything.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(Color("SubtleGray"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)
                }
                .opacity(textOpacity)
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Staggered shape appearances
        for i in 0..<4 {
            withAnimation(.easeOut(duration: 0.8).delay(Double(i) * 0.2)) {
                shapesOpacity[i] = 1
                shapesScale[i] = 1
            }
        }
        
        // Assembly animation
        withAnimation(.easeInOut(duration: 2).delay(1)) {
            assemblyProgress = 1
        }
        
        // Text fade in
        withAnimation(.easeIn(duration: 0.8).delay(1.5)) {
            textOpacity = 1
        }
    }
    
    private func shapeOffset(for index: Int, size: CGSize, progress: CGFloat) -> CGSize {
        let spread: CGFloat = 80
        let baseOffsets: [CGSize] = [
            CGSize(width: -spread, height: -spread - 50),
            CGSize(width: spread, height: -spread - 50),
            CGSize(width: -spread, height: spread - 50),
            CGSize(width: spread, height: spread - 50)
        ]
        
        let offset = baseOffsets[index]
        return CGSize(
            width: offset.width * (1 - progress * 0.8),
            height: offset.height * (1 - progress * 0.8)
        )
    }
}

struct GlowingShape: View {
    let index: Int
    let assemblyProgress: CGFloat
    
    var body: some View {
        Group {
            switch index % 4 {
            case 0:
                Circle()
                    .fill(Color("NeonRed").opacity(0.8))
                    .frame(width: 40, height: 40)
                    .blur(radius: 5 * (1 - assemblyProgress))
            case 1:
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("SoftGold").opacity(0.8))
                    .frame(width: 35, height: 35)
                    .rotationEffect(.degrees(45))
                    .blur(radius: 5 * (1 - assemblyProgress))
            case 2:
                Circle()
                    .fill(Color("MutedRedGlow").opacity(0.8))
                    .frame(width: 30, height: 30)
                    .blur(radius: 5 * (1 - assemblyProgress))
            default:
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color("NeonRed").opacity(0.6))
                    .frame(width: 45, height: 25)
                    .blur(radius: 5 * (1 - assemblyProgress))
            }
        }
        .shadow(color: Color("NeonRed").opacity(0.5), radius: 10)
    }
}

// MARK: - Page 2: Progress and Mastery
struct OnboardingPage2: View {
    @Binding var isAnimating: Bool
    @State private var lightY: CGFloat = -200
    @State private var textOpacity: Double = 0
    @State private var progressBars: [CGFloat] = [0, 0, 0]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vertical light beam
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color("SoftGold").opacity(0.3),
                                Color("SoftGold").opacity(0.6),
                                Color("SoftGold").opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 4, height: 300)
                    .offset(y: lightY)
                    .blur(radius: 2)
                
                // Progress visualization
                VStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { index in
                        HStack {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color("DarkGraphite"))
                                .frame(width: 200, height: 8)
                                .overlay(
                                    GeometryReader { barGeometry in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color("NeonRed"), Color("SoftGold")],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: barGeometry.size.width * progressBars[index])
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                .offset(y: -50)
                
                // Text content
                VStack(spacing: 16) {
                    Spacer()
                    
                    Text("Rise Through Mastery")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color("WarmWhite"))
                    
                    Text("Track your growth.\nEvery session makes you sharper.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(Color("SubtleGray"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.15)
                }
                .opacity(textOpacity)
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Light movement
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            lightY = 200
        }
        
        // Progress bars
        for i in 0..<3 {
            withAnimation(.easeOut(duration: 1.2).delay(Double(i) * 0.3 + 0.5)) {
                progressBars[i] = [0.7, 0.85, 0.55][i]
            }
        }
        
        // Text
        withAnimation(.easeIn(duration: 0.8).delay(0.8)) {
            textOpacity = 1
        }
    }
}

// MARK: - Page 3: Short Sessions
struct OnboardingPage3: View {
    @Binding var isAnimating: Bool
    let onStart: () -> Void
    
    @State private var pathPulse: CGFloat = 0
    @State private var glowIntensity: Double = 0.3
    @State private var textOpacity: Double = 0
    @State private var buttonOpacity: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Pulsing neon path
                NeonPath()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color("NeonRed").opacity(glowIntensity),
                                Color("MutedRedGlow").opacity(glowIntensity * 0.7),
                                Color("NeonRed").opacity(glowIntensity)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 250, height: 100)
                    .shadow(color: Color("NeonRed").opacity(glowIntensity), radius: 15)
                    .offset(y: -80)
                
                // Traveling pulse on path
                Circle()
                    .fill(Color("SoftGold"))
                    .frame(width: 12, height: 12)
                    .shadow(color: Color("SoftGold"), radius: 10)
                    .offset(x: -125 + pathPulse * 250, y: sin(pathPulse * .pi * 2) * 30 - 80)
                
                // Text content
                VStack(spacing: 16) {
                    Spacer()
                    
                    Text("Quick Sessions, Deep Skill")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color("WarmWhite"))
                    
                    Text("Play anytime.\nBuild lasting precision in minutes.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .foregroundColor(Color("SubtleGray"))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                    
                    Spacer()
                        .frame(height: 24)
                    
                    // Page indicator on page 3
                    HStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { index in
                            Capsule()
                                .fill(index == 2 ? Color("NeonRed") : Color("SubtleGray").opacity(0.5))
                                .frame(width: index == 2 ? 24 : 8, height: 8)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 24)
                    
                    PrimaryButton(title: "Start", action: onStart)
                        .padding(.horizontal, 60)
                        .opacity(buttonOpacity)
                    
                    Spacer()
                        .frame(height: geometry.size.height * 0.08)
                }
                .opacity(textOpacity)
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Path pulse movement
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            pathPulse = 1
        }
        
        // Glow intensity
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowIntensity = 0.8
        }
        
        // Text
        withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
            textOpacity = 1
        }
        
        // Button
        withAnimation(.easeIn(duration: 0.6).delay(0.8)) {
            buttonOpacity = 1
        }
    }
}

struct NeonPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        path.addCurve(
            to: CGPoint(x: rect.width * 0.33, y: rect.midY - 30),
            control1: CGPoint(x: rect.width * 0.15, y: rect.midY),
            control2: CGPoint(x: rect.width * 0.25, y: rect.midY - 30)
        )
        
        path.addCurve(
            to: CGPoint(x: rect.width * 0.66, y: rect.midY + 30),
            control1: CGPoint(x: rect.width * 0.45, y: rect.midY - 30),
            control2: CGPoint(x: rect.width * 0.55, y: rect.midY + 30)
        )
        
        path.addCurve(
            to: CGPoint(x: rect.width, y: rect.midY),
            control1: CGPoint(x: rect.width * 0.8, y: rect.midY + 30),
            control2: CGPoint(x: rect.width * 0.9, y: rect.midY)
        )
        
        return path
    }
}

#Preview {
    OnboardingView(gameManager: GameManager.shared)
}

