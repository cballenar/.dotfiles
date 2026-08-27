import Foundation
import CoreAudio

// MARK: - Configuration Model

struct Config: Codable, Equatable {
    var targetInput: String
    var targetOutput: String
    var bufferSize: Int
    var soxPath: String
    var soxEffects: [String]

    enum CodingKeys: String, CodingKey {
        case targetInput = "target_input"
        case targetOutput = "target_output"
        case bufferSize = "buffer_size"
        case soxPath = "sox_path"
        case soxEffects = "sox_effects"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.targetInput = try container.decodeIfPresent(String.self, forKey: .targetInput) ?? ""
        self.targetOutput = try container.decodeIfPresent(String.self, forKey: .targetOutput) ?? ""
        self.bufferSize = try container.decodeIfPresent(Int.self, forKey: .bufferSize) ?? 64
        self.soxPath = try container.decodeIfPresent(String.self, forKey: .soxPath) ?? "/opt/homebrew/bin/sox"
        self.soxEffects = try container.decodeIfPresent([String].self, forKey: .soxEffects) ?? []
    }

    init(
        targetInput: String = "",
        targetOutput: String = "",
        bufferSize: Int = 64,
        soxPath: String = "/opt/homebrew/bin/sox",
        soxEffects: [String] = []
    ) {
        self.targetInput = targetInput
        self.targetOutput = targetOutput
        self.bufferSize = bufferSize
        self.soxPath = soxPath
        self.soxEffects = soxEffects
    }

    static var empty: Config {
        Config()
    }

    static func resolveConfigURL(from customPath: String? = nil) -> URL {
        if let customPath = customPath {
            return URL(fileURLWithPath: (customPath as NSString).expandingTildeInPath).resolvingSymlinksInPath()
        }
        let homeDir = FileManager.default.homeDirectoryForCurrentUser
        let symlinkURL = homeDir.appendingPathComponent(".config/sidetone/config.json")
        return symlinkURL.resolvingSymlinksInPath()
    }

    static func load(from customPath: String? = nil) -> Config {
        let configURL = resolveConfigURL(from: customPath)

        guard FileManager.default.fileExists(atPath: configURL.path) else {
            return .empty
        }

        do {
            let data = try Data(contentsOf: configURL)
            let decoded = try JSONDecoder().decode(Config.self, from: data)
            return decoded
        } catch {
            print("⚠️ Failed to parse config at \(configURL.path): \(error)")
            return .empty
        }
    }
}

// MARK: - CoreAudio Device Helpers

func getAllAudioDevices() -> [String] {
    var propertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    var dataSize: UInt32 = 0
    guard AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &dataSize) == noErr else {
        return []
    }

    let deviceCount = Int(dataSize) / MemoryLayout<AudioDeviceID>.size
    var deviceIDs = [AudioDeviceID](repeating: 0, count: deviceCount)

    guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &propertyAddress, 0, nil, &dataSize, &deviceIDs) == noErr else {
        return []
    }

    var names: [String] = []
    for deviceID in deviceIDs {
        var nameAddress = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyName,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var name: CFString = "" as CFString
        var nameSize = UInt32(MemoryLayout<CFString>.size)

        let status = withUnsafeMutablePointer(to: &name) { ptr in
            AudioObjectGetPropertyData(deviceID, &nameAddress, 0, nil, &nameSize, ptr)
        }

        if status == noErr {
            names.append(name as String)
        }
    }

    return names
}

func getDeviceName(selector: AudioObjectPropertySelector) -> String {
    var deviceID = AudioDeviceID(0)
    var size = UInt32(MemoryLayout<AudioDeviceID>.size)
    var address = AudioObjectPropertyAddress(
        mSelector: selector,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )

    guard AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &deviceID) == noErr,
          deviceID != kAudioObjectUnknown else {
        return ""
    }

    var name: CFString = "" as CFString
    var nameSize = UInt32(MemoryLayout<CFString>.size)
    address.mSelector = kAudioObjectPropertyName

    let status = withUnsafeMutablePointer(to: &name) { ptr in
        AudioObjectGetPropertyData(deviceID, &address, 0, nil, &nameSize, ptr)
    }

    guard status == noErr else { return "" }
    return name as String
}

// MARK: - Sidetone Controller

class SidetoneController {
    private var customConfigPath: String?
    private var config: Config
    private var soxProcess: Process?
    private var lastRunningArguments: [String] = []
    private var lastFileModDate: Date?
    private var pollTimer: DispatchSourceTimer?

    init(customConfigPath: String? = nil) {
        self.customConfigPath = customConfigPath
        self.config = Config.load(from: customConfigPath)
    }

    func start() {
        checkAndSyncDevices()
        registerAudioListeners()
        startConfigWatcher()
    }

    func stop() {
        stopSox()
        pollTimer?.cancel()
        pollTimer = nil
    }

    private func registerAudioListeners() {
        registerListener(selector: kAudioHardwarePropertyDefaultInputDevice)
        registerListener(selector: kAudioHardwarePropertyDefaultOutputDevice)
    }

    private func registerListener(selector: AudioObjectPropertySelector) {
        var address = AudioObjectPropertyAddress(
            mSelector: selector,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        AudioObjectAddPropertyListenerBlock(
            AudioObjectID(kAudioObjectSystemObject),
            &address,
            DispatchQueue.main
        ) { [weak self] _, _ in
            self?.checkAndSyncDevices()
        }
    }

    private func startConfigWatcher() {
        let configURL = Config.resolveConfigURL(from: customConfigPath)
        if let attrs = try? FileManager.default.attributesOfItem(atPath: configURL.path),
           let modDate = attrs[.modificationDate] as? Date {
            self.lastFileModDate = modDate
        }

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: .now() + .milliseconds(500), repeating: .milliseconds(500))
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            let resolvedURL = Config.resolveConfigURL(from: self.customConfigPath)
            guard let attrs = try? FileManager.default.attributesOfItem(atPath: resolvedURL.path),
                  let modDate = attrs[.modificationDate] as? Date else { return }

            if self.lastFileModDate == nil || modDate > self.lastFileModDate! {
                self.lastFileModDate = modDate
                print("⚙️ Config file updated: \(modDate). Reloading...")
                self.checkAndSyncDevices()
            }
        }
        timer.resume()
        self.pollTimer = timer
    }

    func checkAndSyncDevices() {
        let latestConfig = Config.load(from: customConfigPath)
        self.config = latestConfig

        let inputName = getDeviceName(selector: kAudioHardwarePropertyDefaultInputDevice)
        let outputName = getDeviceName(selector: kAudioHardwarePropertyDefaultOutputDevice)

        print("🔍 Audio State -> Input: [\(inputName)], Output: [\(outputName)]")

        guard !config.targetInput.isEmpty, !config.targetOutput.isEmpty else {
            print("⚠️ target_input or target_output is not configured. Set them in config.json. Idling.")
            stopSox()
            return
        }

        let isMatch = (inputName == config.targetInput && outputName == config.targetOutput)

        if isMatch {
            startOrUpdateSox()
        } else {
            stopSox()
        }
    }

    private func buildSoxArguments() -> (path: String, args: [String])? {
        var resolvedSoxPath = config.soxPath
        if !FileManager.default.fileExists(atPath: resolvedSoxPath) {
            let fallbacks = ["/usr/local/bin/sox", "/opt/homebrew/bin/sox"]
            if let found = fallbacks.first(where: { FileManager.default.fileExists(atPath: $0) }) {
                resolvedSoxPath = found
            } else {
                print("❌ sox not found at \(config.soxPath) or common paths.")
                return nil
            }
        }

        var arguments = [
            "-q",
            "--buffer", String(config.bufferSize),
            "-t", "coreaudio", config.targetInput,
            "-t", "coreaudio", config.targetOutput
        ]

        for effect in config.soxEffects where !effect.trimmingCharacters(in: .whitespaces).isEmpty {
            let parts = effect.split(separator: " ").map(String.init)
            arguments.append(contentsOf: parts)
        }

        return (resolvedSoxPath, arguments)
    }

    private func startOrUpdateSox() {
        guard let (soxPath, arguments) = buildSoxArguments() else { return }

        // If already running with the exact same arguments, do nothing
        if let currentProcess = soxProcess, currentProcess.isRunning {
            if lastRunningArguments == arguments {
                return
            }
            print("🔄 Config updated while running. Restarting sox with new settings...")
            stopSox()
        }

        print("🎙️ Starting sox: \(arguments.joined(separator: " "))")

        let p = Process()
        p.executableURL = URL(fileURLWithPath: soxPath)
        p.arguments = arguments

        do {
            try p.run()
            self.soxProcess = p
            self.lastRunningArguments = arguments
        } catch {
            print("❌ Failed to launch sox: \(error)")
        }
    }

    private func stopSox() {
        if let p = soxProcess, p.isRunning {
            print("🛑 Stopping sidetone...")
            p.terminate()
        }
        self.soxProcess = nil
        self.lastRunningArguments = []
    }
}

// MARK: - CLI Entry Point

func printUsage() {
    print("""
    Sidetone: Minimalist microphone monitoring daemon for macOS.

    Usage:
      sidetone [options]

    Options:
      -l, --list-devices     List all detected CoreAudio device names
      -c, --config <path>    Path to custom JSON configuration file
      -h, --help             Show this help message

    Configuration:
      Default path: ~/.config/sidetone/config.json
    """)
}

let args = CommandLine.arguments

if args.contains("-h") || args.contains("--help") {
    printUsage()
    exit(0)
}

if args.contains("-l") || args.contains("--list-devices") {
    print("Detected CoreAudio Devices:")
    for device in Set(getAllAudioDevices()).sorted() {
        print("  • \(device)")
    }
    exit(0)
}

var customConfigPath: String? = nil
if let configIndex = args.firstIndex(where: { $0 == "-c" || $0 == "--config" }),
   configIndex + 1 < args.count {
    customConfigPath = args[configIndex + 1]
}

let controller = SidetoneController(customConfigPath: customConfigPath)

// Handle clean shutdown signals
signal(SIGINT) { _ in
    controller.stop()
    exit(0)
}
signal(SIGTERM) { _ in
    controller.stop()
    exit(0)
}

controller.start()
RunLoop.main.run()
