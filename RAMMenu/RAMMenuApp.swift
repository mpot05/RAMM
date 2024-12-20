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
    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            Text("Total Ram: \(processInfo.physicalMemory/1024/1024/1000)GB")
            Text("Ram Usage: \(ramUsage)GB")
            Divider()
                .onAppear {
                    ramUsage = getRamUsage()
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (t) in
                        ramUsage = getRamUsage()
                        print("time")
                    }
                }
            Button("Quit") {
                NSApplication.shared.terminate(self)
            }.keyboardShortcut("q")
        }
        
    }
    
    func getRamUsage() -> String {
        var finalStrings: [String] = []
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
            let matches = regex.matches(in: outputString, range: NSRange(location: 0, length: outputString.count))
            var result: [String] = []
            for match in matches {
                var groups: [String] = []
                for rangeIndex in 1 ..< match.numberOfRanges {
                    let nsRange = match.range(at: rangeIndex)
                    guard !NSEqualRanges(nsRange, NSMakeRange(NSNotFound, 0)) else { continue }
                    let string = (outputString as NSString).substring(with: nsRange)
                    groups.append(string)
                }
                if !groups.isEmpty {
                    result.append(groups[0])
                }
            }
            print (result)
            finalStrings.append(result[1])
            finalStrings.append(result[3])
            finalStrings.append(result[1])
        } catch {
            print("error \(error)")
        }
        let num1 = ((Double(finalStrings[0]) ?? -1)*16384)
        let num2 = ((Double(finalStrings[1]) ?? -1)*16384)
        let num3 = num1 + num2
        let num4 = processInfo.physicalMemory
        let num5 = (((Double(num4) - Double(num3))/1024)/1024)/1000
        
        
        return String(num5)
    }
}
