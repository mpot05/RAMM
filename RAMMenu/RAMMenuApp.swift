//
//  RAMMenuApp.swift
//  RAMMenu
//
//  Created by Michael Potter on 11/27/24.
//

import SwiftUI

@main
struct RAMMenuApp: App {
    @State var currentNumber: String = "1"
    var body: some Scene {
        MenuBarExtra(currentNumber, systemImage: "\(currentNumber).circle") {
            Button("One") {
                currentNumber = "1"
            }
            Button("Two") {
                currentNumber = "2"
            }
            Button("Three") {
                currentNumber = "3"
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(self)
            }.keyboardShortcut("q")
        }
    }
}
