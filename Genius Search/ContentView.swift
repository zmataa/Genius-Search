//  ContentView.swift
//  Genius Search
//
//  Created by Zane Matarieh on 3/3/25.
//

import SwiftUI
import WebKit

struct ContentView: View {
    @State private var query: String = ""
    @State private var artists: [Artist] = []
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter artist name", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Search") {
                    Task { await searchArtists() }
                }
                .padding()
                
                
                List(artists, id: \.id) { artist in
                    NavigationLink(destination: SongsView(artist: artist)) {
                        Text(artist.name)
                    }
                }
            }
            .navigationTitle("Genius Artist Search")
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Error"), message: Text("Failed to load data."), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func searchArtists() async {
        guard !query.isEmpty,
              let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://api.genius.com/search?q=\(queryEncoded)")
        else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer rSEGtFXk0qG16G1m-qt-xhAUQwkZTbkEWuVCvf1ksgSyFuAs2sCGRHaEyDHcYn7G", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let searchResponse = try JSONDecoder().decode(GeniusSearchResponse.self, from: data)
            let hits = searchResponse.response.hits
            let uniqueArtists = Set(hits.map { $0.result.primary_artist })
            let sortedArtists = uniqueArtists.sorted { $0.name < $1.name }
            artists = sortedArtists
        } catch {
            DispatchQueue.main.async {
                self.showingAlert = true
            }
        }
    }
}

struct GeniusSearchResponse: Codable {
    let response: SearchResponse
}

struct SearchResponse: Codable {
    let hits: [Hit]
}

struct Hit: Codable {
    let result: SongResult
}

struct SongResult: Codable {
    let id: Int
    let title: String
    let url: String
    let primary_artist: Artist
}

struct Artist: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let url: String
}

struct ArtistSongsResponse: Codable {
    let response: SongsResponse
}

struct SongsResponse: Codable {
    let songs: [GeniusSong]
}

struct GeniusSong: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String
}

#Preview {
    ContentView()
}
