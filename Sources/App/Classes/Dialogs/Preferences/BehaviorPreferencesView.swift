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

struct BehaviorPreferencesView: View {
	@AppStorage("OpenClickedLinksInBackgroundBrowser")
	private var openLinksInBackground = false

	@AppStorage("RejoinChannelOnLocalKick")
	private var rejoinOnKick = false

	@AppStorage("AutojoinChannelOnInvite")
	private var autojoinOnInvite = false

	@AppStorage("SetAwayOnScreenSleep")
	private var awayOnSleep = false

	@AppStorage("ReloadScrollbackOnLaunch")
	private var restoreScrollback = false

	@AppStorage("ServerListRetainsQueriesBetweenRestarts")
	private var restoreQueries = false

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Toggle("Open browser links in the background", isOn: $openLinksInBackground)
			Toggle("Automatically rejoin a channel when kicked", isOn: $rejoinOnKick)
			Toggle("Automatically join a channel when invited", isOn: $autojoinOnInvite)
			Toggle("Toggle away status when your display goes to sleep", isOn: $awayOnSleep)

			Divider()
				.padding(.vertical, 4)

			Toggle("Restore scrollback from previous session", isOn: $restoreScrollback)
			Toggle("Restore the state of queries from previous session", isOn: $restoreQueries)
		}
		.padding()
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

/// NSView wrapper for hosting the SwiftUI BehaviorPreferencesView in AppKit.
@objc(BehaviorPreferencesViewController)
final class BehaviorPreferencesViewController: NSObject {
	@objc static func makeView() -> NSView {
		return NSHostingView(rootView: BehaviorPreferencesView())
	}
}
