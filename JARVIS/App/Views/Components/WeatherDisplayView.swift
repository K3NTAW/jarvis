//
//  WeatherDisplayView.swift
//  JARVIS
//
//  Weather card with temperature, condition, icon, and high/low.
//  Glassmorphism style with animated weather icon.
//

import SwiftUI

/// A weather display card showing current conditions.
struct WeatherDisplayView: View {
    let data: BlueprintComponent
    
    var body: some View {
        HStack(spacing: 16) {
            // Weather icon
            VStack {
                Image(systemName: data.conditionIcon ?? "cloud.fill")
                    .font(.system(size: 44, weight: .light))
                    .foregroundColor(weatherIconColor)
                    .glowEffect(color: weatherIconColor, radius: 6)
                    .symbolEffect(.pulse, options: .repeating)
            }
            .frame(width: 70)
            
            // Weather info
            VStack(alignment: .leading, spacing: 6) {
                // Location
                if let location = data.location {
                    Text(location)
                        .font(JARVISFonts.caption(13))
                        .foregroundColor(JARVISColors.textSecondary)
                }
                
                // Temperature
                Text(data.temperature ?? "—°")
                    .font(JARVISFonts.stat(36))
                    .foregroundColor(JARVISColors.textPrimary)
                
                // Condition
                if let condition = data.condition {
                    Text(condition)
                        .font(JARVISFonts.body(14))
                        .foregroundColor(JARVISColors.textSecondary)
                }
                
                // High / Low
                if let highLow = data.highLow {
                    Text(highLow)
                        .font(JARVISFonts.caption(12))
                        .foregroundColor(JARVISColors.textTertiary)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .glassMorphism()
    }
    
    private var weatherIconColor: Color {
        let icon = data.conditionIcon ?? ""
        if icon.contains("sun") { return .yellow }
        if icon.contains("cloud") { return Color(white: 0.7) }
        if icon.contains("rain") || icon.contains("drop") { return .blue }
        if icon.contains("snow") { return .white }
        if icon.contains("bolt") { return .yellow }
        return JARVISColors.primaryAccent
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        
        WeatherDisplayView(data: BlueprintComponent(
            id: "weather_zurich",
            type: "weather_display",
            temperature: "7°C",
            condition: "Cloudy",
            conditionIcon: "cloud.fill",
            location: "Zurich",
            highLow: "10°C / 4°C"
        ))
        .padding()
    }
}

