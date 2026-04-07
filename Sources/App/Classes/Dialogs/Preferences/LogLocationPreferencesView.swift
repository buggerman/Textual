/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2026 Contributors
 *
 *********************************************************************** */

import SwiftUI

struct LogLocationPreferencesView: View {
	@State private var loggingEnabled: Bool
	@State private var folderName: String

	init() {
		let enabled = UserDefaults.standard.bool(forKey: "LogTranscript")
		let bookmark = UserDefaults.standard.data(forKey: "LogTranscriptDestinationSecurityBookmark_5")
		var name = "No folder selected"
		if let bookmark = bookmark {
			var stale = false
			if let url = try? URL(resolvingBookmarkData: bookmark,
								  options: .withSecurityScope,
								  relativeTo: nil,
								  bookmarkDataIsStale: &stale) {
				name = url.lastPathComponent
			}
		}
		_loggingEnabled = State(initialValue: enabled)
		_folderName = State(initialValue: name)
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Log transcripts to folder:", isOn: $loggingEnabled)
				.onChange(of: loggingEnabled) {
					UserDefaults.standard.set(loggingEnabled, forKey: "LogTranscript")
					PreferencesReloadHelper.performReload(0x8000) // LogTranscripts
				}

			HStack {
				Text(folderName)
					.foregroundColor(.secondary)
					.lineLimit(1)
					.frame(maxWidth: 300, alignment: .leading)

				Button("Select Folder\u{2026}") {
					selectFolder()
				}

				Button("Clear") {
					clearFolder()
				}
			}
			.padding(.leading, 20)
		}
		.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
		.frame(width: 670, height: 80, alignment: .topLeading)
	}

	private func selectFolder() {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = true
		panel.canChooseFiles = false
		panel.canCreateDirectories = true
		panel.prompt = "Select"

		guard panel.runModal() == .OK, let url = panel.url else { return }

		if let bookmark = try? url.bookmarkData(options: .withSecurityScope,
												includingResourceValuesForKeys: nil,
												relativeTo: nil) {
			UserDefaults.standard.set(bookmark, forKey: "LogTranscriptDestinationSecurityBookmark_5")
			folderName = url.lastPathComponent
			PreferencesReloadHelper.performReload(0x8000) // LogTranscripts
		}
	}

	private func clearFolder() {
		UserDefaults.standard.removeObject(forKey: "LogTranscriptDestinationSecurityBookmark_5")
		folderName = "No folder selected"
		PreferencesReloadHelper.performReload(0x8000) // LogTranscripts
	}
}

@objc(LogLocationPreferencesViewController)
final class LogLocationPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: LogLocationPreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 80)
		return view
	}
}
