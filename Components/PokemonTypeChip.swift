//
//  PokemonTypeChip.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import SwiftUI

struct PokemonTypeChip: View {
    let type: String
    let size: ChipSize
    
    enum ChipSize {
        case small, medium, large
        
        var font: Font {
            switch self {
            case .small: return DesignTokens.Typography.caption2
            case .medium: return DesignTokens.Typography.caption1
            case .large: return DesignTokens.Typography.footnote
            }
        }
        
        var padding: EdgeInsets {
            switch self {
            case .small: return EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
            case .medium: return EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 10)
            case .large: return EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 10
            case .large: return 12
            }
        }
    }
    
    init(type: String, size: ChipSize = .medium) {
        self.type = type
        self.size = size
    }
    
    var body: some View {
        Text(type.capitalized)
            .font(size.font)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(size.padding)
            .background(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .fill(Color.pokemonTypeColor(for: type))
                    .shadow(color: Color.pokemonTypeColor(for: type).opacity(0.3), radius: 2, x: 0, y: 1)
            )
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

struct PokemonTypesView: View {
    let types: [PokemonType]
    let size: PokemonTypeChip.ChipSize
    
    init(types: [PokemonType], size: PokemonTypeChip.ChipSize = .medium) {
        self.types = types
        self.size = size
    }
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            ForEach(types) { pokemonType in
                PokemonTypeChip(type: pokemonType.type.name, size: size)
            }
        }
        .enableInjection()
    }

    #if DEBUG
    @ObserveInjection var forceRedraw
    #endif
}

#Preview {
    VStack(spacing: 16) {
        PokemonTypeChip(type: "fire", size: .small)
        PokemonTypeChip(type: "water", size: .medium)
        PokemonTypeChip(type: "grass", size: .large)
        
        // Multiple types example
        let sampleTypes = [
            PokemonType(slot: 1, type: TypeInfo(name: "fire", url: "")),
            PokemonType(slot: 2, type: TypeInfo(name: "flying", url: ""))
        ]
        
        PokemonTypesView(types: sampleTypes)
    }
    .padding()
}
