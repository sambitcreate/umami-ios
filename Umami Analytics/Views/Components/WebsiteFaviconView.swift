//
//  WebsiteFaviconView.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI
import UIKit
@preconcurrency import Combine

struct WebsiteFaviconView: View {
    var domain: String
    var size: CGFloat = 36
    @StateObject private var loader = FaviconImageLoader()

    private var faviconURL: URL? {
        var trimmedDomain = domain.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedDomain.hasPrefix("http://") || trimmedDomain.hasPrefix("https://") {
            if let url = URL(string: trimmedDomain), let host = url.host {
                trimmedDomain = host
            }
        }

        guard !trimmedDomain.isEmpty else { return nil }

        let encodedDomain = trimmedDomain.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? trimmedDomain
        let urlString = "https://www.google.com/s2/favicons?sz=64&domain=\(encodedDomain)"
        return URL(string: urlString)
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: size / 4, style: .continuous))
            } else if loader.isLoading {
                placeholder.overlay(
                    ProgressView()
                        .scaleEffect(0.6)
                )
            } else {
                placeholder
            }
        }
        .frame(width: size, height: size)
        .onAppear {
            loader.load(from: faviconURL)
        }
        .onChange(of: faviconURL) { newURL in
            loader.load(from: newURL)
        }
    }

    private var placeholder: some View {
        RoundedRectangle(cornerRadius: size / 4, style: .continuous)
            .fill(Color(.secondarySystemBackground))
            .overlay(
                Image(systemName: "globe")
                    .font(.system(size: size / 2))
                    .foregroundStyle(.secondary)
            )
    }
}

@MainActor
private final class FaviconImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false

    private static let cache = NSCache<NSURL, UIImage>()
    private var activeURL: URL?
    private var cancellable: AnyCancellable?

    func load(from url: URL?) {
        cancellable?.cancel()
        activeURL = url

        guard let url else {
            image = nil
            isLoading = false
            return
        }

        if let cachedImage = Self.cache.object(forKey: url as NSURL) {
            image = cachedImage
            isLoading = false
            return
        }

        image = nil
        isLoading = true

        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 15
        )

        cancellable = URLSession.shared.dataTaskPublisher(for: request)
            .compactMap { UIImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard self?.activeURL == url else { return }
                self?.isLoading = false
            } receiveValue: { [weak self] downloadedImage in
                guard self?.activeURL == url else { return }
                Self.cache.setObject(downloadedImage, forKey: url as NSURL)
                self?.image = downloadedImage
                self?.isLoading = false
            }
    }

}
