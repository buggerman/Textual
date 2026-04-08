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
import Combine

// MARK: - Value Types

struct ServerItem: Identifiable {
	let id: String
	let name: String
	let isActive: Bool
	let isConnecting: Bool
	let isLoggedIn: Bool
	let isExpanded: Bool
	var channels: [ChannelItem]
}

struct ChannelItem: Identifiable {
	let id: String
	let name: String
	let isActive: Bool
	let isChannel: Bool
	let isPrivateMessage: Bool
	let unreadCount: Int
	let highlightCount: Int
}

// MARK: - Observable Model

/// Bridges ObjC IRCWorld data to SwiftUI via ServerListBridge.
final class ServerListModel: ObservableObject {
	@Published var servers: [ServerItem] = []
	@Published var selectedItemId: String?

	private var cancellables = Set<AnyCancellable>()
	private var refreshTimer: Timer?

	init() {
		// Observe client list changes
		NotificationCenter.default.publisher(for: Notification.Name("IRCWorldClientListWasModifiedNotification"))
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in self?.refresh() }
			.store(in: &cancellables)

		// Observe selection changes
		NotificationCenter.default.publisher(for: Notification.Name("TVCMainWindowSelectionChangedNotification"))
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in self?.refreshSelection() }
			.store(in: &cancellables)

		// Periodic refresh for unread counts and connection state (1 second)
		refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			DispatchQueue.main.async {
				self?.refresh()
			}
		}

		refresh()
		refreshSelection()
	}

	deinit {
		refreshTimer?.invalidate()
	}

	func refresh() {
		let snapshots = ServerListBridge.currentServers()

		var newServers: [ServerItem] = []

		for snapshot in snapshots {
			var channels: [ChannelItem] = []

			for channelSnap in snapshot.channels {
				channels.append(ChannelItem(
					id: channelSnap.uniqueId,
					name: channelSnap.name,
					isActive: channelSnap.isActive,
					isChannel: channelSnap.isChannel,
					isPrivateMessage: channelSnap.isPrivateMessage,
					unreadCount: Int(channelSnap.unreadCount),
					highlightCount: Int(channelSnap.highlightCount)
				))
			}

			newServers.append(ServerItem(
				id: snapshot.uniqueId,
				name: snapshot.name,
				isActive: snapshot.isActive,
				isConnecting: snapshot.isConnecting,
				isLoggedIn: snapshot.isLoggedIn,
				isExpanded: snapshot.isExpanded,
				channels: channels
			))
		}

		servers = newServers
	}

	func refreshSelection() {
		selectedItemId = ServerListBridge.selectedItemId()
	}

	func select(itemId: String) {
		ServerListBridge.selectItem(withId: itemId)
		selectedItemId = itemId
	}

	func toggleExpanded(serverId: String) {
		ServerListBridge.toggleExpanded(forServer: serverId)
		// The next periodic refresh will pick up the new state
		refresh()
	}

	func doubleClick(itemId: String) {
		ServerListBridge.doubleClickItem(withId: itemId)
	}
}
