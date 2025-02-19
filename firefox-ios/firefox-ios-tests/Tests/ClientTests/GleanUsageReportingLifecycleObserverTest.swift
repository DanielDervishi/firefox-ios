// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import XCTest
@testable import Client

class GleanUsageReportingApiMock: GleanUsageReportingApi {
    var pingSubmitCount = 0
    var lastUsageReason: String?
    var lastDurationMillis: Int64?

    func setUsageReason(_ usageReason: UsageReason) {
        lastUsageReason = usageReason.rawValue
    }

    func submitPing() {
        pingSubmitCount += 1
    }

    func setDuration(_ durationMillis: Int64) {
        lastDurationMillis = durationMillis
    }
}

class GleanUsageReportingLifecycleObserverTest: XCTestCase {
    private var fakeGleanUsageReportingApi: GleanUsageReportingApiMock!

    override func setUp() {
        super.setUp()
        fakeGleanUsageReportingApi = GleanUsageReportingApiMock()
    }

    func testNoPingsSubmittedBeforeLifecycleChanges() {
        _ = createObserver()
        XCTAssertEqual(fakeGleanUsageReportingApi.pingSubmitCount, 0)
    }

    func testNoUsageReasonSetBeforeLifecycleChanges() {
        _ = createObserver()
        XCTAssertNil(fakeGleanUsageReportingApi.lastUsageReason)
    }

    func testSetUsageReasonToActiveOnStart() {
        let observer = createObserver()
        observer.handleForegroundEvent()
        XCTAssertEqual(fakeGleanUsageReportingApi.lastUsageReason, "active")
    }

    func testSubmitPingOnStart() {
        let observer = createObserver()
        observer.handleForegroundEvent()
        XCTAssertEqual(fakeGleanUsageReportingApi.pingSubmitCount, 1)
    }

    func testSetUsageReasonToInactiveOnStop() {
        let observer = createObserver()
        observer.handleBackgroundEvent()
        XCTAssertEqual(fakeGleanUsageReportingApi.lastUsageReason, "inactive")
    }

    func testSubmitPingOnStop() {
        let observer = createObserver()
        observer.handleForegroundEvent()
        observer.handleBackgroundEvent()
        XCTAssertEqual(fakeGleanUsageReportingApi.pingSubmitCount, 2)
    }

    func testDoNotSubmitDurationIfNotSet() {
        let observer = createObserver()
        observer.handleBackgroundEvent()
        XCTAssertNil(fakeGleanUsageReportingApi.lastDurationMillis)
    }

    private func createObserver() -> GleanLifecycleObserver {
        return GleanLifecycleObserver(
            gleanUsageReportingApi: fakeGleanUsageReportingApi
        )
    }
}
