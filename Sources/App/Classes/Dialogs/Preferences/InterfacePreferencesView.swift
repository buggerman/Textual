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

// MARK: - Color UserDefaults Helper

/// Reads/writes archived NSColor values from UserDefaults.
/// NSColor is stored as archived Data using NSKeyedArchiver.
final class ColorPreference: ObservableObject {
	private let key: String
	private let fallback: NSColor

	@Published var color: Color {
		didSet { save() }
	}

	init(key: String, fallback: NSColor = .clear) {
		self.key = key
		self.fallback = fallback

		if let data = UserDefaults.standard.data(forKey: key),
		   let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) {
			self.color = Color(nsColor: nsColor)
		} else {
			self.color = Color(nsColor: fallback)
		}
	}

	private func save() {
		let nsColor = NSColor(color)
		if nsColor == fallback || nsColor == .clear {
			UserDefaults.standard.removeObject(forKey: key)
		} else if let data = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: true) {
			UserDefaults.standard.set(data, forKey: key)
		}
	}

	func reset() {
		UserDefaults.standard.removeObject(forKey: key)
		color = Color(nsColor: fallback)
	}
}

// MARK: - Interface Preferences View

struct InterfacePreferencesView: View {
	// Checkboxes
	@AppStorage("DisplayUserListNoModeSymbol")
	private var showNoModeSymbol = false

	@AppStorage("MemberListSortFavorsServerStaff")
	private var sortFavorsStaff = false

	@AppStorage("MemberListUpdatesUserInfoPopoverOnScroll")
	private var popoverOnScroll = false

	@AppStorage("RightToLeftTextFormatting")
	private var rightToLeft = false

	// Popups
	@AppStorage("Appearance")
	private var appearance = 0

	@AppStorage("ChannelViewArrangement")
	private var channelArrangement = 0

	// Slider
	@AppStorage("MainWindowTransparencyLevel")
	private var transparency = 0.0

	// Colors
	@StateObject private var badgeHighlight = ColorPreference(
		key: "Server List Unread Message Count Badge Colors -> Highlight")
	@StateObject private var colorY = ColorPreference(
		key: "User List Mode Badge Colors -> +y")
	@StateObject private var colorQ = ColorPreference(
		key: "User List Mode Badge Colors -> +q")
	@StateObject private var colorA = ColorPreference(
		key: "User List Mode Badge Colors -> +a")
	@StateObject private var colorO = ColorPreference(
		key: "User List Mode Badge Colors -> +o")
	@StateObject private var colorH = ColorPreference(
		key: "User List Mode Badge Colors -> +h")
	@StateObject private var colorV = ColorPreference(
		key: "User List Mode Badge Colors -> +v")

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Use \"x\" to indicate user with no mode set in user list", isOn: $showNoModeSymbol)
			Toggle("Place known server staff members at top of user list", isOn: $sortFavorsStaff)
			Toggle("User list info popover updates while scrolling", isOn: $popoverOnScroll)
			Toggle("Right to left text", isOn: $rightToLeft)
				.onChange(of: rightToLeft) {
					PreferencesReloadHelper.performReload(0x1 | 0x4) // Style | TextDirection
				}

			Divider().padding(.vertical, 2)

			HStack {
				Text("Main window appearance:")
				Picker("", selection: $appearance) {
					Text("Your Mac's Default").tag(0)
					Text("Light").tag(1)
					Text("Dark").tag(2)
				}
				.labelsHidden()
				.frame(width: 180)
				.onChange(of: appearance) {
					PreferencesReloadHelper.performReload(0x80) // Appearance
				}
			}

			HStack {
				Text("Main window transparency:")
				Slider(value: $transparency, in: 0...1)
					.frame(width: 200)
					.onChange(of: transparency) {
						// Direct call to update window alpha
						NSApp.mainWindow?.alphaValue = CGFloat(1.0 - transparency)
					}
				Text("\(Int((1.0 - transparency) * 100))%")
					.frame(width: 35, alignment: .trailing)
					.foregroundColor(.secondary)
			}

			HStack {
				Text("Arrange multiple channels:")
				Picker("", selection: $channelArrangement) {
					Text("Top to bottom").tag(0)
					Text("Left to right").tag(1)
				}
				.labelsHidden()
				.frame(width: 160)
				.onChange(of: channelArrangement) {
					PreferencesReloadHelper.performReload(0x100) // ChannelViewArrangement
				}
			}

			Divider().padding(.vertical, 2)

			HStack {
				Text("Background color for unread badge with highlight:")
				ColorPicker("", selection: $badgeHighlight.color)
					.labelsHidden()
				Button("Reset") {
					badgeHighlight.reset()
					PreferencesReloadHelper.performReload(0x2000000 | 0x200) // ServerListUnreadBadge | ServerList
				}
			}

			Divider().padding(.vertical, 2)

			Text("These colors represent the various user modes shown on the user list for each channel.")
				.font(.caption)
				.foregroundColor(.secondary)

			Grid(alignment: .leading, verticalSpacing: 6) {
				GridRow {
					Text("Server Staff Member:").frame(width: 180, alignment: .trailing)
					ColorPicker("", selection: $colorY.color).labelsHidden()
				}
				GridRow {
					Text("Channel Owner (+q):").frame(width: 180, alignment: .trailing)
					ColorPicker("", selection: $colorQ.color).labelsHidden()
				}
				GridRow {
					Text("Channel Administrator (+a):").frame(width: 180, alignment: .trailing)
					ColorPicker("", selection: $colorA.color).labelsHidden()
				}
				GridRow {
					Text("Channel Operator (+o):").frame(width: 180, alignment: .trailing)
					ColorPicker("", selection: $colorO.color).labelsHidden()
				}
				GridRow {
					Text("Channel Half-Operator (+h):").frame(width: 180, alignment: .trailing)
					ColorPicker("", selection: $colorH.color).labelsHidden()
				}
				GridRow {
					Text("Voiced User (+v):").frame(width: 180, alignment: .trailing)
					ColorPicker("", selection: $colorV.color).labelsHidden()
				}
			}

			Button("Reset to Defaults") {
				[colorY, colorQ, colorA, colorO, colorH, colorV].forEach { $0.reset() }
				PreferencesReloadHelper.performReload(0x1000000 | 0x200) // MemberListUserBadges | MemberList
			}
		}
		.padding(EdgeInsets(top: 14, leading: 40, bottom: 14, trailing: 40))
		.frame(width: 670, height: 436, alignment: .topLeading)
	}
}

@objc(InterfacePreferencesViewController)
final class InterfacePreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: InterfacePreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 436)
		return view
	}
}
