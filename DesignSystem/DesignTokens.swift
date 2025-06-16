//
//  DesignTokens.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import SwiftUI

// MARK: - Colors
enum DesignTokens {
    enum Colors {
        static let primary = Color("PrimaryColor") // Azul Pokémon
        static let secondary = Color("SecondaryColor") // Amarelo Pokémon
        static let background = Color("BackgroundColor")
        static let surface = Color("SurfaceColor")
        static let onPrimary = Color.white
        static let onSecondary = Color.black
        static let onBackground = Color("OnBackgroundColor")
        static let onSurface = Color("OnSurfaceColor")
        static let error = Color.red
        static let success = Color.green
        static let warning = Color.orange
        
        // Pokémon Type Colors
        static let typeNormal = Color(hex: "A8A878")
        static let typeFire = Color(hex: "F08030")
        static let typeWater = Color(hex: "6890F0")
        static let typeElectric = Color(hex: "F8D030")
        static let typeGrass = Color(hex: "78C850")
        static let typeIce = Color(hex: "98D8D8")
        static let typeFighting = Color(hex: "C03028")
        static let typePoison = Color(hex: "A040A0")
        static let typeGround = Color(hex: "E0C068")
        static let typeFlying = Color(hex: "A890F0")
        static let typePsychic = Color(hex: "F85888")
        static let typeBug = Color(hex: "A8B820")
        static let typeRock = Color(hex: "B8A038")
        static let typeGhost = Color(hex: "705898")
        static let typeDragon = Color(hex: "7038F8")
        static let typeDark = Color(hex: "705848")
        static let typeSteel = Color(hex: "B8B8D0")
        static let typeFairy = Color(hex: "EE99AC")
    }
    
    enum Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
        static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 17, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
        static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
        static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
        static let caption1 = Font.system(size: 12, weight: .regular, design: .rounded)
        static let caption2 = Font.system(size: 11, weight: .regular, design: .rounded)
    }
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    enum BorderRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let round: CGFloat = 50
    }
    
    enum Shadow {
        static let small = (color: Color.black.opacity(0.1), radius: CGFloat(2), x: CGFloat(0), y: CGFloat(1))
        static let medium = (color: Color.black.opacity(0.15), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let large = (color: Color.black.opacity(0.2), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // cores pros tipos do pokemon
    // muito legal btw!!
    static func pokemonTypeColor(for type: String) -> Color {
        switch type.lowercased() {
        case "normal": return DesignTokens.Colors.typeNormal
        case "fire": return DesignTokens.Colors.typeFire
        case "water": return DesignTokens.Colors.typeWater
        case "electric": return DesignTokens.Colors.typeElectric
        case "grass": return DesignTokens.Colors.typeGrass
        case "ice": return DesignTokens.Colors.typeIce
        case "fighting": return DesignTokens.Colors.typeFighting
        case "poison": return DesignTokens.Colors.typePoison
        case "ground": return DesignTokens.Colors.typeGround
        case "flying": return DesignTokens.Colors.typeFlying
        case "psychic": return DesignTokens.Colors.typePsychic
        case "bug": return DesignTokens.Colors.typeBug
        case "rock": return DesignTokens.Colors.typeRock
        case "ghost": return DesignTokens.Colors.typeGhost
        case "dragon": return DesignTokens.Colors.typeDragon
        case "dark": return DesignTokens.Colors.typeDark
        case "steel": return DesignTokens.Colors.typeSteel
        case "fairy": return DesignTokens.Colors.typeFairy
        default: return DesignTokens.Colors.typeNormal
        }
    }
}
