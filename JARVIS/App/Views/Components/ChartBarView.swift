//
//  ChartBarView.swift
//  JARVIS
//
//  Simple bar chart component with animated bars.
//  Supports custom colors, labels, and max value.
//

import SwiftUI

/// A simple bar chart with animated bars.
struct ChartBarView: View {
    let data: BlueprintComponent
    
    @State private var animatedValues: [Double] = []
    
    private var chartData: [ChartDataPoint] {
        data.data ?? []
    }
    
    private var maxVal: Double {
        data.maxValue ?? chartData.map(\.value).max() ?? 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = data.title {
                Text(title)
                    .font(JARVISFonts.caption(14))
                    .foregroundColor(JARVISColors.textSecondary)
            }
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(chartData.enumerated()), id: \.element.id) { index, point in
                    VStack(spacing: 6) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        barColor(for: point).opacity(0.4),
                                        barColor(for: point)
                                    ],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(
                                height: index < animatedValues.count
                                    ? max(4, CGFloat(animatedValues[index] / maxVal) * 120)
                                    : 4
                            )
                            .shadow(color: barColor(for: point).opacity(0.4), radius: 3)
                        
                        // Label
                        Text(point.label)
                            .font(JARVISFonts.caption(10))
                            .foregroundColor(JARVISColors.textTertiary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
        }
        .padding(16)
        .glassMorphism()
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animatedValues = chartData.map(\.value)
            }
        }
    }
    
    private func barColor(for point: ChartDataPoint) -> Color {
        JARVISColors.fromHex(point.color) ?? JARVISColors.primaryAccent
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        JARVISColors.background.ignoresSafeArea()
        
        ChartBarView(data: BlueprintComponent(
            id: "usage_chart",
            type: "chart_bar",
            title: "Weekly Usage",
            data: [
                ChartDataPoint(label: "Mon", value: 45, color: "#00FFFF"),
                ChartDataPoint(label: "Tue", value: 72, color: "#00FFFF"),
                ChartDataPoint(label: "Wed", value: 38, color: "#00FFFF"),
                ChartDataPoint(label: "Thu", value: 91, color: "#9D00FF"),
                ChartDataPoint(label: "Fri", value: 65, color: "#00FFFF"),
                ChartDataPoint(label: "Sat", value: 28, color: "#00FFFF"),
                ChartDataPoint(label: "Sun", value: 55, color: "#00FFFF")
            ],
            maxValue: 100
        ))
        .padding()
    }
}

