

//
//  SongLyricsView.swift
//  Genius Search
//
//  Created by Zane Matarieh on 3/3/25.
//
import SwiftUI

struct SongLyricsView: View {
    let song: GeniusSong
    @State private var lyrics = "Loading song lyrics..."
    
    var body: some View {
        ScrollView {
            Text(lyrics)
                .padding()
                .foregroundColor(.yellow)
                .background(Color.black)
        }
        .background(Color.black)
        .navigationTitle(song.title)
        .foregroundColor(.yellow)
        .task {
            await loadLyrics()
        }
    }
    
    func loadLyrics() async {
        guard let url = URL(string: song.url) else {
            lyrics = "Invalid URL."
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let html = String(data: data, encoding: .utf8) {
                if let startRange = html.range(of: "<div data-lyrics-container=\"true\"") {
                    let subHTML = html[startRange.lowerBound...]
                    if let endRange = subHTML.range(of: "</div>") {
                        let snippet = subHTML[..<endRange.upperBound]
            
                        var plainText = snippet.replacingOccurrences(of: "<[^>]+>", with: "\n", options: .regularExpression)
                        plainText = plainText.replacingOccurrences(of: "&#x27;", with: "'")
                        plainText = plainText.replacingOccurrences(of: "\n+", with: "\n", options: .regularExpression)
                        plainText = plainText.replacingOccurrences(of: "&amp;", with: "&", options: .regularExpression)
                        plainText = plainText.replacingOccurrences(of: "&quot;", with: "\"", options: .regularExpression)

                        DispatchQueue.main.async {
                            lyrics = plainText.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        return
                    }
                }
                DispatchQueue.main.async {
                    lyrics = "No lyrics found."
                }
            }
        } catch {
            DispatchQueue.main.async {
                lyrics = "Error loading lyrics: \(error.localizedDescription)"
            }
        }
    }
}

struct SongLyricsView_Previews: PreviewProvider {
    static var previews: some View {
        SongLyricsView(song: GeniusSong(id: 1, title: "Example", url: ""))
    }
}
