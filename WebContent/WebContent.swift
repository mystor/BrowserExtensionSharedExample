//
//  WebContent.swift
//  WebContent
//
//  Created by Nika Layzell on 2024-02-29.
//

import Foundation
import BrowserEngineKit
import EngineCommon

@main
class WebContent: WebContentExtension {
    required init() {
        // Initialize your extension here.
    }

    func handle(xpcConnection: xpc_connection_t) {
        handleContentConnection(xpcConnection)
    }
}
