//
//  AsyncImageView.swift
//  SomativaFinalIos
//
//  Created by Enzo Enrico on 13/06/25.
//

import SwiftUI
import Combine

struct AsyncImageView: View {
    let url: String?
    let placeholder: Image
    let contentMode: ContentMode
    
    @StateObject private var imageLoader = ImageLoader()
    
    init(url: String?, 
         placeholder: Image = Image(systemName: "photo"), 
         contentMode: ContentMode = .fit) {
        self.url = url
        self.placeholder = placeholder
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            } else {
                placeholder
                    .foregroundColor(DesignTokens.Colors.onSurface.opacity(0.5))
                    .transition(.opacity.animation(.easeInOut(duration: 0.3)))
            }
        }
        .onAppear {
            if let url = url {
                imageLoader.loadImage(from: url)
            }
        }
        .onChange(of: url) { oldValue, newUrl in
            if let newUrl = newUrl {
                imageLoader.loadImage(from: newUrl)
            }
        }
    }
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private let imageCache = ImageCacheService.shared
    private var cancellables = Set<AnyCancellable>()
    
    func loadImage(from urlString: String) {
        imageCache.loadImage(from: urlString)
            .sink { [weak self] image in
                DispatchQueue.main.async {
                    self?.image = image
                }
            }
            .store(in: &cancellables)
    }
}

#Preview {
    AsyncImageView(url: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/1.png")
        .frame(width: 200, height: 200)
}
