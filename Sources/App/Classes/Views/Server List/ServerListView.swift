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
			ForEach(model.servers) { server in
				Section(isExpanded: .constant(server.isExpanded)) {
					ForEach(server.channels) { channel in
						ChannelRow(channel: channel)
							.tag(channel.id)
							.onTapGesture(count: 2) {
								model.doubleClick(itemId: channel.id)
							}
					}
				} header: {
					ServerRow(server: server)
						.tag(server.id)
						.onTapGesture(count: 2) {
							model.doubleClick(itemId: server.id)
						}
				}
			}
		}
		.listStyle(.sidebar)
	}
}

// MARK: - Row Views

struct ServerRow: View {
	let server: ServerItem

	var body: some View {
		HStack {
			Text(server.name)
				.font(.system(size: 12, weight: .semibold))
				.foregroundColor(server.isActive ? .primary : .secondary)
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
		} else if channel.isChannel {
			return "number"
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

// MARK: - NSView Wrapper

@objc(ServerListSwiftViewController)
final class ServerListSwiftViewController: NSObject {
	private static let model = ServerListModel()

	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: ServerListView(model: model))
		return view
	}
}
