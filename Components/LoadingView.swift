//
//  LoadingView.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    @State private var isAnimating = false
    
    init(message: String = "Carregando...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ProgressView()
                .scaleEffect(1.5)
                .progressViewStyle(CircularProgressViewStyle(tint: DesignTokens.Colors.primary))
            
            Text(message)
                .font(DesignTokens.Typography.callout)
                .foregroundColor(DesignTokens.Colors.onBackground)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.lg)
                .fill(DesignTokens.Colors.surface)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct PokeBallLoadingView: View {
    @State private var isRotating = false
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Image(.coloredPokeball)
            }
            .rotationEffect(.degrees(isRotating ? 360 : 0))
            .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isRotating)
            .onAppear {
                isRotating = true
            }
            
            Text("Procurando Pokémon...")
                .font(DesignTokens.Typography.callout)
                .foregroundColor(DesignTokens.Colors.onBackground)
        }
        .padding(DesignTokens.Spacing.xl)
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview("Loading View") {
    LoadingView(message: "Carregando Pokémon...")
}

#Preview("PokeBall Loading") {
    PokeBallLoadingView()
}
