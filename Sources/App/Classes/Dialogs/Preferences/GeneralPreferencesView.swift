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

struct GeneralPreferencesView: View {
	@AppStorage("ConfirmApplicationQuit")
	private var confirmQuit = false

	@AppStorage("ReceiveBetaUpdates")
	private var betaUpdates = false

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Request confirmation before quitting Textual", isOn: $confirmQuit)

			Divider().padding(.vertical, 4)

			Text("Updates:")
				.fontWeight(.medium)

			Toggle("Enable beta updates", isOn: $betaUpdates)
				.onChange(of: betaUpdates) {
					PreferencesReloadHelper.performReload(0x800000) // SparkleFrameworkFeedURL
				}
		}
		.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
		.frame(width: 670, height: 199, alignment: .topLeading)
	}
}

@objc(GeneralPreferencesViewController)
final class GeneralPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: GeneralPreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 199)
		return view
	}
}
