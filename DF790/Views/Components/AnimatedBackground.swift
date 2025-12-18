//
//  AnimatedBackground.swift
//  DF790
//

import SwiftUI

struct AnimatedBackground: View {
    @State private var animateGradient = false
    @State private var lightPosition: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color("DeepBlack"),
                    Color("DarkGraphite").opacity(0.8),
                    Color("DeepBlack")
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            
            // Moving light orbs
            GeometryReader { geometry in
                ZStack {
                    // Primary glow orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("NeonRed").opacity(0.3),
                                    Color("NeonRed").opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geometry.size.width * 0.4
                            )
                        )
                        .frame(width: geometry.size.width * 0.8, height: geometry.size.width * 0.8)
                        .offset(
                            x: cos(lightPosition) * geometry.size.width * 0.2,
                            y: sin(lightPosition * 0.7) * geometry.size.height * 0.15
                        )
                        .scaleEffect(pulseScale)
                    
                    // Secondary gold accent orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("SoftGold").opacity(0.15),
                                    Color("SoftGold").opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geometry.size.width * 0.3
                            )
                        )
                        .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.6)
                        .offset(
                            x: sin(lightPosition * 1.3) * geometry.size.width * 0.25,
                            y: cos(lightPosition * 0.9) * geometry.size.height * 0.2 + geometry.size.height * 0.3
                        )
                }
            }
            
            // Subtle noise overlay
            Rectangle()
                .fill(Color("DeepBlack").opacity(0.3))
                .ignoresSafeArea()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                lightPosition = .pi * 2
            }
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                pulseScale = 1.15
            }
        }
    }
}

struct GlowingCard: ViewModifier {
    var color: Color = Color("NeonRed")
    var cornerRadius: CGFloat = 20
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color("DarkGraphite"))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: color.opacity(0.2), radius: 20, x: 0, y: 10)
            )
    }
}

extension View {
    func glowingCard(color: Color = Color("NeonRed"), cornerRadius: CGFloat = 20) -> some View {
        modifier(GlowingCard(color: color, cornerRadius: cornerRadius))
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var width: CGFloat? = nil
    
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
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color("DeepBlack"))
                .frame(maxWidth: width ?? .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [Color("NeonRed"), Color("MutedRedGlow")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color("NeonRed").opacity(0.4), radius: isPressed ? 5 : 15, x: 0, y: isPressed ? 2 : 8)
                .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var width: CGFloat? = nil
    
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
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color("WarmWhite"))
                .frame(maxWidth: width ?? .infinity)
                .frame(height: 56)
                .background(Color("DarkGraphite"))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("NeonRed").opacity(0.5), lineWidth: 1.5)
                )
                .shadow(color: Color("NeonRed").opacity(0.2), radius: isPressed ? 3 : 10, x: 0, y: isPressed ? 1 : 5)
                .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        AnimatedBackground()
        VStack(spacing: 20) {
            PrimaryButton(title: "Play", action: {})
                .padding(.horizontal, 40)
            SecondaryButton(title: "Settings", action: {})
                .padding(.horizontal, 40)
        }
    }
}

