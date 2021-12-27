//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import CovidCertificateSDK
import Foundation
import SnapKit

class CertificateStateView: UIView {
    // MARK: - Subviews

    private let backgroundView = UIView()
    private let imageView = UIImageView()
    private let roundImageBackgroundView = UIView()
    private let loadingView = UIActivityIndicatorView(style: .gray)
    private let textLabel = Label(.textLarge, textAlignment: .center)

    private let validityErrorStackView = UIStackView()
    private var validityErrorStackViewTopConstraint: Constraint? = nil
    private let validityHeadlineLabel = Label(.text, textAlignment: .center)
    private let entryValidityView = CertificateStateValidityView()
    private let nightClubValidityView = CertificateStateValidityView()
    private let errorLabel = Label(.smallErrorLight, textAlignment: .center)
    private let certificate: UserCertificate?

    private let validityHintView = Label(.smallErrorLight, textAlignment: .center)

    private let regionStateView = CertificateRegionStateView()

    private var hasValidityView: Bool = false

    var states: (state: VerificationResultStatus, temporaryVerifierState: TemporaryVerifierState) = (.loading, .idle) {
        didSet { update(animated: true) }
    }

    private let isHomescreen: Bool

    // MARK: - Init

    init(certificate: UserCertificate? = nil, isHomescreen: Bool = true) {
        self.isHomescreen = isHomescreen
        self.certificate = certificate
        self.hasValidityView = isHomescreen == false

        super.init(frame: .zero)

        setup()
        isAccessibilityElement = true

        update(animated: false)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        addSubview(validityHintView)

        addSubview(backgroundView)
        addSubview(roundImageBackgroundView)
        addSubview(imageView)
        addSubview(loadingView)
        addSubview(textLabel)
        addSubview(regionStateView)

        validityHintView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(Padding.medium)
            make.top.equalToSuperview()
        }

        backgroundView.layer.cornerRadius = 10
        backgroundView.backgroundColor = .cc_blueish
        backgroundView.snp.makeConstraints { make in
            make.top.equalTo(validityHintView.snp.bottom).offset(Padding.medium)
            make.leading.trailing.equalToSuperview()
            if !hasValidityView {
                make.bottom.equalToSuperview()
            }
            make.height.greaterThanOrEqualTo(76)
        }
        
        regionStateView.snp.makeConstraints { make in
            make.edges.equalTo(backgroundView)
        }

        imageView.snp.makeConstraints { make in
            make.centerY.equalTo(self.backgroundView.snp.top)
            make.centerX.equalToSuperview()
        }

        loadingView.snp.makeConstraints { make in
            make.center.equalTo(self.imageView)
        }

        roundImageBackgroundView.backgroundColor = .cc_white
        roundImageBackgroundView.snp.makeConstraints { make in
            make.center.equalTo(imageView)
            make.size.equalTo(32)
        }

        textLabel.snp.makeConstraints { make in
            make.top.equalTo(backgroundView).inset(Padding.medium + 2)
            make.leading.trailing.bottom.equalTo(backgroundView).inset(Padding.medium)
        }

        if hasValidityView {
            validityErrorStackView.axis = .vertical
            validityErrorStackView.spacing = 2.0 * Padding.small

            addSubview(validityErrorStackView)
            validityErrorStackView.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                validityErrorStackViewTopConstraint = make.top.equalTo(backgroundView.snp.bottom).offset(Padding.large).constraint
                make.bottom.equalToSuperview()
            }

            validityHeadlineLabel.text = UBLocalized.wallet_3g_status_validity_headline
            
            validityErrorStackView.addArrangedSubview(validityHeadlineLabel)
            validityErrorStackView.addArrangedSubview(entryValidityView)
            validityErrorStackView.addArrangedSubview(nightClubValidityView)
            validityErrorStackView.addArrangedSubview(errorLabel)

            entryValidityView.backgroundColor = .cc_greenish
            nightClubValidityView.backgroundColor = .cc_greenish
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        roundImageBackgroundView.layer.cornerRadius = roundImageBackgroundView.frame.size.height * 0.5
    }

    private func update(animated: Bool) {
        // switch non-animatable states
        switch states.state {
        case .loading:
            loadingView.startAnimating()
        default:
            loadingView.stopAnimating()
        }

        // switch animatable states
        let actions = {
            self.validityHintView.text = UBLocalized.wallet_3g_status_disclaimer
            //self.validityView.isOfflineMode = false
            self.errorLabel.ub_setHidden(true)
            self.validityErrorStackView.ub_setHidden(false)

            self.textLabel.textColor = .cc_text

            switch self.states.temporaryVerifierState {
            case let .success(results):
                self.imageView.image = UIImage(named: "ic-check-filled")?.ub_image(with: .cc_green)
                self.textLabel.attributedText = UBLocalized.wallet_certificate_verify_success.bold()
                self.backgroundView.backgroundColor = .cc_greenish
                //self.validityView.backgroundColor = .cc_greenish
                //self.validityView.textColor = .cc_black
                self.regionStateView.results = results
                self.regionStateView.ub_setHidden(false)
                self.imageView.ub_setHidden(true)
                self.validityHintView.ub_setHidden(false)
                self.backgroundView.ub_setHidden(true)
                self.textLabel.ub_setHidden(true)
            case .failure:
                if case .error = self.states.state {
                    self.imageView.image = VerificationError.signature.icon(with: .cc_red)
                    self.textLabel.attributedText = VerificationError.signature.displayName()
                    self.backgroundView.backgroundColor = .cc_red_invalid
                    //self.validityView.backgroundColor = .cc_red_invalid
                    self.textLabel.textColor = .cc_white
                    //self.validityView.textColor = .cc_white
                }
                self.regionStateView.ub_setHidden(true)
                self.imageView.ub_setHidden(false)
                self.validityHintView.ub_setHidden(true)
                self.backgroundView.ub_setHidden(false)
                self.textLabel.ub_setHidden(false)
            case .verifying:
                self.imageView.image = nil
                self.textLabel.attributedText = NSAttributedString(string: UBLocalized.wallet_certificate_verifying)
                self.backgroundView.backgroundColor = .cc_greyish
                //self.validityView.backgroundColor = .cc_greyish
                //self.validityView.textColor = .cc_grey
                self.validityErrorStackView.ub_setHidden(true)
                self.regionStateView.ub_setHidden(true)
                self.imageView.ub_setHidden(false)
                self.validityHintView.ub_setHidden(true)
                self.backgroundView.ub_setHidden(false)
                self.textLabel.ub_setHidden(false)
            case .idle:
                switch self.states.state {
                case .loading:
                    self.imageView.image = nil
                    self.textLabel.textColor = .cc_white
                    self.textLabel.text = UBLocalized.wallet_certificate_verifying
                    self.backgroundView.backgroundColor = .cc_greyish
                    self.entryValidityView.ub_setHidden(true)
                    self.nightClubValidityView.ub_setHidden(true)
                    self.validityHeadlineLabel.ub_setHidden(true)
                    self.validityErrorStackView.ub_setHidden(true)
                    self.regionStateView.ub_setHidden(true)
                    self.imageView.ub_setHidden(false)
                    self.validityHintView.ub_setHidden(true)
                    self.backgroundView.ub_setHidden(false)
                    self.textLabel.ub_setHidden(false)
                case let .success(results):
                    self.imageView.image = UIImage(named: "ic-info-filled")?.ub_image(with: .cc_green_valid)
                    self.textLabel.attributedText = nil
                    self.backgroundView.backgroundColor = .cc_green_valid
                    self.textLabel.textColor = .cc_white
                    self.entryValidityView.ub_setHidden(false)
                    self.nightClubValidityView.ub_setHidden(false)
                    self.regionStateView.results = results
                    self.regionStateView.ub_setHidden(false)
                    self.imageView.ub_setHidden(true)
                    self.validityHintView.ub_setHidden(false)
                    self.backgroundView.ub_setHidden(true)
                    self.textLabel.ub_setHidden(true)
                    
                    let entryResult = results.first(where: { $0.region?.hasPrefix("ET") == true })
                    let nightClubResult = results.first(where: { $0.region?.hasPrefix("NG") == true })
                    
                    self.entryValidityView.textColor = .cc_black
                    self.nightClubValidityView.textColor = .cc_black
                    
                    if entryResult?.valid == true {
                        self.entryValidityView.untilText = entryResult?.validUntil
                        self.entryValidityView.validityTitleLabel.text = String(format: NSLocalizedString("wallet_certificate_validity", comment: ""), UBLocalized.region_type_ET_validity, Region.regionFromString(WalletUserStorage.shared.selectedValidationRegion)?.validityName ?? "")
                    } else {
                        self.entryValidityView.ub_setHidden(true)
                    }
                    
                    if nightClubResult?.valid == true {
                        self.nightClubValidityView.untilText = nightClubResult?.validUntil
                        self.nightClubValidityView.validityTitleLabel.text = String(format: NSLocalizedString("wallet_certificate_validity", comment: ""), UBLocalized.region_type_NG_validity, Region.regionFromString(WalletUserStorage.shared.selectedValidationRegion)?.validityName ?? "")
                    } else {
                        self.nightClubValidityView.ub_setHidden(true)
                    }
                    self.validityHeadlineLabel.ub_setHidden(entryResult?.valid == false && nightClubResult?.valid == false)
                    self.validityErrorStackViewTopConstraint?.update(offset: (entryResult?.valid == false && nightClubResult?.valid == false) ? 0 : Padding.large)
                case .error:
                    self.imageView.image = VerificationError.typeInvalid.icon()?.ub_image(with: .cc_red)
                    self.textLabel.attributedText = VerificationError.typeInvalid.displayName()
                    self.backgroundView.backgroundColor = .cc_red_invalid
                    self.textLabel.textColor = .cc_white
                    self.regionStateView.ub_setHidden(true)
                    self.imageView.ub_setHidden(false)
                    self.validityHintView.ub_setHidden(true)
                    self.backgroundView.ub_setHidden(false)
                    self.textLabel.ub_setHidden(false)
                    self.entryValidityView.ub_setHidden(true)
                    self.nightClubValidityView.ub_setHidden(true)
                    self.validityHeadlineLabel.ub_setHidden(true)
                    self.validityErrorStackViewTopConstraint?.update(offset: 0)
                case .signatureInvalid:
                    self.imageView.image = VerificationError.signature.icon()?.ub_image(with: .cc_red)
                    self.textLabel.attributedText = VerificationError.signature.displayName()
                    self.backgroundView.backgroundColor = .cc_red_invalid
                    self.textLabel.textColor = .cc_white
                    self.entryValidityView.ub_setHidden(true)
                    self.nightClubValidityView.ub_setHidden(true)
                    self.validityHeadlineLabel.ub_setHidden(true)
                    self.regionStateView.ub_setHidden(true)
                    self.imageView.ub_setHidden(false)
                    self.validityHintView.ub_setHidden(true)
                    self.backgroundView.ub_setHidden(false)
                    self.textLabel.ub_setHidden(false)
                    self.validityErrorStackViewTopConstraint?.update(offset: 0)
                case .timeMissing:
                    self.imageView.image = UIImage(named: "ic-info-filled")?.ub_image(with: .cc_orange)
                    self.textLabel.attributedText = NSAttributedString(string: UBLocalized.wallet_time_missing)
                    self.backgroundView.backgroundColor = .cc_orange
                    self.textLabel.textColor = .cc_white
                    self.entryValidityView.ub_setHidden(true)
                    self.nightClubValidityView.ub_setHidden(true)
                    self.validityHeadlineLabel.ub_setHidden(true)
                    self.regionStateView.ub_setHidden(true)
                    self.imageView.ub_setHidden(false)
                    self.validityHintView.ub_setHidden(true)
                    self.backgroundView.ub_setHidden(false)
                    self.textLabel.ub_setHidden(false)
                    self.validityErrorStackViewTopConstraint?.update(offset: 0)
                case .dataExpired:
                    self.imageView.image = UIImage(named: "ic-offline")?.ub_image(with: .cc_orange)
                    self.textLabel.attributedText = NSAttributedString(string: UBLocalized.wallet_validation_data_expired)
                    self.backgroundView.backgroundColor = .cc_orange
                    self.textLabel.textColor = .cc_white
                    self.entryValidityView.ub_setHidden(true)
                    self.nightClubValidityView.ub_setHidden(true)
                    self.validityHeadlineLabel.ub_setHidden(true)
                    self.regionStateView.ub_setHidden(true)
                    self.imageView.ub_setHidden(false)
                    self.validityHintView.ub_setHidden(true)
                    self.backgroundView.ub_setHidden(false)
                    self.textLabel.ub_setHidden(false)
                    self.validityErrorStackViewTopConstraint?.update(offset: 0)
                    
                }
            }

            if let text = self.textLabel.attributedText?.string {
                self.accessibilityLabel = text
            } else {
                self.accessibilityLabel = [self.validityHintView.text, self.regionStateView.accessibilityLabel].compactMap({$0}).joined(separator: ",")
            }
        }

        if animated {
            UIView.animate(withDuration: 0.2) {
                actions()
            }
        } else {
            actions()
        }
    }
}
