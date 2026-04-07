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

struct ChannelManagementPreferencesView: View {
	@AppStorage("ChannelOperatorDefaultLocalization -> Kick Reason")
	private var kickReason = ""

	@AppStorage("DefaultBanCommandHostmaskFormat")
	private var hostmaskFormat = 0

	private let hostmaskOptions = [
		"*!*@address",
		"*!ident@address",
		"nickname!*@address",
		"nickname!username@address"
	]

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Grid(alignment: .leading, verticalSpacing: 8) {
				GridRow {
					Text("Default Kick Reason:")
						.frame(width: 160, alignment: .trailing)
					TextField("", text: $kickReason)
						.frame(width: 400)
				}
				GridRow {
					Text("Hostmask Ban Format:")
						.frame(width: 160, alignment: .trailing)
					Picker("", selection: $hostmaskFormat) {
						ForEach(0..<hostmaskOptions.count, id: \.self) { index in
							Text(hostmaskOptions[index]).tag(index)
						}
					}
					.labelsHidden()
					.frame(width: 400)
				}
			}

			Text("When used in the context of a hostmask, an asterisk (*) represents a wildcard character that is matched by any possible value.")
				.font(.caption)
				.foregroundColor(.secondary)
		}
		.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
		.frame(width: 670, height: 212, alignment: .topLeading)
	}
}

/// NSView wrapper for hosting the SwiftUI ChannelManagementPreferencesView in AppKit.
@objc(ChannelManagementPreferencesViewController)
final class ChannelManagementPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: ChannelManagementPreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 212)
		return view
	}
}
