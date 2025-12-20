import AppKit
import Foundation

let hcUUID = "GATEKEEPER_UUID_PLACEHOLDER"
let baseUrl = "https://hc-ping.com/\(hcUUID)"

/// Fetches local and public IP information asynchronously
func getDiagnosticInfo(completion: @escaping (String) -> Void) {
    // 1. Get Local IP
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/sbin/ipconfig")
    process.arguments = ["getifaddr", "en0"]
    let pipe = Pipe()
    process.standardOutput = pipe
    try? process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let localIP = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown Local IP"
    
    // 2. Get Public IP (non-blocking)
    var request = URLRequest(url: URL(string: "https://ifconfig.me/ip")!)
    request.timeoutInterval = 3 // Short timeout to avoid blocking alerts
    
    URLSession.shared.dataTask(with: request) { data, _, _ in
        let publicIP = data.flatMap { String(data: $0, encoding: .utf8) }?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown Public IP"
        completion("User: \(NSUserName()) | Local: \(localIP) | Public: \(publicIP)")
    }.resume()
}

/// Sends an HTTP POST request with retry logic
func sendRequest(urlString: String, body: String, retryAttempts: Int = 3, completion: (() -> Void)? = nil) {
    guard let url = URL(string: urlString) else { return }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = body.data(using: .utf8)
    
    URLSession.shared.dataTask(with: request) { _, response, error in
        var shouldRetry = false
        
        if let error = error {
            print("Network Error: \(error.localizedDescription)")
            shouldRetry = true
        } else if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            print("HTTP Error: \(httpResponse.statusCode)")
            shouldRetry = true
        } else {
            // Success
            completion?()
            return
        }

        if shouldRetry && retryAttempts > 0 {
            let delay = 3.0
            DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
                sendRequest(urlString: urlString, body: body, retryAttempts: retryAttempts - 1, completion: completion)
            }
        }
    }.resume()
}

func triggerAlert(event: String) {
    getDiagnosticInfo { infoString in
        let diagnosticInfo = "SECURITY ALERT: \(event) | \(infoString)"
        
        // 1. Trigger the immediate alert (High Priority)
        sendRequest(urlString: "\(baseUrl)/fail", body: diagnosticInfo, retryAttempts: 5) {
            
            // 2. Log details (Fire & Forget)
            sendRequest(urlString: "\(baseUrl)/log", body: diagnosticInfo)
            
            // 3. Reset to Green after 10 seconds (Only if alert succeeded)
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                sendRequest(urlString: baseUrl, body: "Resetting after alert.")
            }
        }
    }
}

class EntryWatcher {
    var heartbeatTimer: Timer?
    var sshTimer: Timer?
    var knownSessions: Set<String> = []

    init() {
        // Initialize baseline for SSH sessions
        self.knownSessions = getCurrentSSHSessions()
        
        // System Event Observers
        let nc = NSWorkspace.shared.notificationCenter
        nc.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in
            triggerAlert(event: "System Wake")
        }
        
        DistributedNotificationCenter.default().addObserver(forName: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil, queue: .main) { _ in
            triggerAlert(event: "Screen Unlocked")
        }

        // Initial Startup Ping
        getDiagnosticInfo { info in
            sendRequest(urlString: baseUrl, body: "Gatekeeper Started: System Online | \(info)")
        }

        // Heartbeat Timer (Every 5 mins)
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            sendRequest(urlString: baseUrl, body: "Heartbeat: System Online")
        }
        
        // SSH/Terminal Session Watcher (Every 5 secs)
        sshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            self?.checkSSHSessions()
        }
    }
    
    func getCurrentSSHSessions() -> Set<String> {
        let task = Process()
        task.launchPath = "/usr/bin/who"
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return [] }
        return Set(output.components(separatedBy: .newlines).filter { !$0.isEmpty })
    }
    
    func checkSSHSessions() {
        let currentSessions = getCurrentSSHSessions()
        let newSessions = currentSessions.subtracting(knownSessions)
        
        if !newSessions.isEmpty {
            for session in newSessions {
                triggerAlert(event: "New SSH/Terminal Login Detected: \(session)")
            }
        }
        knownSessions = currentSessions
    }
}

let watcher = EntryWatcher()
RunLoop.main.run()
