//
//  RAMMenuApp.swift
//  RAMMenu
//
//  Created by Michael Potter on 11/27/24.
//

import SwiftUI
import Darwin

@main
struct RAMMenuApp: App {
    @State var currentNumber: String = "1"
    @State var processInfo = ProcessInfo.processInfo
    @State var ramUsage: String = ""
    @State var swapUsage: String = ""
    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "memorychip") {
            Text("Total Ram: \(processInfo.physicalMemory/1024/1024/1000)GB")
            Text("Ram Usage: \(ramUsage)GB")
            Text("Swap Usage: \(swapUsage)MB")
            Divider().onAppear {
                ramUsage = getRamUsage()
                swapUsage = getSwapUsage()
                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
                    ramUsage = getRamUsage()
                    swapUsage = getSwapUsage()
                }
            }
            Button("Quit") {
                NSApplication.shared.terminate(self)
            }.keyboardShortcut("q")
        }.menuBarExtraStyle(.automatic)
    }
    
    func getRamUsage() -> String {
        
        let hw_pagesize = runCommand("sysctl -n hw.pagesize")
//        print("hw_pagesize: " + "\(hw_pagesize)")
//        let mem_total = runCommand("sysctl -n hw.memsize") / 1024 / 1024
//        print("mem_total: " + "\(mem_total)")
        let pages_app = runCommand("sysctl -n vm.page_pageable_internal_count") - runCommand("sysctl -n vm.page_purgeable_count")
//        print("pages_app: " + "\(pages_app)")
        let pages_wired = runCommand("vm_stat | awk '/ wired/ { print $4 }'")
//        print("pages_wired: " + "\(pages_wired)")
        let pages_compressed = runCommand("vm_stat | awk '/occupied/ { print $5 }'")
//        print("pages_compressed: " + "\(pages_compressed)")
        var mem_used = ((pages_app + pages_wired + pages_compressed) * hw_pagesize) / 1024 / 1024 / 1000
        
        mem_used = Double(round(100 * mem_used) / 100)
        return "\(mem_used)"
    }
    
    func getSwapUsage() -> String {
        let swapUsage = runCommand("sysctl vm.swapusage | awk '/ used/ { print $7 }'")
        return "\(swapUsage)"
    }
    
    func runCommand(_ command: String) -> Double {
        
        let process = Process()
        let pipe = Pipe()
        
        process.standardOutput = pipe
        process.standardError = pipe
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command ]
        try! process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        var trimmed = output.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if command == "sysctl vm.swapusage | awk '/ used/ { print $7 }'" {
            trimmed.removeLast()
        }
//        print(command + " -> " + trimmed)
        
        return Double(trimmed) ?? 0.0
    }
}
