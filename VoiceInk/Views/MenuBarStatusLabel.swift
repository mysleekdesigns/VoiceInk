import SwiftUI

/// Menu-bar icon that mirrors the engine's recording state, so dictation
/// feedback is visible even when the recorder panel is hidden.
struct MenuBarStatusLabel: View {
    @ObservedObject var engine: VoiceInkEngine

    var body: some View {
        switch engine.recordingState {
        case .starting, .recording:
            Image(systemName: "record.circle.fill")
                .font(.system(size: 16, weight: .medium))
        case .transcribing, .enhancing, .busy:
            Image(systemName: "waveform")
                .font(.system(size: 16, weight: .medium))
        case .idle:
            Image(nsImage: Self.idleIcon)
        }
    }

    /// The upstream static asset, resized for the menu bar (22 pt tall).
    /// Resizes a copy so the shared NSImage(named:) cache keeps its original size.
    @MainActor private static let idleIcon: NSImage = {
        guard let cached = NSImage(named: "menuBarIcon") else {
            return NSImage(systemSymbolName: "mic", accessibilityDescription: nil) ?? NSImage()
        }
        let image = (cached.copy() as? NSImage) ?? cached
        let ratio = image.size.height / image.size.width
        image.size.height = 22
        image.size.width = 22 / ratio
        return image
    }()
}
