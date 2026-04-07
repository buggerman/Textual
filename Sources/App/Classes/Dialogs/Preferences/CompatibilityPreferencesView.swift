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

struct CompatibilityPreferencesView: View {
	@AppStorage("IRC -> Enable echo-message Capability")
	private var echoMessage = false

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Enable echo-message capability", isOn: $echoMessage)
		}
		.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
		.frame(width: 670, height: 76, alignment: .topLeading)
	}
}

@objc(CompatibilityPreferencesViewController)
final class CompatibilityPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: CompatibilityPreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 76)
		return view
	}
}
