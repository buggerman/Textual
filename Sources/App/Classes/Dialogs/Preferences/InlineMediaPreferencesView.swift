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

struct InlineMediaPreferencesView: View {
	@AppStorage("DisplayEventInLogView -> Inline Media")
	private var showInlineMedia = false

	@AppStorage("InlineMediaMaximumFilesize")
	private var maxFilesize = 10

	@AppStorage("InlineMediaMaximumHeight")
	private var maxHeight = 300

	@AppStorage("InlineMediaScalingWidth")
	private var maxWidth = 300

	@AppStorage("InlineMediaCheckEverything")
	private var checkEverything = false

	@AppStorage("InlineMediaLimitToBasics")
	private var limitToBasics = true

	@AppStorage("InlineMediaLimitBasicsToFiles")
	private var limitBasicsToFiles = false

	@AppStorage("InlineMediaLimitNaughtyContent")
	private var limitNaughtyContent = true

	@AppStorage("InlineMediaLimitUnsafeContent")
	private var limitUnsafeContent = true

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Show images, videos, and other media inline with chat", isOn: $showInlineMedia)
				.onChange(of: showInlineMedia) {
					// Reload theme to show/hide inline media
					PreferencesReloadHelper.performReload(0x1) // Style
				}

			Text("This preference can be enabled or disabled for individual channels in Channel Properties.")
				.font(.caption)
				.foregroundColor(.secondary)
				.padding(.leading, 20)

			Divider().padding(.vertical, 2)

			HStack {
				Text("Do not display images with a file size greater than")
				Picker("", selection: $maxFilesize) {
					Text("1 Megabyte").tag(1)
					Text("2 Megabytes").tag(2)
					Text("3 Megabytes").tag(3)
					Text("4 Megabytes").tag(4)
					Text("5 Megabytes").tag(5)
					Text("10 Megabytes").tag(6)
					Text("15 Megabytes").tag(7)
					Text("20 Megabytes").tag(8)
					Text("50 Megabytes").tag(9)
					Text("100 Megabytes").tag(10)
				}
				.labelsHidden()
				.frame(width: 150)
			}

			HStack {
				Text("Do not display images with a height greater than")
				TextField("", value: $maxHeight, format: .number)
					.frame(width: 60)
				Text("pixels")
			}

			Text("Change the value of this preference to zero (0) to disable height checks.")
				.font(.caption)
				.foregroundColor(.secondary)
				.padding(.leading, 20)

			HStack {
				Text("Scale to a maximum of")
				TextField("", value: $maxWidth, format: .number)
					.frame(width: 60)
				Text("pixels wide")
			}

			Divider().padding(.vertical, 2)

			Toggle("Load everything", isOn: $checkEverything)

			Text("Load the contents of every URL posted in a channel to determine which are images or videos.")
				.font(.caption)
				.foregroundColor(.secondary)
				.padding(.leading, 20)

			Divider().padding(.vertical, 2)

			Toggle("Only inline images and videos", isOn: $limitToBasics)

			Toggle("Including video services such as YouTube and others", isOn: $limitBasicsToFiles)
				.disabled(!limitToBasics)
				.padding(.leading, 20)

			Toggle("Only inline media that is safe to view in public", isOn: $limitNaughtyContent)

			Toggle("Only inline media from safe sources", isOn: $limitUnsafeContent)

			Text("Safe sources are services that don't inject HTML nor load external JavaScript resources to appear inline.")
				.font(.caption)
				.foregroundColor(.secondary)
				.padding(.leading, 20)
		}
		.padding(EdgeInsets(top: 14, leading: 40, bottom: 14, trailing: 40))
		.frame(width: 670, height: 440, alignment: .topLeading)
	}
}

@objc(InlineMediaPreferencesViewController)
final class InlineMediaPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: InlineMediaPreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 440)
		return view
	}
}
