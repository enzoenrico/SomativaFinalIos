//
//  MainTabView.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        TabView {
            NavigationView {
                PokemonListView()
            }
            .tabItem {
                Label("Pokédex", systemImage: "list.bullet")
            }
            
            NavigationView {
                FavoritesView()
            }
            .tabItem {
                Label("Favoritos", systemImage: "heart.fill")
            }
            
            NavigationView {
                ProfileView()
            }
            .tabItem {
                Label("Perfil", systemImage: "person.fill")
            }
        }
        .accentColor(DesignTokens.Colors.primary)
    }
}

struct ProfileView: View {
    @StateObject private var authService = AuthService.shared
    @State private var showingLogoutAlert = false
    
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: DesignTokens.Spacing.xl) {
                profileHeader
                
                profileInfo
                
                Spacer()
                
                logoutButton
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.xl)
        }
        .navigationTitle("Perfil")
        .navigationBarTitleDisplayMode(.large)
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
    
    private var profileHeader: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            // Profile Avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DesignTokens.Colors.primary, DesignTokens.Colors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Text(authService.currentUser?.username.first?.uppercased() ?? "?")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .shadow(color: DesignTokens.Colors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            
            if let user = authService.currentUser {
                Text(user.username)
                    .font(DesignTokens.Typography.title2)
                    .fontWeight(.bold)
                    .foregroundColor(DesignTokens.Colors.onBackground)
                
                Text(user.email)
                    .font(DesignTokens.Typography.callout)
                    .foregroundColor(DesignTokens.Colors.onBackground.opacity(0.7))
            }
        }
    }
    
    private var profileInfo: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            if let user = authService.currentUser {
                ProfileInfoCard(
                    title: "Membro desde",
                    value: user.createdAt.formatted(date: .abbreviated, time: .omitted),
                    icon: "calendar"
                )
                
                // You could add more info cards here like:
                // - Number of favorites
                // - Last activity
                // - Achievements, etc.
            }
        }
    }
    
    private var logoutButton: some View {
        Button(action: {
            showingLogoutAlert = true
        }) {
            HStack {
                Image(systemName: "arrow.right.square")
                Text("Sair")
            }
            .font(DesignTokens.Typography.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
                    .fill(DesignTokens.Colors.error)
            )
        }
        .alert("Sair da Conta", isPresented: $showingLogoutAlert) {
            Button("Cancelar", role: .cancel) { }
            Button("Sair", role: .destructive) {
                authService.logout()
            }
        } message: {
            Text("Tem certeza que deseja sair da sua conta?")
        }
    }
}

struct ProfileInfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(DesignTokens.Colors.primary)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(DesignTokens.Typography.caption1)
                    .foregroundColor(DesignTokens.Colors.onSurface.opacity(0.7))
                
                Text(value)
                    .font(DesignTokens.Typography.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(DesignTokens.Colors.onSurface)
            }
            
            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
                .fill(DesignTokens.Colors.surface)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview("Main Tab View") {
    MainTabView()
}

#Preview("Profile View") {
    ProfileView()
}
