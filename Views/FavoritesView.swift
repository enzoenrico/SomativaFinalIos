//
//  FavoritesView.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import SwiftUI

struct FavoritesView: View {
  @StateObject private var viewModel = FavoritesViewModel()
  @State private var selectedFavorite: FavoritePokemon?

  var body: some View {
    ZStack {
      DesignTokens.Colors.background
        .ignoresSafeArea()

      if viewModel.isLoading && viewModel.favorites.isEmpty {
        LoadingView(message: "Carregando favoritos...")
      } else if viewModel.favorites.isEmpty {
        emptyState
      } else {
        favoritesList
      }
    }
    .navigationTitle("Favoritos")
    .navigationBarTitleDisplayMode(.large)
    .refreshable {
      viewModel.refresh()
    }
    .sheet(item: $selectedFavorite) { favorite in
      PokemonDetailView(pokemonId: favorite.pokemonId)
        .presentationDetents([.medium, .large])
    }
    .onAppear {
      viewModel.loadFavorites()
    }
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif

  private var emptyState: some View {
    VStack(spacing: DesignTokens.Spacing.lg) {
      Image(systemName: "heart.slash")
        .font(.system(size: 60))
        .foregroundColor(DesignTokens.Colors.onBackground.opacity(0.3))

      Text("Nenhum Favorito")
        .font(DesignTokens.Typography.title2)
        .fontWeight(.bold)
        .foregroundColor(DesignTokens.Colors.onBackground)

      Text("Adicione Pokémon aos seus favoritos para vê-los aqui!")
        .font(DesignTokens.Typography.body)
        .foregroundColor(DesignTokens.Colors.onBackground.opacity(0.7))
        .multilineTextAlignment(.center)
        .padding(.horizontal, DesignTokens.Spacing.xl)
    }
    .padding(DesignTokens.Spacing.xl)
  }

  private var favoritesList: some View {
    ScrollView {
      LazyVStack(spacing: DesignTokens.Spacing.md) {
        ForEach(viewModel.favorites) { favorite in
          FavoriteCardView(favorite: favorite) {
            selectedFavorite = favorite
          } onRemove: {
            withAnimation(.easeInOut(duration: 0.3)) {
              viewModel.removeFromFavorites(favorite)
            }
          }
        }

        if viewModel.isLoading {
          ForEach(0..<3, id: \.self) { _ in
            FavoriteCardSkeletonView()
          }
        }
      }
      .padding(.horizontal, DesignTokens.Spacing.md)
      .padding(.top, DesignTokens.Spacing.md)
    }
  }
}

struct FavoriteCardView: View {
  let favorite: FavoritePokemon
  let onTap: () -> Void
  let onRemove: () -> Void

  @State private var isPressed = false
  @State private var showingRemoveAlert = false

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: DesignTokens.Spacing.md) {
        // Pokemon Image
        AsyncImageView(
          url: favorite.pokemonImageUrl,
          placeholder: Image(systemName: "questionmark.circle"),
          contentMode: .fit
        )
        .frame(width: 80, height: 80)
        .background(
          Circle()
            .fill(DesignTokens.Colors.surface)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        )

        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
          Text("#\(String(format: "%03d", favorite.pokemonId))")
            .font(DesignTokens.Typography.caption1)
            .foregroundColor(DesignTokens.Colors.onSurface.opacity(0.6))

          Text(favorite.pokemonName.capitalized)
            .font(DesignTokens.Typography.headline)
            .foregroundColor(DesignTokens.Colors.onSurface)

          Text("Adicionado em \(favorite.addedAt.formatted(date: .abbreviated, time: .omitted))")
            .font(DesignTokens.Typography.caption2)
            .foregroundColor(DesignTokens.Colors.onSurface.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Button(action: {
          showingRemoveAlert = true
        }) {
          Image(systemName: "heart.fill")
            .foregroundColor(.red)
            .font(.title2)
        }
        .buttonStyle(PlainButtonStyle())
      }
      .padding(DesignTokens.Spacing.md)
    }
    .buttonStyle(PlainButtonStyle())
    .background(
      RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.lg)
        .fill(DesignTokens.Colors.surface)
        .shadow(
          color: isPressed ? DesignTokens.Colors.primary.opacity(0.2) : .black.opacity(0.1),
          radius: isPressed ? 6 : 3,
          x: 0,
          y: isPressed ? 3 : 1
        )
    )
    .scaleEffect(isPressed ? 0.98 : 1.0)
    .animation(.easeInOut(duration: 0.1), value: isPressed)
    .onLongPressGesture(
      minimumDuration: 0,
      maximumDistance: .infinity,
      pressing: { pressing in
        isPressed = pressing
      },
      perform: {}
    )
    .alert("Remover dos Favoritos", isPresented: $showingRemoveAlert) {
      Button("Cancelar", role: .cancel) {}
      Button("Remover", role: .destructive) {
        onRemove()
      }
    } message: {
      Text("Tem certeza que deseja remover \(favorite.pokemonName.capitalized) dos seus favoritos?")
    }
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

struct FavoriteCardSkeletonView: View {
  @State private var isAnimating = false

  var body: some View {
    HStack(spacing: DesignTokens.Spacing.md) {
      Circle()
        .fill(DesignTokens.Colors.onSurface.opacity(0.1))
        .frame(width: 80, height: 80)

      VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
        RoundedRectangle(cornerRadius: 4)
          .fill(DesignTokens.Colors.onSurface.opacity(0.1))
          .frame(width: 60, height: 12)

        RoundedRectangle(cornerRadius: 4)
          .fill(DesignTokens.Colors.onSurface.opacity(0.1))
          .frame(width: 120, height: 16)

        RoundedRectangle(cornerRadius: 4)
          .fill(DesignTokens.Colors.onSurface.opacity(0.1))
          .frame(width: 100, height: 10)
      }
      .frame(maxWidth: .infinity, alignment: .leading)

      Circle()
        .fill(DesignTokens.Colors.onSurface.opacity(0.1))
        .frame(width: 24, height: 24)
    }
    .padding(DesignTokens.Spacing.md)
    .background(
      RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.lg)
        .fill(DesignTokens.Colors.surface)
    )
    .opacity(isAnimating ? 0.5 : 1.0)
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

#Preview {
  FavoritesView()
}
