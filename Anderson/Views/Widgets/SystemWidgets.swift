//
//  SystemWidgets.swift
//  Anderson
//
//  System monitoring widgets
//

import SwiftUI
import Foundation

// MARK: - Uptime Widget

struct UptimeWidget: View {
    @State private var uptime: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            GlowingText("UPTIME", size: 12, bold: true)
            
            VStack(spacing: 4) {
                Text(uptimeString)
                    .font(MatrixTheme.font(size: 16, bold: true))
                    .foregroundColor(MatrixTheme.primaryGreen)
                    .modifier(GlowModifier(intensity: 1.0, radius: 3))
                
                Text("SYSTEM ACTIVE")
                    .font(MatrixTheme.font(size: 10))
                    .foregroundColor(MatrixTheme.dimGreen)
            }
        }
        .onAppear {
            updateUptime()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var uptimeString: String {
        let days = Int(uptime / 86400)
        let hours = Int((uptime.truncatingRemainder(dividingBy: 86400)) / 3600)
        let minutes = Int((uptime.truncatingRemainder(dividingBy: 3600)) / 60)
        
        if days > 0 {
            return String(format: "%dd %02dh %02dm", days, hours, minutes)
        } else if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
    
    private func updateUptime() {
        var boottime = timeval()
        var size = MemoryLayout<timeval>.stride
        var mib: [Int32] = [CTL_KERN, KERN_BOOTTIME]
        
        if sysctl(&mib, 2, &boottime, &size, nil, 0) == 0 {
            let bootDate = Date(timeIntervalSince1970: TimeInterval(boottime.tv_sec))
            uptime = Date().timeIntervalSince(bootDate)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            updateUptime()
        }
    }
}

// MARK: - CPU Widget

struct CPUWidget: View {
    @State private var cpuUsage: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            GlowingText("CPU", size: 12, bold: true)
            
            VStack(spacing: 6) {
                Text(String(format: "%.1f%%", cpuUsage))
                    .font(MatrixTheme.font(size: 20, bold: true))
                    .foregroundColor(MatrixTheme.primaryGreen)
                    .modifier(GlowModifier(intensity: 1.0, radius: 3))
                
                ProgressBar(value: cpuUsage / 100.0)
                    .frame(height: 8)
            }
        }
        .onAppear {
            updateCPU()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func updateCPU() {
        var numCPUs: natural_t = 0
        var cpuInfo: processor_info_array_t!
        var numCpuInfo: mach_msg_type_number_t = 0
        
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &cpuInfo, &numCpuInfo)
        
        if result == KERN_SUCCESS {
            var totalUser: UInt64 = 0
            var totalSystem: UInt64 = 0
            var totalIdle: UInt64 = 0

            for i in 0..<Int(numCPUs) {
                let infoArray = cpuInfo.advanced(by: Int(CPU_STATE_MAX) * i)
                let user = UInt64(bitPattern: Int64(UInt64(Int64(infoArray[Int(CPU_STATE_USER)]))))
                let system = UInt64(bitPattern: Int64(UInt64(Int64(infoArray[Int(CPU_STATE_SYSTEM)]))))
                let idle = UInt64(bitPattern: Int64(UInt64(Int64(infoArray[Int(CPU_STATE_IDLE)]))))
                totalUser &+= user
                totalSystem &+= system
                totalIdle &+= idle
            }

            let total = totalUser &+ totalSystem &+ totalIdle
            if total > 0 {
                cpuUsage = (Double(totalUser &+ totalSystem) / Double(total)) * 100.0
            }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
            updateCPU()
        }
    }
}

// MARK: - Memory Widget

struct MemoryWidget: View {
    @State private var usedMemory: Double = 0
    @State private var totalMemory: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            GlowingText("MEMORY", size: 12, bold: true)
            
            VStack(spacing: 6) {
                Text(String(format: "%.1f / %.1f GB", usedMemory, totalMemory))
                    .font(MatrixTheme.font(size: 14, bold: true))
                    .foregroundColor(MatrixTheme.primaryGreen)
                    .modifier(GlowModifier(intensity: 1.0, radius: 3))
                
                let ratio = (totalMemory > 0) ? (usedMemory / totalMemory) : 0
                Text(String(format: "%.0f%%", ratio * 100))
                    .font(MatrixTheme.font(size: 18, bold: true))
                    .foregroundColor(MatrixTheme.dimGreen)
                
                ProgressBar(value: ratio)
                    .frame(height: 8)
            }
        }
        .onAppear {
            updateMemory()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func updateMemory() {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let pageSize = vm_kernel_page_size
            totalMemory = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824 // GB
            
            _ = Double(stats.free_count) * Double(pageSize)
            let active = Double(stats.active_count) * Double(pageSize)
            let inactive = Double(stats.inactive_count) * Double(pageSize)
            let wired = Double(stats.wire_count) * Double(pageSize)
            
            usedMemory = (active + inactive + wired) / 1_073_741_824 // GB
            
            if !usedMemory.isFinite { usedMemory = 0 }
            if !totalMemory.isFinite || totalMemory <= 0 { totalMemory = 0 }
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { _ in
            updateMemory()
        }
    }
}

// MARK: - Network Widget

struct NetworkWidget: View {
    @State private var downloadSpeed: Double = 0
    @State private var uploadSpeed: Double = 0
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 8) {
            GlowingText("NETWORK", size: 12, bold: true)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("↓")
                        .font(MatrixTheme.font(size: 16, bold: true))
                    Text(formatSpeed(downloadSpeed))
                        .font(MatrixTheme.font(size: 13))
                }
                .foregroundColor(MatrixTheme.primaryGreen)
                .modifier(GlowModifier(intensity: 0.8, radius: 2))
                
                HStack {
                    Text("↑")
                        .font(MatrixTheme.font(size: 16, bold: true))
                    Text(formatSpeed(uploadSpeed))
                        .font(MatrixTheme.font(size: 13))
                }
                .foregroundColor(MatrixTheme.dimGreen)
                .modifier(GlowModifier(intensity: 0.8, radius: 2))
            }
        }
        .onAppear {
            updateNetwork()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func formatSpeed(_ bytesPerSecond: Double) -> String {
        if bytesPerSecond > 1_048_576 { // MB
            return String(format: "%.2f MB/s", bytesPerSecond / 1_048_576)
        } else if bytesPerSecond > 1024 { // KB
            return String(format: "%.2f KB/s", bytesPerSecond / 1024)
        } else {
            return String(format: "%.0f B/s", bytesPerSecond)
        }
    }
    
    private func updateNetwork() {
        // Simplified network monitoring - in production, this would track actual network I/O
        // For now, using random values as placeholder
        downloadSpeed = Double.random(in: 0...5_000_000)
        uploadSpeed = Double.random(in: 0...1_000_000)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            updateNetwork()
        }
    }
}

// MARK: - Storage Widget

struct StorageWidget: View {
    @State private var volumes: [VolumeInfo] = []
    @State private var timer: Timer?
    @EnvironmentObject var preferences: AppPreferences
    
    var body: some View {
        VStack(spacing: 8) {
            GlowingText("STORAGE", size: 12, bold: true)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(displayedVolumes) { volume in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(volume.name)
                                .font(MatrixTheme.font(size: 10, bold: true))
                                .foregroundColor(MatrixTheme.primaryGreen)
                                .lineLimit(1)
                            
                            HStack {
                                Text(formatBytes(volume.free))
                                    .font(MatrixTheme.font(size: 9))
                                    .foregroundColor(MatrixTheme.dimGreen)
                                
                                Text("free")
                                    .font(MatrixTheme.font(size: 8))
                                    .foregroundColor(MatrixTheme.darkGreen)
                            }
                            
                            ProgressBar(value: volume.usedRatio)
                                .frame(height: 4)
                        }
                    }
                }
            }
        }
        .onAppear {
            updateVolumes()
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private var displayedVolumes: [VolumeInfo] {
        // Only show volumes with significant recent changes
        let thresholdBytes: Int64 = Int64(preferences.diskSpaceChangeThreshold * CGFloat(1_073_741_824))
        return volumes.filter { volume in
            volume.recentChange > thresholdBytes // GB to bytes
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let gb = Double(bytes) / 1_073_741_824
        if gb > 1000 {
            return String(format: "%.1f TB", gb / 1024)
        } else {
            return String(format: "%.1f GB", gb)
        }
    }
    
    private func updateVolumes() {
        let fileManager = FileManager.default
        guard let keys = fileManager.mountedVolumeURLs(includingResourceValuesForKeys: [
            .volumeNameKey,
            .volumeTotalCapacityKey,
            .volumeAvailableCapacityKey
        ]) else { return }
        
        var newVolumes: [VolumeInfo] = []
        
        for url in keys {
            if let values = try? url.resourceValues(forKeys: [
                .volumeNameKey,
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey
            ]) {
                if let name = values.volumeName,
                   let total = values.volumeTotalCapacity,
                   let available = values.volumeAvailableCapacity,
                   total > 0 {
                    
                    let used = Int64(total - available)
                    let rawRatio = (total > 0) ? Double(used) / Double(total) : 0
                    let usedRatio = max(0, min(rawRatio.isFinite ? rawRatio : 0, 1))
                    
                    // Calculate recent change (simplified - would need persistent tracking)
                    let recentChange: Int64 = 0 // Placeholder
                    
                    newVolumes.append(VolumeInfo(
                        name: name,
                        total: Int64(total),
                        free: Int64(available),
                        usedRatio: usedRatio,
                        recentChange: recentChange
                    ))
                }
            }
        }
        
        volumes = newVolumes
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
            updateVolumes()
        }
    }
}

struct VolumeInfo: Identifiable {
    let id = UUID()
    let name: String
    let total: Int64
    let free: Int64
    let usedRatio: Double
    let recentChange: Int64
}

// MARK: - Progress Bar

struct ProgressBar: View {
    let value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(MatrixTheme.darkGreen.opacity(0.3))
                
                let safeValue: Double = value.isFinite ? value : 0
                let clamped = min(max(safeValue, 0), 1)
                RoundedRectangle(cornerRadius: 2)
                    .fill(MatrixTheme.primaryGreen)
                    .frame(width: geometry.size.width * CGFloat(clamped))
                    .modifier(GlowModifier(intensity: 0.6, radius: 2))
            }
        }
    }
}

#Preview("Uptime") {
    UptimeWidget()
        .frame(width: 150, height: 100)
        .background(MatrixTheme.backgroundColor)
}

#Preview("CPU") {
    CPUWidget()
        .frame(width: 150, height: 100)
        .background(MatrixTheme.backgroundColor)
}

#Preview("Memory") {
    MemoryWidget()
        .frame(width: 150, height: 120)
        .background(MatrixTheme.backgroundColor)
}

