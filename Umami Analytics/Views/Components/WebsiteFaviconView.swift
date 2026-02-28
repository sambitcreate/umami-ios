//
//  WebsiteFaviconView.swift
//  Umami Analytics
//
//  Extracted from ContentView.swift
//

import SwiftUI

struct WebsiteFaviconView: View {
    var domain: String
    var size: CGFloat = 36

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
        AsyncImage(url: faviconURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: size / 4, style: .continuous))
            case .failure:
                placeholder
            case .empty:
                placeholder.overlay(
                    ProgressView()
                        .scaleEffect(0.6)
                )
            @unknown default:
                placeholder
            }
        }
        .frame(width: size, height: size)
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
