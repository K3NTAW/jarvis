//
//  MediaThumbnailView.swift
//  JARVIS
//
//  Movie/show cover with metadata and progress indicator.
//  Supports thumbnail image, title, subtitle, and playback progress.
//

import SwiftUI

/// A media thumbnail card displaying cover art, metadata, and progress.
struct MediaThumbnailView: View {
    let data: BlueprintComponent
    
    private var progressValue: Double {
        data.progress ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Thumbnail area
            ZStack(alignment: .bottomLeading) {
                // Thumbnail placeholder or async image
                thumbnailImage
                
                // Play button overlay
                if data.action == "play" {
                    playButton
                }
                
                // Progress bar at bottom
                if progressValue > 0 {
                    progressBar
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            // Metadata
            VStack(alignment: .leading, spacing: 4) {
                Text(data.title ?? "Untitled")
                    .font(JARVISFonts.body(14))
                    .foregroundColor(JARVISColors.textPrimary)
                    .lineLimit(1)
                
                if let subtitle = data.subtitle {
                    Text(subtitle)
                        .font(JARVISFonts.caption(12))
                        .foregroundColor(JARVISColors.textTertiary)
                        .lineLimit(1)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var thumbnailImage: some View {
        if let urlString = data.thumbnailUrl, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    thumbnailPlaceholder
                case .empty:
                    thumbnailPlaceholder
                        .overlay(ProgressView().tint(JARVISColors.primaryAccent))
                @unknown default:
                    thumbnailPlaceholder
                }
            }
        } else {
            thumbnailPlaceholder
        }
    }
    
    private var thumbnailPlaceholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [JARVISColors.cardBackground, JARVISColors.cardBackgroundLight],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                Image(systemName: "film")
                    .font(.system(size: 30))
                    .foregroundColor(JARVISColors.textTertiary)
            )
    }
    
    private var playButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4)
                    .padding(8)
            }
        }
    }
    
    private var progressBar: some View {
        VStack {
            Spacer()
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .frame(height: 3)
                    
                    Rectangle()
                        .fill(JARVISColors.primaryAccent)
                        .frame(width: geo.size.width * progressValue, height: 3)
                        .glowEffect(color: JARVISColors.primaryAccent, radius: 2)
                }
            }
            .frame(height: 3)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        
        HStack(spacing: 16) {
            MediaThumbnailView(data: BlueprintComponent(
                id: "movie_1",
                type: "media_thumbnail",
                title: "Dune: Part Two",
                subtitle: "2024 • Sci-Fi",
                action: "play",
                progress: 0.65
            ))
            
            MediaThumbnailView(data: BlueprintComponent(
                id: "movie_2",
                type: "media_thumbnail",
                title: "Oppenheimer",
                subtitle: "2023 • Drama",
                action: "play",
                progress: 0.0
            ))
        }
        .padding()
    }
}

