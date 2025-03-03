//
//  SongsView.swift
//  Genius Search
//
//  Created by Zane Matarieh on 3/3/25.
//

import SwiftUI

struct SongsView: View {
    let artist: Artist
    @State private var songs: [GeniusSong] = []
    @State private var isLoading = false
    @State private var showingAlert = false

    var body: some View {
        List(songs) { song in
            NavigationLink(destination: LyricsView(song: song)) {
                Text(song.title)
            }
        }
        .navigationTitle("\(artist.name)'s Songs")
        .onAppear {
            Task { await fetchSongs() }
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Error"), message: Text("Failed to load songs."), dismissButton: .default(Text("OK")))
        }
    }

    func fetchSongs() async {
        isLoading = true
        guard let url = URL(string: "https://api.genius.com/artists/\(artist.id)/songs?sort=popularity&per_page=20") else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer rSEGtFXk0qG16G1m-qt-xhAUQwkZTbkEWuVCvf1ksgSyFuAs2sCGRHaEyDHcYn7G", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let songsResponse = try JSONDecoder().decode(ArtistSongsResponse.self, from: data)
            DispatchQueue.main.async {
                self.songs = songsResponse.response.songs
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                self.showingAlert = true
            }
        }
    }
}

// MARK: - Preview
struct SongsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SongsView(artist: Artist(id: 123, name: "Test Artist", url: "https://genius.com"))
        }
    }
}
