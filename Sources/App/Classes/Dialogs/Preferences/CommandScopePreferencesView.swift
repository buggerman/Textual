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

struct CommandScopePreferencesView: View {
	@AppStorage("FocusSelectionOnMessageCommandExecution")
	private var focusOnMsg = false

	@AppStorage("DestinationOfNonserverNotices")
	private var noticeSendLocation = 0

	@AppStorage("ApplyCommandToAllConnections -> amsg")
	private var amsgAllConnections = true

	@AppStorage("ApplyCommandToAllConnections -> away")
	private var awayAllConnections = true

	@AppStorage("ApplyCommandToAllConnections -> nick")
	private var nickAllConnections = false

	@AppStorage("ApplyCommandToAllConnections -> clearall")
	private var clearallAllConnections = true

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Give focus to the destination of the /msg command", isOn: $focusOnMsg)

			Divider().padding(.vertical, 4)

			Text("Forward notices to:")
				.fontWeight(.medium)

			Picker("", selection: $noticeSendLocation) {
				Text("Server Console").tag(0)
				Text("Selected Channel").tag(1)
				Text("Private Message").tag(2)
			}
			.pickerStyle(.radioGroup)
			.labelsHidden()
			.padding(.leading, 16)

			Divider().padding(.vertical, 4)

			Toggle("/amsg and /ame apply to all connections", isOn: $amsgAllConnections)
			Toggle("/away applies to all connections", isOn: $awayAllConnections)
			Toggle("/nick applies to all connections", isOn: $nickAllConnections)
			Toggle("/clearall applies to all connections", isOn: $clearallAllConnections)
		}
		.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
		.frame(width: 670, height: 312, alignment: .topLeading)
	}
}

@objc(CommandScopePreferencesViewController)
final class CommandScopePreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: CommandScopePreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 312)
		return view
	}
}
