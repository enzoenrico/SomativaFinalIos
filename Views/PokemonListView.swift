//
//  PokemonListView.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel = PokemonListViewModel()
    @State private var selectedPokemon: PokemonListItem?
    
    // Grid configuration
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: DesignTokens.Spacing.md)
    ]
    
    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                searchBar
                pokemonGrid
            }
        }
        .navigationTitle("Pokédex")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            viewModel.refresh()
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(DesignTokens.Colors.onSurface.opacity(0.6))
            
            TextField("Buscar Pokémon...", text: $viewModel.searchText)
                .textFieldStyle(.plain)
                .font(DesignTokens.Typography.body)
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
                .fill(DesignTokens.Colors.surface)
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.sm)
    }
    
    private var pokemonGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(viewModel.pokemonList) { pokemon in
                    PokemonCardView(pokemon: pokemon) {
                        selectedPokemon = pokemon
                    }
                    .onAppear {
                        viewModel.loadMoreIfNeeded(pokemon: pokemon)
                    }
                }
                
                if viewModel.isLoading {
                    ForEach(0..<4, id: \.self) { _ in
                        PokemonCardSkeletonView()
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.md)
        }
        .sheet(item: $selectedPokemon) { pokemon in
            PokemonDetailView(pokemonId: pokemon.pokemonId)
                .presentationDetents([.medium, .large])
        }
    }
}

struct PokemonCardView: View {
    let pokemon: PokemonListItem
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack() {
                // Pokemon Image
                AsyncImageView(
                    url: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(pokemon.pokemonId).png",
                    placeholder: Image(systemName: "questionmark.circle"),
                    contentMode: .fit
                )
                .frame(height: 120)
                .padding(.top, DesignTokens.Spacing.sm)
                
                VStack(spacing: DesignTokens.Spacing.xs) {
                    Text("#\(String(format: "%03d", pokemon.pokemonId))")
                        .font(DesignTokens.Typography.caption1)
                        .foregroundColor(DesignTokens.Colors.onSurface.opacity(0.6))
                    
                    Text(pokemon.name.capitalized)
                        .font(DesignTokens.Typography.headline)
                        .foregroundColor(DesignTokens.Colors.onSurface)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                .padding(.bottom, DesignTokens.Spacing.md)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.lg)
                .fill(DesignTokens.Colors.surface)
                .shadow(
                    color: isPressed ? DesignTokens.Colors.primary.opacity(0.3) : .black.opacity(0.1),
                    radius: isPressed ? 8 : 4,
                    x: 0,
                    y: isPressed ? 4 : 2
                )
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                isPressed = pressing
            },
            perform: {}
        )
        .onTapGesture {
            onTap()
        }
    }
}

struct PokemonCardSkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
                .fill(DesignTokens.Colors.onSurface.opacity(0.1))
                .frame(height: 120)
                .padding(.top, DesignTokens.Spacing.md)
            
            VStack(spacing: DesignTokens.Spacing.xs) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignTokens.Colors.onSurface.opacity(0.1))
                    .frame(width: 60, height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(DesignTokens.Colors.onSurface.opacity(0.1))
                    .frame(width: 100, height: 16)
            }
            .padding(.bottom, DesignTokens.Spacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.lg)
                .fill(DesignTokens.Colors.surface)
        )
        .opacity(isAnimating ? 0.5 : 1.0)
        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    NavigationView {
        PokemonListView()
    }
}
