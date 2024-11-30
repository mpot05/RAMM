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
    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            Text("Total Ram: \(processInfo.physicalMemory/1024/1024/1000)GB")
            Text("Ram Usage: \(getRamUsage())GB")
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(self)
            }.keyboardShortcut("q")
        }
        
    }
    
    func getRamUsage() -> String {
        var task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/vm_stat")
        
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        do {
            try task.run()
        } catch {
            print("error: \(error)")
            return "uh oh"
        }
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        var outputString = "\(String(decoding: outputData, as: UTF8.self))"
        do {
            let regex = try NSRegularExpression(pattern: "(?:(?:\\b *)*([1234567890]+).)")
            regex.matches(in: outputString, range: NSRange(location: 0, length: outputString.count))
        } catch {
            print("error \(error)")
        }
        
        return outputString
    }
}
