/* *********************************************************************
 *                  _____         _               _
 *                 |_   _|____  _| |_ _   _  __ _| |
 *                   | |/ _ \ \/ / __| | | |/ _` | |
 *                   | |  __/>  <| |_| |_| | (_| | |
 *                   |_|\___/_/\_\\__|\__,_|\__,_|_|
 *
 * Copyright (c) 2026 Contributors
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *********************************************************************** */

import SwiftUI

struct DefaultIdentityPreferencesView: View {
	@AppStorage("DefaultIdentity -> Nickname")
	private var nickname = ""

	@AppStorage("DefaultIdentity -> AwayNickname")
	private var awayNickname = ""

	@AppStorage("DefaultIdentity -> Username")
	private var username = ""

	@AppStorage("DefaultIdentity -> Realname")
	private var realname = ""

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("The following information will be filled in when creating a NEW connection.")

			Grid(alignment: .leading, verticalSpacing: 8) {
				GridRow {
					Text("Nickname:")
						.frame(width: 120, alignment: .trailing)
					TextField("", text: $nickname)
						.frame(width: 200)
				}
				GridRow {
					Text("Away Nickname:")
						.frame(width: 120, alignment: .trailing)
					TextField("", text: $awayNickname)
						.frame(width: 200)
				}
				GridRow {
					Text("Username:")
						.frame(width: 120, alignment: .trailing)
					TextField("", text: $username)
						.frame(width: 200)
				}
				GridRow {
					Text("Real name:")
						.frame(width: 120, alignment: .trailing)
					TextField("", text: $realname)
						.frame(width: 200)
				}
			}

			Text("All fields are optional")
				.font(.caption)
				.foregroundColor(.secondary)
		}
		.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
		.frame(width: 670, height: 243, alignment: .topLeading)
	}
}

/// NSView wrapper for hosting the SwiftUI DefaultIdentityPreferencesView in AppKit.
@objc(DefaultIdentityPreferencesViewController)
final class DefaultIdentityPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: DefaultIdentityPreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 243)
		return view
	}
}
