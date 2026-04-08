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

struct ServerListView: View {
	@ObservedObject var model: ServerListModel

	var body: some View {
		List(selection: Binding(
			get: { model.selectedItemId },
			set: { newValue in
				if let id = newValue {
					model.select(itemId: id)
				}
			}
		)) {
			ForEach($model.servers) { $server in
				ServerRow(server: server, onToggle: {
					model.toggleExpanded(serverId: server.id)
				})
				.tag(server.id)
				.contentShape(Rectangle())
				.contextMenu {
					serverContextMenu(server: server)
				}

				if server.isExpanded {
					ForEach(server.channels) { channel in
						ChannelRow(channel: channel)
							.tag(channel.id)
							.contentShape(Rectangle())
							.padding(.leading, 12)
							.contextMenu {
								channelContextMenu(channel: channel)
							}
					}
				}
			}
		}
		.listStyle(.sidebar)
	}

	// MARK: - Context Menus

	@ViewBuilder
	private func serverContextMenu(server: ServerItem) -> some View {
		if server.isActive {
			Button("Disconnect") { act(server.id, "disconnect:") }
		} else {
			Button("Connect") { act(server.id, "connect:") }
		}

		Divider()

		Button("Channel List\u{2026}") { act(server.id, "showServerChannelList:") }
			.disabled(!server.isActive)
		Button("Change Nickname\u{2026}") { act(server.id, "showServerChangeNicknameSheet:") }
			.disabled(!server.isActive)

		Divider()

		Button("Add Server\u{2026}") { act(server.id, "addServer:") }
		Button("Duplicate Server") { act(server.id, "duplicateServer:") }
		Button("Delete Server\u{2026}") { act(server.id, "deleteServer:") }
			.disabled(server.isActive)

		Divider()

		Button("Add Channel\u{2026}") { act(server.id, "addChannel:") }
		Button("Server Properties\u{2026}") { act(server.id, "showServerPropertiesSheet:") }
	}

	@ViewBuilder
	private func channelContextMenu(channel: ChannelItem) -> some View {
		if channel.isActive {
			Button("Leave Channel") { act(channel.id, "leaveChannel:") }
		} else {
			Button("Join Channel") { act(channel.id, "joinChannel:") }
		}

		Divider()

		Button("Add Channel\u{2026}") { act(channel.id, "addChannel:") }
		Button("Delete Channel") { act(channel.id, "deleteChannel:") }

		Divider()

		Button("View Logs") { act(channel.id, "openChannelLogs:") }
			.disabled(!ServerListBridge.isLoggingEnabled())
		Button("Modify Topic") { act(channel.id, "showChannelModifyTopicSheet:") }
			.disabled(!channel.isActive)

		Menu("Modes") {
			Button("Modes\u{2026}") { act(channel.id, "showChannelModifyModesSheet:") }
		}
		.disabled(!channel.isActive)

		Divider()

		Button("List of Bans") { act(channel.id, "showChannelBanList:") }
			.disabled(!channel.isActive)
		Button("List of Ban Exceptions") { act(channel.id, "showChannelBanExceptionList:") }
			.disabled(!channel.isActive)
		Button("List of Invite Exceptions") { act(channel.id, "showChannelInviteExceptionList:") }
			.disabled(!channel.isActive)
		Button("List of Quiets") { act(channel.id, "showChannelQuietList:") }
			.disabled(!channel.isActive)

		Divider()

		Button("Channel Properties\u{2026}") { act(channel.id, "showChannelPropertiesSheet:") }
	}

	private func act(_ itemId: String, _ selector: String) {
		model.select(itemId: itemId)
		DispatchQueue.main.async {
			ServerListBridge.performMenuAction(selector)
		}
	}
}

// MARK: - Row Views

struct ServerRow: View {
	let server: ServerItem
	let onToggle: () -> Void

	var body: some View {
		HStack {
			Circle()
				.fill(server.isActive ? Color.green : Color.gray)
				.frame(width: 8, height: 8)

			Text(server.name)
				.font(.system(size: 12, weight: .semibold))
				.foregroundColor(server.isActive ? .primary : .secondary)

			Spacer()

			Button(action: onToggle) {
				Image(systemName: server.isExpanded ? "chevron.down" : "chevron.right")
					.font(.system(size: 9))
					.foregroundColor(.secondary)
			}
			.buttonStyle(.plain)
			.frame(width: 20, height: 20)
		}
	}
}

struct ChannelRow: View {
	let channel: ChannelItem

	var body: some View {
		HStack {
			Image(systemName: channelIcon)
				.font(.system(size: 10))
				.foregroundColor(channel.isActive ? .accentColor : .secondary)
				.frame(width: 16)

			Text(channel.name)
				.font(.system(size: 13))
				.foregroundColor(channel.isActive ? .primary : .secondary)
				.lineLimit(1)

			Spacer()

			if channel.highlightCount > 0 {
				BadgeView(count: channel.highlightCount, isHighlight: true)
			} else if channel.unreadCount > 0 {
				BadgeView(count: channel.unreadCount, isHighlight: false)
			}
		}
	}

	private var channelIcon: String {
		if channel.isPrivateMessage {
			return "person.fill"
		} else {
			return "text.bubble"
		}
	}
}

struct BadgeView: View {
	let count: Int
	let isHighlight: Bool

	var body: some View {
		Text("\(count)")
			.font(.system(size: 10, weight: .bold))
			.foregroundColor(.white)
			.padding(.horizontal, 6)
			.padding(.vertical, 1)
			.background(
				Capsule()
					.fill(isHighlight ? Color.red : Color.gray)
			)
	}
}

// MARK: - Debug Panel

@objc(ServerListSwiftViewController)
final class ServerListSwiftViewController: NSObject {
	private static let model = ServerListModel()
	private static var panel: NSPanel?

	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: ServerListView(model: model))
		return view
	}

	@objc static func showDebugPanel() {
		if let existing = panel {
			existing.makeKeyAndOrderFront(nil)
			return
		}

		let hostingView = NSHostingView(rootView: ServerListView(model: model))

		let p = NSPanel(
			contentRect: NSRect(x: 100, y: 100, width: 220, height: 500),
			styleMask: [.titled, .closable, .resizable, .utilityWindow],
			backing: .buffered,
			defer: false
		)
		p.title = "SwiftUI Sidebar (Preview)"
		p.contentView = hostingView
		p.isFloatingPanel = true
		p.makeKeyAndOrderFront(nil)

		panel = p
	}
}
