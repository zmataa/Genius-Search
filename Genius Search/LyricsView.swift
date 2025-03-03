//
//  LyricsView.swift
//  Genius Search
//
//  Created by Zane Matarieh on 3/3/25.
//

import SwiftUI

struct SongInsightsView: View {
    let song: GeniusSong
    @State private var insights = "Loading song insights..."
    
    var body: some View {
        ScrollView {
            Text(insights)
                .padding()
        }
        .navigationTitle(song.title)
        .onAppear {
            loadInsights()
        }
    }
    
    func loadInsights() {
        guard let url = URL(string: song.url) else {
            insights = "Invalid URL."
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data,
                  error == nil,
                  let html = String(data: data, encoding: .utf8) else {
                DispatchQueue.main.async {
                    insights = "Error loading insights."
                }
                return
            }
            // Look for the first occurrence of the lyrics container.
            if let startRange = html.range(of: "<div data-lyrics-container=\"true\"") {
                let subHTML = html[startRange.lowerBound...]
                if let endRange = subHTML.range(of: "</div>") {
                    let snippet = subHTML[..<endRange.upperBound]
                    // Remove HTML tags with a simple regular expression.
                    let plainText = snippet.replacingOccurrences(of: "<[^>]+>", with: "\n", options: .regularExpression)
                    DispatchQueue.main.async {
                        insights = plainText.trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                insights = "No insights found."
            }
        }.resume()
    }
}

struct SongInsightsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SongInsightsView(song: GeniusSong(id: 1,
                                              title: "Test Song",
                                              url: "https://genius.com/Test-song-lyrics"))
        }
    }
}
