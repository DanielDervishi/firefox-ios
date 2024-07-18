// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/

import Common
import UIKit
import Shared
import ComponentLibrary

class PasswordManagerOnboardingViewController: SettingsViewController {
    private struct UX {
        static let maxLabelLines: Int = 0
        static let buttonCornerRadius: CGFloat = 8
        static let standardSpacing: CGFloat = 20
        static let continueButtonHeight: CGFloat = 44
        static let buttonHorizontalPadding: CGFloat = 35
        static let continueButtonMaxWidth: CGFloat = 360
    }

    private var onboardingMessageLabel: UILabel = . build { label in
        label.text = ".Settings.Passwords.OnboardingMessage gia fdjsafkdsalj fdsk;fj dsaklf jdsaf; dsjfkldsa jfkld;sjfdslkj fdslak;fjdsaklf jdsl;f dsjafk dsjafl;kds fhgfghfhgf gjfhgf "
        label.font = FXFontStyles.Regular.callout.scaledFont()
        label.textAlignment = .center
        label.numberOfLines = UX.maxLabelLines
    }

    private lazy var learnMoreButton: LinkButton = .build { button in
        let buttonViewModel = LinkButtonViewModel(
            title: .LoginsOnboardingLearnMoreButtonTitle,
            a11yIdentifier: AccessibilityIdentifiers.Settings.Passwords.onboardingLearnMore)
        button.configure(viewModel: buttonViewModel)
        button.addTarget(self, action: #selector(self.learnMoreButtonTapped), for: .touchUpInside)
    }

    private lazy var continueButton: PrimaryRoundedButton = .build { button in
        let buttonViewModel = PrimaryRoundedButtonViewModel(title: .LoginsOnboardingContinueButtonTitle, a11yIdentifier: AccessibilityIdentifiers.Settings.Passwords.onboardingContinue)
        button.configure(viewModel: buttonViewModel)
        button.addTarget(self, action: #selector(self.proceedButtonTapped), for: .touchUpInside)
    }
    
    private lazy var scrollView: UIScrollView = .build { scrollView in
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        contentView.addSubviews(self.onboardingMessageLabel, self.learnMoreButton)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),

            contentView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor),
        ])
        NSLayoutConstraint.activate(
            [
                self.onboardingMessageLabel.leadingAnchor.constraint(
                    equalTo: contentView.safeAreaLayoutGuide.leadingAnchor,
                    constant: UX.standardSpacing
                ),
                self.onboardingMessageLabel.trailingAnchor.constraint(
                    equalTo: contentView.safeAreaLayoutGuide.trailingAnchor,
                    constant: -UX.standardSpacing
                ),
                self.onboardingMessageLabel.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
                self.onboardingMessageLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: UX.standardSpacing),
                self.learnMoreButton.topAnchor.constraint(
                    equalTo: self.onboardingMessageLabel.bottomAnchor,
                    constant: UX.standardSpacing
                ),
                self.learnMoreButton.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            ])
        
        
        
        
    }

    weak var coordinator: PasswordManagerFlowDelegate?
    private var appAuthenticator: AppAuthenticationProtocol

    init(profile: Profile? = nil,
         tabManager: TabManager? = nil,
         windowUUID: WindowUUID,
         appAuthenticator: AppAuthenticationProtocol = AppAuthenticator()) {
        self.appAuthenticator = appAuthenticator
        super.init(windowUUID: windowUUID, profile: profile, tabManager: tabManager)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = .Settings.Passwords.Title

        self.view.addSubviews(scrollView, continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.bottomAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                constant: -UX.standardSpacing
            ),
            continueButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            continueButton.leadingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,
                constant: UX.buttonHorizontalPadding,
                priority: .defaultHigh
            ),
            continueButton.trailingAnchor.constraint(
                equalTo: self.view.safeAreaLayoutGuide.trailingAnchor,
                constant: -UX.buttonHorizontalPadding,
                priority: .defaultHigh
            ),
            continueButton.widthAnchor.constraint(lessThanOrEqualToConstant: UX.continueButtonMaxWidth),
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        scrollView.bottomAnchor.constraint(equalTo: continueButton.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
        ])

    }

    @objc
    func learnMoreButtonTapped(_ sender: UIButton) {
        let viewController = SettingsContentViewController(windowUUID: windowUUID)
        viewController.url = SupportUtils.URLForTopic("set-passcode-and-touch-id-firefox")
        navigationController?.pushViewController(viewController, animated: true)
    }

    @objc
    func proceedButtonTapped(_ sender: UIButton) {
        continueFromOnboarding()
    }


    private func continueFromOnboarding() {
        appAuthenticator.getAuthenticationState { state in
            switch state {
            case .deviceOwnerAuthenticated:
                self.coordinator?.continueFromOnboarding()
            case .deviceOwnerFailed:
                break // Keep showing the main settings page
            case .passCodeRequired:
                self.coordinator?.showDevicePassCode()
            }
        }
    }

    override func applyTheme() {
        super.applyTheme()

        let currentTheme = themeManager.getCurrentTheme(for: windowUUID)
        learnMoreButton.applyTheme(theme: currentTheme)
        continueButton.applyTheme(theme: currentTheme)
    }
}
