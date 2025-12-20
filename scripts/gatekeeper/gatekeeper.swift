import AppKit
import Foundation

let hcUUID = "YOUR-UUID-HERE"
let baseUrl = "https://hc-ping.com/\(hcUUID)"

func getUsefulInfo() -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/sbin/ipconfig")
    process.arguments = ["getifaddr", "en0"] 
    let pipe = Pipe()
    process.standardOutput = pipe
    try? process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let ip = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown IP"
    return "User: \(NSUserName()) | Local IP: \(ip)"
}

func sendRequest(urlString: String, body: String) {
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body.data(using: .utf8)
    URLSession.shared.dataTask(with: request).resume()
}

func triggerAlert(event: String) {
    let diagnosticInfo = "SECURITY ALERT: \(event) | \(getUsefulInfo())"
    
    // 1. Trigger the immediate alert
    sendRequest(urlString: "\(baseUrl)/fail", body: diagnosticInfo)
    // 2. Log the data
    sendRequest(urlString: "\(baseUrl)/log", body: diagnosticInfo)
    
    // 3. Reset to Green after 10 seconds
    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        sendRequest(urlString: baseUrl, body: "Resetting after alert.")
    }
}

class EntryWatcher {
    var heartbeatTimer: Timer?

    init() {
        let nc = NSWorkspace.shared.notificationCenter
        
        // Listen for Wake
        nc.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in
            triggerAlert(event: "System Wake")
        }
        
        // Listen for Unlock
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil, queue: .main) { _ in
            triggerAlert(event: "Screen Unlocked")
        }

        // Manually fire the first ping immediately so the dashboard goes green right away
        sendRequest(urlString: baseUrl, body: "Gatekeeper Started: System Online")

        // --- THE HEARTBEAT ---
        // Pings every 300 seconds (5 minutes) to keep the check Green
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            sendRequest(urlString: baseUrl, body: "Heartbeat: System Online")
        }
    }
}

let watcher = EntryWatcher()
print("Gatekeeper Active with Hourly Heartbeat. Standing by...")
RunLoop.main.run()
