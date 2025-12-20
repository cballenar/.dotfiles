import AppKit
import Foundation

let hcUUID = "YOUR-UUID-HERE"

func getUsefulInfo() -> String {
    // Get Local IP Address
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/sbin/ipconfig")
    process.arguments = ["getifaddr", "en0"] // en0 is standard for Wi-Fi/Ethernet
    let pipe = Pipe()
    process.standardOutput = pipe
    try? process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown IP"

    // Get Active User
    let user = NSUserName()
    
    return "User: \(user) | Local IP: \(ip)"
}

func triggerAlert(event: String) {
    let baseUrl = "https://hc-ping.com/\(hcUUID)"
    let diagnosticInfo = "EVENT: \(event) | \(getUsefulInfo())"

    // 1. Send the FAILURE (to trigger the alert)
    sendRequest(urlString: "\(baseUrl)/fail", body: diagnosticInfo)
    
    // 2. Send the LOG (to save the info in the history)
    sendRequest(urlString: "\(baseUrl)/log", body: diagnosticInfo)

    // 3. Reset to GREEN after a 10-second delay
    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        sendRequest(urlString: baseUrl, body: "Resetting to Green after event.")
        print("Alert sent and monitor reset.")
    }
}

func sendRequest(urlString: String, body: String) {
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body.data(using: .utf8)
    URLSession.shared.dataTask(with: request).resume()
}

class EntryWatcher {
    init() {
        let nc = NSWorkspace.shared.notificationCenter
        
        nc.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in
            triggerAlert(event: "System Wake")
        }
        
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil, queue: .main) { _ in
            triggerAlert(event: "Screen Unlocked")
        }
    }
}

let watcher = EntryWatcher()
print("Gatekeeper Active. Standing by...")
RunLoop.main.run()
