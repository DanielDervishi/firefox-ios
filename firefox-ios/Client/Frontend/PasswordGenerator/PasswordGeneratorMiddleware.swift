// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Foundation
import Redux
import Shared
import Common

final class PasswordGeneratorMiddleware {
    private let logger: Logger
    private let generatedPasswordStorage: GeneratedPasswordStorageProtocol = GeneratedPasswordStorage()

    init(logger: Logger = DefaultLogger.shared) {
        self.logger = logger
    }

    lazy var passwordGeneratorProvider: Middleware<AppState> = { state, action in
        let windowUUID = action.windowUUID
        guard let currentTab = (action as? PasswordGeneratorAction)?.currentTab else { return }
        switch action.actionType {
        case PasswordGeneratorActionType.showPasswordGenerator:
            self.showPasswordGenerator(with: currentTab, windowUUID: windowUUID)
        case PasswordGeneratorActionType.userTappedRefreshPassword:
            self.userTappedRefreshPassword(with: currentTab, windowUUID: windowUUID)
        case PasswordGeneratorActionType.clearGeneratedPasswordForSite:
            self.clearGeneratedPasswordForSite(with: currentTab, windowUUID: windowUUID)
        case PasswordGeneratorActionType.userTappedUsePassword:
            guard let password = state.screenState(PasswordGeneratorState.self,
                                             for: .passwordGenerator,
                                                   window: action.windowUUID)?.password else {return}
            self.userTappedUsePassword(with: currentTab, password: password)
        default:
            break
        }
    }
    
    private func userTappedUsePassword(with tab: Tab, password: String) {
        let jsFunctionCall = "window.__firefox__.logins.fillGeneratedPassword(\"\(password)\")"

        tab.webView?.evaluateJavascriptInDefaultContentWorld(jsFunctionCall) { (result, error) in
            if let error = error {
                print("Error filling in password info")
            }
        }
    }
    
    private func clearGeneratedPasswordForSite(with tab: Tab, windowUUID: WindowUUID) {
        guard let origin = tab.url?.origin else {return}
        generatedPasswordStorage.deletePasswordForOrigin(origin: origin)
    }

    private func showPasswordGenerator(with tab: Tab, windowUUID: WindowUUID) {
        guard let origin = tab.url?.origin else {return}
        if let password = generatedPasswordStorage.getPasswordForOrigin(origin: origin) {
            let newAction = PasswordGeneratorAction(
                windowUUID: windowUUID,
                actionType: PasswordGeneratorActionType.updateGeneratedPassword,
                password: password
            )
            store.dispatch(newAction)
        } else {
            generateNewPassword(with: tab, completion: { generatedPassword in
                self.generatedPasswordStorage.setPasswordForOrigin(origin: origin, password: generatedPassword)
                let newAction = PasswordGeneratorAction(
                    windowUUID: windowUUID,
                    actionType: PasswordGeneratorActionType.updateGeneratedPassword,
                    password: generatedPassword
                )
                store.dispatch(newAction)
            })
        }
    }

    private func userTappedRefreshPassword(with tab: Tab, windowUUID: WindowUUID) {
        guard let origin = tab.url?.origin else {return}
        generateNewPassword(with: tab, completion: { generatedPassword in
            self.generatedPasswordStorage.setPasswordForOrigin(origin: origin, password: generatedPassword)
            let newAction = PasswordGeneratorAction(
                windowUUID: windowUUID,
                actionType: PasswordGeneratorActionType.updateGeneratedPassword,
                password: generatedPassword
            )
            store.dispatch(newAction)
        })
    }

    private func generateNewPassword(with tab: Tab, completion: @escaping (String) -> Void) {
        let jsFunctionCall = "window.__firefox__.logins.generatePassword()"
        tab.webView?.evaluateJavascriptInDefaultContentWorld(jsFunctionCall) { (result, error) in
            if let error = error {
                print("JavaScript evaluation error: \(error.localizedDescription)")
            } else if let result = result as? String {
                print("JavaScript object: \(result)")
                completion(result)
            }
        }
    }
}
