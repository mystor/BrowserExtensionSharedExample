//
//  EmbedAPI.swift
//  EngineCommon
//
//  Created by Nika Layzell on 2024-02-29.
//
import Foundation
import BrowserEngineKit

class SharedResourceLoader {
    static func loadData() -> Dictionary<String, Any> {
        let bundle = Bundle(for: Self.self)
        let resourceUrl = bundle.url(forResource: "ExampleResource", withExtension: "json")!
        let data = try! Data(contentsOf: resourceUrl)
        return try! JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
    }
}

public func getValueLocal(key: String) throws -> String? {
    return SharedResourceLoader.loadData()[key] as? String
}

public func startAndQueryContent(key: String) async throws -> String? {
    let process = try await WebContentProcess() {
        NSLog("Interrupted!")
    }

    let xpcConnection = try process.makeLibXPCConnection()
    xpc_connection_set_event_handler(xpcConnection) { event in
        let type = xpc_get_type(event)
        if type == XPC_TYPE_ERROR {
            NSLog("ERROR: \(event)")
        }
    }
    xpc_connection_resume(xpcConnection)

    // (Yes, this is terrible to do sync IPC in an async function, but I didn't
    // feel like writing the wrapper for this example)
    let request = xpc_dictionary_create_empty()
    xpc_dictionary_set_string(request, "key", key)
    let reply = xpc_connection_send_message_with_reply_sync(xpcConnection, request) // hack

    // clean up
    process.invalidate()

    let replyType = xpc_get_type(reply)
    if replyType != XPC_TYPE_DICTIONARY {
        NSLog("ERROR: Got a bad type! \(reply)")
        return nil
    }

    if let rawValue = xpc_dictionary_get_string(reply, "value") {
        return String(cString: rawValue)
    }
    return nil
}

public func handleContentConnection(_ xpcConnection: xpc_connection_t) {
    xpc_connection_set_event_handler(xpcConnection) { event in
        let type = xpc_get_type(event)
        if type != XPC_TYPE_DICTIONARY {
            if type == XPC_TYPE_ERROR {
                exit(1)
            }
            return
        }

        // If a "key" string is passed down, look load the shared data and send it back down
        if let key = xpc_dictionary_get_string(event, "key") {
            let reply = xpc_dictionary_create_reply(event)!
            if let value = try! getValueLocal(key: String(cString: key)) {
                xpc_dictionary_set_string(reply, "value", value)
            }
            xpc_connection_send_message(xpc_dictionary_get_remote_connection(event)!,
                                        reply)
        }
    }
    xpc_connection_activate(xpcConnection)
}
