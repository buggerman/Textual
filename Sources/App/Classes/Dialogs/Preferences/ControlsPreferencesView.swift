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

struct ControlsPreferencesView: View {
	// MARK: - Double Click

	@AppStorage("ServerListDoubleClickConnectServer")
	private var doubleClickConnect = false

	@AppStorage("ServerListDoubleClickDisconnectServer")
	private var doubleClickDisconnect = false

	@AppStorage("ServerListDoubleClickJoinChannel")
	private var doubleClickJoin = false

	@AppStorage("ServerListDoubleClickLeaveChannel")
	private var doubleClickLeave = false

	// MARK: - Selection

	@AppStorage("CopyTextSelectionOnMouseUp")
	private var copyOnSelect = false

	@AppStorage("ChannelNavigationIsServerSpecific")
	private var channelNavServerSpecific = false

	// MARK: - Popups

	@AppStorage("UserListDoubleClickAction")
	private var userListDoubleClick = 200

	@AppStorage("Keyboard -> Command+W Key Action")
	private var commandWAction = 0

	@AppStorage("Keyboard -> Tab Key Action")
	private var tabKeyAction = 0

	@AppStorage("Keyboard -> Tab Key Completion Suffix")
	private var tabCompletionSuffix = ""

	@AppStorage("Main Input Text Field -> Font Size")
	private var inputFontSize = 1

	// MARK: - Input Field

	@AppStorage("TextFieldAutomaticSpellCheck")
	private var spellCheck = false

	@AppStorage("TextFieldAutomaticGrammarCheck")
	private var grammarCheck = false

	@AppStorage("TextFieldAutomaticSpellCorrection")
	private var spellCorrection = false

	@AppStorage("SaveInputHistoryPerSelection")
	private var historyPerChannel = false

	@AppStorage("CommandReturnSendsMessageAsAction")
	private var commandReturnAction = false

	@AppStorage("ControlEnterSendsMessage")
	private var controlEnterSends = false

	@AppStorage("DisableMainWindowSegmentedController")
	private var hideSegmentedController = false

	var body: some View {
		VStack(alignment: .leading, spacing: 6) {
			// Double click section
			Toggle("Connect to server on double click", isOn: $doubleClickConnect)
			Toggle("Disconnect from server on double click", isOn: $doubleClickDisconnect)
			Toggle("Join channel on double click", isOn: $doubleClickJoin)
			Toggle("Leave channel on double click", isOn: $doubleClickLeave)

			Divider().padding(.vertical, 2)

			Toggle("Automatically copy selected text", isOn: $copyOnSelect)
			Text("Hold the Option key (\u{2325}) while selecting text to temporarily disable this feature.")
				.font(.caption)
				.foregroundColor(.secondary)
				.padding(.leading, 20)

			Toggle("Channel navigation is limited to the selected server", isOn: $channelNavServerSpecific)

			Divider().padding(.vertical, 2)

			// Popup menus
			HStack {
				Text("Double clicking a user:")
				Picker("", selection: $userListDoubleClick) {
					Text("Open Query").tag(200)
					Text("Whois User").tag(100)
					Text("Insert Name Into Text Field").tag(300)
				}
				.labelsHidden()
				.frame(width: 220)
			}

			HStack {
				Text("Command + W key action:")
				Picker("", selection: $commandWAction) {
					Text("Close Main Window").tag(0)
					Text("Close Selected Query or Part Selected Channel").tag(1)
					Text("Disconnect from Selected Server").tag(2)
					Text("Disconnect and Quit Application").tag(3)
				}
				.labelsHidden()
				.frame(width: 320)
			}

			HStack {
				Text("Tab key action:")
				Picker("", selection: $tabKeyAction) {
					Text("Complete nicknames, channels, and commands").tag(0)
					Text("Move to next unread channel").tag(1)
					Text("Perform no action").tag(100)
				}
				.labelsHidden()
				.frame(width: 300)
			}

			HStack {
				Text("Autocomplete Suffix:")
				TextField("", text: $tabCompletionSuffix)
					.frame(width: 60)
				Text("Preview:")
					.foregroundColor(.secondary)
				Text("nick\(tabCompletionSuffix)")
					.foregroundColor(.secondary)
			}

			HStack {
				Text("Text size of the input text field:")
				Picker("", selection: $inputFontSize) {
					Text("Normal").tag(1)
					Text("Large").tag(2)
					Text("Extra Large").tag(3)
					Text("Humongous").tag(4)
				}
				.labelsHidden()
				.frame(width: 130)
				.onChange(of: inputFontSize) { _ in
					performReload(0x800000) // TPCPreferencesReloadActionTextFieldFontSize = 1 << 23
				}
			}

			Divider().padding(.vertical, 2)

			Toggle("Check spelling while typing", isOn: $spellCheck)
			Toggle("Check grammar while typing", isOn: $grammarCheck)
			Toggle("Correct spelling automatically", isOn: $spellCorrection)

			Divider().padding(.vertical, 2)

			Toggle("Save input history for each channel rather than globally", isOn: $historyPerChannel)
				.onChange(of: historyPerChannel) { _ in
					performReload(0x10) // TPCPreferencesReloadActionInputHistoryScope = 1 << 4
				}
			Toggle("Command Return (\u{2318}\u{23CE}) sends message as an action", isOn: $commandReturnAction)
			Toggle("Control Enter (\u{2303}\u{2386}) sends message instead of inserting new line", isOn: $controlEnterSends)
			Toggle("Hide the buttons left of the input text field", isOn: $hideSegmentedController)
				.onChange(of: hideSegmentedController) { _ in
					performReload(0x400000) // TPCPreferencesReloadActionTextFieldSegmentedControllerOrigin = 1 << 22
				}
		}
		.padding(EdgeInsets(top: 14, leading: 40, bottom: 14, trailing: 40))
		.frame(width: 670, height: 536, alignment: .topLeading)
	}

	private func performReload(_ action: UInt) {
		PreferencesReloadHelper.performReload(action)
	}
}

@objc(ControlsPreferencesViewController)
final class ControlsPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: ControlsPreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 536)
		return view
	}
}
