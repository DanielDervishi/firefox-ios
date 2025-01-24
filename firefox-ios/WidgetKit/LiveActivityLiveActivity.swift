// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import SwiftUI

import Foundation
import ActivityKit
import WidgetKit

public struct OrderAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public enum OrderStatus: Float, Codable, Hashable {
            case inQueue = 0
            case aboutToTake
            case making
            case ready

            var description: String {
                switch self {
                case .inQueue:
                    return "Your order is in the queue"
                case .aboutToTake:
                    return "We're about to take your order"
                case .making:
                    return "We're preparing your order"
                case .ready:
                    return "Your order is ready to pick up!"
                }
            }
        }

        public let status: OrderStatus
    }

    public let orderNumber: Int
}

struct LiveActivityView: View {
    let state: OrderAttributes.ContentState

    var body: some View {
        VStack {
            HStack {
                Image(systemName: "cup.and.saucer")
                ProgressView(value: state.status.rawValue, total: 3)
                    .tint(.black)
                    .background(Color.brown)
                Image(systemName: "cup.and.saucer.fill")
            }
            .padding(16)

            Text("\(state.status.description)")
                .font(.system(size: 18, weight: .semibold))
                .padding(.bottom)
            Spacer()
        }
        .background(Color.brown.opacity(0.6))
    }
}

@available(iOS 16.1, *)
struct LiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: OrderAttributes.self) { context in
            // Lock screen/banner UI goes here
            LiveActivityView(state: context.state)
        } dynamicIsland: { context in
            // Define Dynamic Island regions
            DynamicIsland {
                // Expanded state (when the user interacts with the Dynamic Island)
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView() // Nothing for leading
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView() // Nothing for trailing
                }
                DynamicIslandExpandedRegion(.center) {
                    EmptyView() // No center content
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView() // No bottom content
                }
            } compactLeading: {
                EmptyView() // Compact leading (Dynamic Island collapsed state)
            } compactTrailing: {
                EmptyView() // Compact trailing (Dynamic Island collapsed state)
            } minimal: {
                EmptyView() // Minimal content (Dynamic Island minimal state)
            }
        }
    }
}

// #Preview("Notification", as: .content, using: LiveActivityAttributes.preview) {
//   LiveActivityLiveActivity()
// } contentStates: {
//    LiveActivityAttributes.ContentState.smiley
//    LiveActivityAttributes.ContentState.starEyes
// }
