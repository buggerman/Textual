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

struct DefaultIRCopMessagesPreferencesView: View {
	@AppStorage("IRCopDefaultLocalizaiton -> Kill Reason")
	private var killReason = ""

	@AppStorage("IRCopDefaultLocalizaiton -> Shun Reason")
	private var shunReason = ""

	@AppStorage("IRCopDefaultLocalizaiton -> G:Line Reason")
	private var glineReason = ""

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Grid(alignment: .leading, verticalSpacing: 8) {
				GridRow {
					Text("Default Kill Reason:")
						.frame(width: 160, alignment: .trailing)
					TextField("", text: $killReason)
						.frame(width: 400)
				}
				GridRow {
					VStack(alignment: .trailing, spacing: 2) {
						Text("Default Shun Reason:")
						Text("(Includes Ban Length)")
							.font(.caption)
							.foregroundColor(.secondary)
					}
					.frame(width: 160, alignment: .trailing)
					TextField("", text: $shunReason)
						.frame(width: 400)
				}
				GridRow {
					VStack(alignment: .trailing, spacing: 2) {
						Text("Default G:Line Reason:")
						Text("(Includes Ban Length)")
							.font(.caption)
							.foregroundColor(.secondary)
					}
					.frame(width: 160, alignment: .trailing)
					TextField("", text: $glineReason)
						.frame(width: 400)
				}
			}
		}
		.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
		.frame(width: 670, height: 363, alignment: .topLeading)
	}
}

/// NSView wrapper for hosting the SwiftUI DefaultIRCopMessagesPreferencesView in AppKit.
@objc(DefaultIRCopMessagesPreferencesViewController)
final class DefaultIRCopMessagesPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: DefaultIRCopMessagesPreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 363)
		return view
	}
}
