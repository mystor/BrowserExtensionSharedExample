//
//  ContentView.swift
//  BrowserExtensionSharedExample
//
//  Created by Nika Layzell on 2024-02-29.
//

import SwiftUI
import EngineCommon

struct ContentView: View {
    @State var result = "Content Not Started..."

    var body: some View {
        VStack {
            Text(result)
            Button(action: {
                Task { @MainActor in
                    do {
                        let key = "hello"
                        let local = try getValueLocal(key: key)
                        let remote = try await startAndQueryContent(key: key)
                        result = "Key: \(key)\nLocal Value: \(local)\nRemote Value: \(remote)"
                    } catch {
                        result = "ERRORED"
                    }
                }
            }) {
                Text("Start Content Process")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
