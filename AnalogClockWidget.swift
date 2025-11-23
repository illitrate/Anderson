//
//  AnalogClockWidget.swift
//  MatrixMonitor
//
//  Traditional analog clock with Matrix styling
//

import SwiftUI

struct AnalogClockWidget: View {
    @State private var currentTime = Date()
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 4) {
            GlowingText("CLOCK", size: 12, bold: true)
            
            ZStack {
                // Clock face background
                RoundedRectangle(cornerRadius: 4)
                    .stroke(MatrixTheme.primaryGreen.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(MatrixTheme.backgroundColor.opacity(0.5))
                    )
                
                // Hour markers
                ForEach(0..<12) { hour in
                    Rectangle()
                        .fill(MatrixTheme.dimGreen)
                        .frame(width: 2, height: 8)
                        .offset(y: -35)
                        .rotationEffect(.degrees(Double(hour) * 30))
                }
                
                // Minute markers
                ForEach(0..<60) { minute in
                    if minute % 5 != 0 {
                        Rectangle()
                            .fill(MatrixTheme.darkGreen)
                            .frame(width: 1, height: 4)
                            .offset(y: -35)
                            .rotationEffect(.degrees(Double(minute) * 6))
                    }
                }
                
                // Hour hand
                ClockHand(
                    length: 25,
                    width: 4,
                    color: MatrixTheme.primaryGreen,
                    angle: hourAngle
                )
                
                // Minute hand
                ClockHand(
                    length: 35,
                    width: 3,
                    color: MatrixTheme.primaryGreen,
                    angle: minuteAngle
                )
                
                // Second hand
                ClockHand(
                    length: 38,
                    width: 1.5,
                    color: MatrixTheme.dimGreen,
                    angle: secondAngle
                )
                
                // Center dot
                Circle()
                    .fill(MatrixTheme.primaryGreen)
                    .frame(width: 6, height: 6)
                    .modifier(GlowModifier(intensity: 1.0, radius: 3))
            }
            .frame(width: 90, height: 90)
            
            // Digital time display
            Text(timeString)
                .font(MatrixTheme.font(size: 11, bold: true))
                .foregroundColor(MatrixTheme.dimGreen)
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var hourAngle: Double {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: currentTime)
        let minute = calendar.component(.minute, from: currentTime)
        return Double(hour % 12) * 30 + Double(minute) * 0.5 - 90
    }
    
    private var minuteAngle: Double {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: currentTime)
        let second = calendar.component(.second, from: currentTime)
        return Double(minute) * 6 + Double(second) * 0.1 - 90
    }
    
    private var secondAngle: Double {
        let calendar = Calendar.current
        let second = calendar.component(.second, from: currentTime)
        return Double(second) * 6 - 90
    }
    
    private var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: currentTime)
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            currentTime = Date()
        }
    }
}

struct ClockHand: View {
    let length: CGFloat
    let width: CGFloat
    let color: Color
    let angle: Double
    
    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(.degrees(angle))
            .modifier(GlowModifier(intensity: 0.8, radius: 2))
    }
}

#Preview {
    AnalogClockWidget()
        .frame(width: 150, height: 150)
        .background(MatrixTheme.backgroundColor)
}
