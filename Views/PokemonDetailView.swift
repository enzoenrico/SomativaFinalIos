//
//  PokemonDetailView.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import SwiftUI

struct PokemonDetailView: View {
  let pokemonId: Int
  @StateObject private var viewModel: PokemonDetailViewModel
  @Environment(\.dismiss) private var dismiss

  init(pokemonId: Int) {
    self.pokemonId = pokemonId
    self._viewModel = StateObject(wrappedValue: PokemonDetailViewModel(pokemonId: pokemonId))
  }

  var body: some View {
    ZStack {
      if let pokemon = viewModel.pokemon {
        backgroundGradient(for: pokemon)
          .ignoresSafeArea()

        ScrollView {
          VStack(spacing: DesignTokens.Spacing.lg) {
            headerSection(pokemon: pokemon)
            basicInfoSection(pokemon: pokemon)
            typesSection(pokemon: pokemon)
            statsSection(pokemon: pokemon)
            abilitiesSection(pokemon: pokemon)
            movesSection(pokemon: pokemon)
          }
          .padding(.horizontal, DesignTokens.Spacing.md)
          .padding(.top, DesignTokens.Spacing.lg)
        }
      } else if viewModel.isLoading {
        PokeBallLoadingView()
      } else if let errorMessage = viewModel.errorMessage {
        ErrorView(message: errorMessage) {
          viewModel.loadPokemon()
        }
      }
    }

  }

  private func backgroundGradient(for pokemon: Pokemon) -> some View {
    let primaryType = pokemon.types.first?.type.name ?? "normal"
    let primaryColor = Color.pokemonTypeColor(for: primaryType)
    let secondaryColor =
      pokemon.types.count > 1
      ? Color.pokemonTypeColor(for: pokemon.types[1].type.name)
      : primaryColor.opacity(0.7)

    return LinearGradient(
      colors: [primaryColor, secondaryColor],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private func headerSection(pokemon: Pokemon) -> some View {
    VStack(spacing: DesignTokens.Spacing.md) {
      HStack {
        favoriteButton
        Text("#\(String(format: "%03d", pokemon.id))")
          .font(DesignTokens.Typography.title2)
          .foregroundColor(.white.opacity(0.8))

        Spacer()

        Text(pokemon.formattedName)
          .font(DesignTokens.Typography.largeTitle)
          .fontWeight(.bold)
          .foregroundColor(.white)
      }

      AsyncImageView(
        url: pokemon.sprites.mainImageUrl,
        placeholder: Image(systemName: "questionmark.circle"),
        contentMode: .fit
      )
      .frame(height: 200)
      .background(
        Circle()
          .fill(.white.opacity(0.2))
          .frame(width: 220, height: 220)
      )
      .scaleEffect(1.0)
      .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.pokemon != nil)
    }
  }

  private func basicInfoSection(pokemon: Pokemon) -> some View {
    HStack(spacing: DesignTokens.Spacing.lg) {
      InfoCard(
        title: "Altura",
        value: String(format: "%.1f m", pokemon.heightInMeters),
        icon: "ruler"
      )

      InfoCard(
        title: "Peso",
        value: String(format: "%.1f kg", pokemon.weightInKilograms),
        icon: "scalemass"
      )

      if let baseExp = pokemon.baseExperience {
        InfoCard(
          title: "Exp. Base",
          value: "\(baseExp)",
          icon: "star.fill"
        )
      }
    }
  }

  private func typesSection(pokemon: Pokemon) -> some View {
    SectionCard(title: "Tipos", icon: "tag.fill") {
      PokemonTypesView(types: viewModel.mainTypes, size: .large)
    }
  }

  private func statsSection(pokemon: Pokemon) -> some View {
    SectionCard(title: "Estatísticas", icon: "chart.bar.fill") {
      VStack(spacing: DesignTokens.Spacing.sm) {
        ForEach(pokemon.stats) { stat in
          StatBarView(
            name: stat.stat.formattedName,
            value: stat.baseStat,
            maxValue: viewModel.statMaxValue
          )
        }
      }
    }
  }

  private func abilitiesSection(pokemon: Pokemon) -> some View {
    SectionCard(title: "Habilidades", icon: "bolt.fill") {
      VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
        ForEach(viewModel.mainAbilities) { ability in
          HStack {
            Text(ability.ability.formattedName)
              .font(DesignTokens.Typography.body)
              .foregroundColor(DesignTokens.Colors.onSurface)

            Spacer()

            if ability.isHidden {
              Text("Oculta")
                .font(DesignTokens.Typography.caption1)
                .padding(.horizontal, DesignTokens.Spacing.xs)
                .padding(.vertical, 2)
                .background(
                  RoundedRectangle(cornerRadius: 4)
                    .fill(DesignTokens.Colors.warning.opacity(0.2))
                )
                .foregroundColor(DesignTokens.Colors.warning)
            }
          }
        }
      }
    }
  }

  private func movesSection(pokemon: Pokemon) -> some View {
    SectionCard(title: "Movimentos", icon: "gamecontroller.fill") {
      LazyVGrid(
        columns: [
          GridItem(.flexible()),
          GridItem(.flexible()),
        ],
      ) {
        ForEach(viewModel.mainMoves) { move in
          Text(move.move.formattedName)
            .font(DesignTokens.Typography.footnote)
            .foregroundColor(DesignTokens.Colors.onSurface)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
              RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.sm)
                .fill(DesignTokens.Colors.surface.opacity(0.8))
            )
        }
      }
    }
    .preferredColorScheme(.light)
  }

  private var favoriteButton: some View {
    Button(action: {
      viewModel.toggleFavorite()
    }) {
      Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
        .foregroundColor(viewModel.isFavorite ? .red : .white)
        .font(.title2)
        .scaleEffect(viewModel.isAddingToFavorites ? 1.2 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isFavorite)
    }
    .disabled(viewModel.isAddingToFavorites)
  }
}

// MARK: - Supporting Views
struct InfoCard: View {
  let title: String
  let value: String
  let icon: String

  var body: some View {
    VStack(spacing: DesignTokens.Spacing.xs) {
      Image(systemName: icon)
        .font(.title2)
        .foregroundColor(.white.opacity(0.8))

      Text(value)
        .font(DesignTokens.Typography.headline)
        .fontWeight(.bold)
        .foregroundColor(.white)

      Text(title)
        .font(DesignTokens.Typography.caption1)
        .foregroundColor(.white.opacity(0.7))
    }
    .frame(maxWidth: .infinity)
    .padding(DesignTokens.Spacing.md)
    .background(
      RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
        .fill(.white.opacity(0.2))
    )
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

struct SectionCard<Content: View>: View {
  let title: String
  let icon: String
  let content: Content

  init(title: String, icon: String, @ViewBuilder content: () -> Content) {
    self.title = title
    self.icon = icon
    self.content = content()
  }

  var body: some View {
    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
      HStack {
        Image(systemName: icon)
          .foregroundColor(DesignTokens.Colors.primary)

        Text(title)
          .font(DesignTokens.Typography.title3)
          .fontWeight(.bold)
          .foregroundColor(DesignTokens.Colors.onSurface)

        Spacer()
      }

      content
    }
    .padding(DesignTokens.Spacing.md)
    .background(
      RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.lg)
        .fill(.white.opacity(0.9))
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    )
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

struct StatBarView: View {
  let name: String
  let value: Int
  let maxValue: Int

  @State private var animatedValue: CGFloat = 0

  var body: some View {
    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
      HStack {
        Text(name)
          .font(DesignTokens.Typography.callout)
          .foregroundColor(DesignTokens.Colors.onSurface)

        Spacer()

        Text("\(value)")
          .font(DesignTokens.Typography.callout)
          .fontWeight(.bold)
          .foregroundColor(DesignTokens.Colors.primary)
      }

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: 4)
            .fill(DesignTokens.Colors.onSurface.opacity(0.1))
            .frame(height: 8)

          RoundedRectangle(cornerRadius: 4)
            .fill(statColor(for: value))
            .frame(
              width: geometry.size.width * animatedValue,
              height: 8
            )
            .animation(.easeInOut(duration: 0.8), value: animatedValue)
        }
      }
      .frame(height: 8)
    }
    .onAppear {
      animatedValue = CGFloat(value) / CGFloat(maxValue)
    }
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif

  private func statColor(for value: Int) -> Color {
    switch value {
    case 0...59: return DesignTokens.Colors.error
    case 60...89: return DesignTokens.Colors.warning
    case 90...119: return DesignTokens.Colors.success
    default: return DesignTokens.Colors.primary
    }
  }
}

struct ErrorView: View {
  let message: String
  let onRetry: () -> Void

  var body: some View {
    VStack(spacing: DesignTokens.Spacing.lg) {
      Image(systemName: "exclamationmark.triangle")
        .font(.system(size: 50))
        .foregroundColor(DesignTokens.Colors.error)

      Text("Oops!")
        .font(DesignTokens.Typography.title1)
        .fontWeight(.bold)
        .foregroundColor(DesignTokens.Colors.onBackground)

      Text(message)
        .font(DesignTokens.Typography.body)
        .foregroundColor(DesignTokens.Colors.onBackground)
        .multilineTextAlignment(.center)
        .padding(.horizontal, DesignTokens.Spacing.lg)

      Button("Tentar Novamente") {
        onRetry()
      }
      .padding(.horizontal, DesignTokens.Spacing.lg)
      .padding(.vertical, DesignTokens.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
          .fill(DesignTokens.Colors.primary)
      )
      .foregroundColor(.white)
      .font(DesignTokens.Typography.headline)
    }
    .padding(DesignTokens.Spacing.xl)
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

#Preview {
  PokemonDetailView(pokemonId: 1)
}
