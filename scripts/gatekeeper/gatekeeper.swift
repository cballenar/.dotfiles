import AppKit
import Foundation

let hcUUID = "GATEKEEPER_UUID_PLACEHOLDER"
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

func sendRequest(urlString: String, body: String, retryAttempts: Int = 0, completion: (() -> Void)? = nil) {
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body.data(using: .utf8)
    
    URLSession.shared.dataTask(with: request) { _, response, error in
        if let error = error {
            if retryAttempts > 0 {
                let delay = 3.0
                print("Network error: \(error.localizedDescription). Retrying in \(delay)s...")
                DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                    sendRequest(urlString: urlString, body: body, retryAttempts: retryAttempts - 1, completion: completion)
                }
            } else {
                print("Failed to send request after multiple attempts.")
            }
            return
        }
        
        // Success
        completion?()
    }.resume()
}

func triggerAlert(event: String) {
    // Note: In a wake scenarios, getUsefulInfo()'s IP might be empty initially.
    // We prioritize getting the alert out over perfecting the metadata.
    let diagnosticInfo = "SECURITY ALERT: \(event) | \(getUsefulInfo())"
    
    // 1. Trigger the immediate alert
    // We retry 5 times (approx 15s) to allow Wi-Fi to reconnect upon wake
    sendRequest(urlString: "\(baseUrl)/fail", body: diagnosticInfo, retryAttempts: 5) {
        
        // 2. Log the data (Lower priority, fire and forget)
        sendRequest(urlString: "\(baseUrl)/log", body: diagnosticInfo)
        
        // 3. Reset to Green after 10 seconds
        // IMPORTANT: We only schedule this AFTER the fail signal has succeeded.
        // This prevents the "Race Condition" where a Reset might arrive before the Fail.
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            sendRequest(urlString: baseUrl, body: "Resetting after alert.")
        }
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
