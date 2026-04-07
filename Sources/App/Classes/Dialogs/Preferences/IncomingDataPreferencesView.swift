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

struct IncomingDataPreferencesView: View {
	@AppStorage("ReplyUnignoredExternalCTCPRequests")
	private var replyCTCPRequests = false

	@AppStorage("AutomaticallyDetectHighlightSpam")
	private var detectHighlightSpam = false

	@AppStorage("AutomaticallyFilterUnicodeTextSpam")
	private var filterUnicodeSpam = false

	@AppStorage("RemoveIRCTextFormatting")
	private var removeFormatting = false

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Automatically reply to Client-to-Client (CTCP) requests", isOn: $replyCTCPRequests)

			Toggle("Automatically ignore highlight spam", isOn: $detectHighlightSpam)
			Text("Do not notify you of a highlight if 75% of a message consists of ten or more nicknames.")
				.font(.caption)
				.foregroundColor(.secondary)

			Toggle("Replace Combining Diacritical Marks with \u{FFFD}", isOn: $filterUnicodeSpam)
			Text("These characters are often combined to form \"Zalgo text\", which is used by some users to disrupt chatrooms.")
				.font(.caption)
				.foregroundColor(.secondary)

			Toggle("Remove formatting from incoming messages", isOn: $removeFormatting)
		}
		.padding(EdgeInsets(top: 20, leading: 40, bottom: 20, trailing: 40))
		.frame(width: 670, height: 259, alignment: .topLeading)
	}
}

/// NSView wrapper for hosting the SwiftUI IncomingDataPreferencesView in AppKit.
@objc(IncomingDataPreferencesViewController)
final class IncomingDataPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		let view = NSHostingView(rootView: IncomingDataPreferencesView())
		view.frame = NSRect(x: 0, y: 0, width: 670, height: 259)
		return view
	}
}
