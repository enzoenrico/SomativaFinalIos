//
//  AuthView.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import SwiftUI

struct AuthView: View {
  @StateObject private var viewModel = AuthViewModel()
  @State private var isShowingLogin = true

  var body: some View {

    VStack(spacing: DesignTokens.Spacing.xl) {
      headerView

      tabSelector

      if isShowingLogin {
        LoginView(viewModel: viewModel)
          .transition(
            .asymmetric(
              insertion: .move(edge: .leading),
              removal: .move(edge: .trailing)
            ))
      } else {
        RegisterView(viewModel: viewModel)
          .transition(
            .asymmetric(
              insertion: .move(edge: .trailing),
              removal: .move(edge: .leading)
            ))
      }

    }
    .padding(.horizontal, DesignTokens.Spacing.lg)
    .padding(.top, DesignTokens.Spacing.xxl)
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif

  private var backgroundGradient: some View {
    LinearGradient(
      colors: [
        DesignTokens.Colors.primary,
        DesignTokens.Colors.secondary.opacity(0.8),
        DesignTokens.Colors.primary,
      ],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
  }

  private var headerView: some View {
    VStack(spacing: DesignTokens.Spacing.md) {
      // Pokeball Icon
      ZStack {
        Image("coloredPokeball")
      }
      .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

      Text("Pokédex")
        .font(DesignTokens.Typography.largeTitle)
        .fontWeight(.bold)
        .foregroundColor(.white)

      Text("Explore o universo Pokémon")
        .font(DesignTokens.Typography.callout)
        .foregroundColor(.white.opacity(0.8))
    }
  }

  private var tabSelector: some View {
    HStack(spacing: 0) {
      TabButton(
        title: "Entrar",
        isSelected: isShowingLogin,
        action: {
          withAnimation(.easeInOut(duration: 0.3)) {
            isShowingLogin = true
          }
        }
      )

      TabButton(
        title: "Cadastrar",
        isSelected: !isShowingLogin,
        action: {
          withAnimation(.easeInOut(duration: 0.3)) {
            isShowingLogin = false
          }
        }
      )
    }
    .background(
      RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
        .fill(.white.opacity(0.2))
    )
  }
}

struct TabButton: View {
  let title: String
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(DesignTokens.Typography.headline)
        .fontWeight(.semibold)
        .foregroundColor(isSelected ? .black : .white.opacity(0.7))
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(
          RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
            .fill(isSelected ? .white : .clear)
        )
    }
    .buttonStyle(PlainButtonStyle())
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

struct LoginView: View {
  @ObservedObject var viewModel: AuthViewModel
  @FocusState private var focusedField: Field?

  enum Field {
    case email, password
  }

  var body: some View {
    VStack(spacing: DesignTokens.Spacing.lg) {
      VStack(spacing: DesignTokens.Spacing.md) {
        CustomTextField(
          title: "Email",
          text: $viewModel.loginEmail,
          keyboardType: .emailAddress,
          icon: "envelope"
        )
        .focused($focusedField, equals: .email)
        .textContentType(.emailAddress)
        .autocapitalization(.none)

        CustomTextField(
          title: "Senha",
          text: $viewModel.loginPassword,
          isSecure: true,
          icon: "lock"
        )
        .focused($focusedField, equals: .password)
        .textContentType(.password)
      }

      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
      }

      ActionButton(
        title: "Entrar",
        isLoading: viewModel.isLoading,
        isEnabled: viewModel.isValidLogin,
        action: {
          focusedField = nil
          viewModel.login()
        }
      )
    }
    .onSubmit {
      switch focusedField {
      case .email:
        focusedField = .password
      case .password:
        viewModel.login()
      case .none:
        break
      }
    }
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

struct RegisterView: View {
  @ObservedObject var viewModel: AuthViewModel
  @FocusState private var focusedField: Field?

  enum Field {
    case username, email, password, confirmPassword
  }

  var body: some View {
    VStack(spacing: DesignTokens.Spacing.lg) {
      VStack(spacing: DesignTokens.Spacing.md) {
        CustomTextField(
          title: "Nome de Usuário",
          text: $viewModel.registerUsername,
          icon: "person"
        )
        .focused($focusedField, equals: .username)
        .textContentType(.username)

        CustomTextField(
          title: "Email",
          text: $viewModel.registerEmail,
          keyboardType: .emailAddress,
          icon: "envelope"
        )
        .focused($focusedField, equals: .email)
        .textContentType(.emailAddress)
        .autocapitalization(.none)

        CustomTextField(
          title: "Senha",
          text: $viewModel.registerPassword,
          isSecure: true,
          icon: "lock"
        )
        .focused($focusedField, equals: .password)
        .textContentType(.newPassword)

        CustomTextField(
          title: "Confirmar Senha",
          text: $viewModel.registerConfirmPassword,
          isSecure: true,
          icon: "lock.fill"
        )
        .focused($focusedField, equals: .confirmPassword)
        .textContentType(.newPassword)
      }

      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
      }

      ActionButton(
        title: "Cadastrar",
        isLoading: viewModel.isLoading,
        isEnabled: viewModel.isValidRegistration,
        action: {
          focusedField = nil
          viewModel.register()
        }
      )
    }
    .onSubmit {
      switch focusedField {
      case .username:
        focusedField = .email
      case .email:
        focusedField = .password
      case .password:
        focusedField = .confirmPassword
      case .confirmPassword:
        viewModel.register()
      case .none:
        break
      }
    }
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

struct CustomTextField: View {
  let title: String
  @Binding var text: String
  let keyboardType: UIKeyboardType
  let isSecure: Bool
  let icon: String

  init(
    title: String,
    text: Binding<String>,
    keyboardType: UIKeyboardType = .default,
    isSecure: Bool = false,
    icon: String
  ) {
    self.title = title
    self._text = text
    self.keyboardType = keyboardType
    self.isSecure = isSecure
    self.icon = icon
  }

  var body: some View {
    HStack(spacing: DesignTokens.Spacing.md) {
      Image(systemName: icon)
        .foregroundColor(.white.opacity(0.7))
        .frame(width: 20)

      if isSecure {
        SecureField(title, text: $text)
          .textFieldStyle()
      } else {
        TextField(title, text: $text)
          .keyboardType(keyboardType)
          .textFieldStyle()
      }
    }
    .padding(DesignTokens.Spacing.md)
    .background(
      RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
        .fill(.white.opacity(0.2))
        .overlay(
          RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
            .stroke(.white.opacity(0.3), lineWidth: 1)
        )
    )
    .enableInjection()
  }

  #if DEBUG
    @ObserveInjection var forceRedraw
  #endif
}

extension View {
  func textFieldStyle() -> some View {
    self
      .font(DesignTokens.Typography.body)
      .foregroundColor(.white)
      .placeholder(when: true) {
        // Placeholder styling handled by SwiftUI
      }
  }

  func placeholder<Content: View>(
    when shouldShow: Bool,
    alignment: Alignment = .leading,
    @ViewBuilder placeholder: () -> Content
  ) -> some View {

    ZStack(alignment: alignment) {
      placeholder().opacity(shouldShow ? 1 : 0)
      self
    }
  }
}

struct ActionButton: View {
  let title: String
  let isLoading: Bool
  let isEnabled: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        if isLoading {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .scaleEffect(0.8)
        } else {
          Text(title)
            .font(DesignTokens.Typography.headline)
            .fontWeight(.semibold)
        }
      }
      .foregroundColor(.white)
      .frame(maxWidth: .infinity)
      .padding(.vertical, DesignTokens.Spacing.md)
      .background(
        RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
          .fill(isEnabled ? .white.opacity(0.3) : .white.opacity(0.1))
          .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.BorderRadius.md)
              .stroke(.white.opacity(0.5), lineWidth: 1)
          )
      )
    }
    .disabled(!isEnabled || isLoading)
    .buttonStyle(PlainButtonStyle())
    .enableInjection()
  }
}

#Preview {
  AuthView()
}
