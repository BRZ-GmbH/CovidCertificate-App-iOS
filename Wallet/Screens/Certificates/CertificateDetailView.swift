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
import UIKit

class CertificateDetailView: UIView {
    private let certificate: UserCertificate
    private var holder: DGCHolder?

    private let stackView = UIStackView()

    var state: VerificationResultStatus = .loading {
        didSet { update(animated: true) }
    }

    private let showEnglishLabels: Bool

    private var labels: [UILabel] = []
    private var englishLabels: [UILabel] = []

    // MARK: - Init

    init(certificate: UserCertificate, showEnglishLabelsIfNeeded: Bool) {
        showEnglishLabels = showEnglishLabelsIfNeeded && !UBLocalized.languageIsEnglish()
        self.certificate = certificate
        super.init(frame: .zero)

        switch self.certificate.decodedCertificate {
        case let .success(holder):
            self.holder = holder
        case .failure:
            break
        }

        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        addSubview(stackView)

        stackView.axis = .vertical

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addVaccinationEntries()
        addRecoveryEntries()
        addTestEntries()

        updateEnglishLabelVisibility()
        applySuccessState()
    }

    private func addVaccinationEntries() {
        guard let vaccinations = holder?.healthCert.vaccinations,
              vaccinations.count > 0 else { return }

        addDividerLine()
        addTitle(title: UBLocalized.translationWithEnglish(key: .covid_certificate_vaccination_title_key))

        for vaccination in vaccinations {
            addDividerLine()

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_impfdosis_title_key), value: vaccination.getNumberOverTotalDose)

            // Vaccine data
            if vaccination.isTargetDiseaseCorrect {
                addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_target_disease_title_key), value: UBLocalized.target_disease_name)
            }

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_vaccine_prophylaxis_key), value: vaccination.prophylaxis)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_impfstoff_product_name_title_key), value: vaccination.name)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_impfstoff_holder_key), value: vaccination.authHolder)

            addDividerLine()

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_vaccination_date_title_key), value: vaccination.displayDateOfVaccination)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_vaccination_country_title_key), value: vaccination.displayCountry)

            addDividerLine()

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_vaccination_issuer_title_key), value: vaccination.certificateIssuer)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_identifier_key), value: vaccination.certificateIdentifier, addEnglishLabels: false)

            addIssuedDate(dateString: holder?.displayIssuedAt)
        }
    }

    private func addRecoveryEntries() {
        guard let pastInfections = holder?.healthCert.recovery,
              pastInfections.count > 0
        else { return }

        addDividerLine()
        addTitle(title: UBLocalized.translationWithEnglish(key: .covid_certificate_recovery_title_key))

        for pastInfection in pastInfections {
            addDividerLine()

            if pastInfection.isTargetDiseaseCorrect {
                addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_target_disease_title_key), value: UBLocalized.target_disease_name)
            }

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_recovery_first_positiv_result_key), value: pastInfection.displayFirstPositiveTest)

            addDividerLine()

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_test_land_key), value: pastInfection.displayCountry)

            addDividerLine()

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_vaccination_issuer_title_key), value: pastInfection.certificateIssuer)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_identifier_key), value: pastInfection.certificateIdentifier, addEnglishLabels: false)

            addIssuedDate(dateString: holder?.displayIssuedAt)
        }
    }

    private func addTestEntries() {
        guard let tests = holder?.healthCert.tests,
              tests.count > 0
        else { return }

        addDividerLine()
        addTitle(title: UBLocalized.translationWithEnglish(key: .covid_certificate_test_title_key))

        for test in tests {
            addDividerLine()

            if test.isTargetDiseaseCorrect {
                addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_target_disease_title_key), value: UBLocalized.target_disease_name)
            }

            let texts = test.isNegative ? UBLocalized.translationWithEnglish(key: .wallet_certificate_test_result_negativ_key) : UBLocalized.translationWithEnglish(key: .wallet_certificate_test_result_positiv_key)

            var text = [texts.0, texts.1].joined(separator: "\n")
            if !showEnglishLabels {
                text = texts.0
            }

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_test_result_title_key), value: text)

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_test_type_key), value: test.testType)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_test_name_key), value: test.readableTestName)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_test_holder_key), value: test.readableManufacturer)

            addDividerLine()

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_test_sample_date_title_key), value: test.displaySampleDateTime)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_test_result_date_title_key), value: test.displayResultDateTime)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_test_done_by_key), value: test.testCenter)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_test_land_key), value: test.displayCountry)

            addDividerLine()

            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_vaccination_issuer_title_key), value: test.certificateIssuer)
            addValueItem(title: UBLocalized.translationWithEnglish(key: .wallet_certificate_identifier_key), value: test.certificateIdentifier, addEnglishLabels: false)

            addIssuedDate(dateString: holder?.displayIssuedAt)
        }
    }

    // MARK: - Content

    private func addTitle(title: (String, String)) {
        let label = Label(.uppercaseBold, textColor: .cc_black)
        label.text = title.0
        label.accessibilityIdentifier = "item_title"
        stackView.addArrangedView(label)

        let englishLabel = Label(.text, textColor: .cc_greyText)
        englishLabel.accessibilityIdentifier = "item_title_english"
        englishLabel.text = title.1
        stackView.addArrangedView(englishLabel)

        stackView.addSpacerView(Padding.large)

        labels.append(label)
        englishLabels.append(englishLabel)
    }

    private func addValueItem(title: (String, String), value: String?, addEnglishLabels: Bool = true) {
        guard let v = value else { return }

        let sv = UIStackView()
        sv.axis = .vertical
        sv.isAccessibilityElement = true

        var accessibilityLabels = [title.0, v]
        // we add what the screen shows to accessibility

        if !UBLocalized.languageIsEnglish() && addEnglishLabels && showEnglishLabels  {
            accessibilityLabels.insert(title.1, at: accessibilityLabels.startIndex + 1)
        }
        
        sv.accessibilityLabel = accessibilityLabels.joined(separator: ", ")
        
        // This is only for the "Vaccine Dose", where "/" gets replaced with "of".
        if title == UBLocalized.translationWithEnglish(key: .wallet_certificate_impfdosis_title_key) {
            sv.accessibilityLabel = sv.accessibilityLabel?.replacingOccurrences(of: "/", with: " \(UBLocalized.accessibility_of_text) ")
        }

        let titleLabel = Label(.textBold)
        titleLabel.text = v
        titleLabel.accessibilityIdentifier = "item_value_value"
        sv.addArrangedView(titleLabel)

        let textLabel = Label(.text)
        textLabel.text = title.0
        textLabel.accessibilityIdentifier = "item_value_label"
        sv.addArrangedView(textLabel)

        if addEnglishLabels {
            let textLabelEnglish = Label(.text, textColor: .cc_greyText)
            textLabelEnglish.accessibilityIdentifier = "item_value_label_english"
            textLabelEnglish.text = title.1
            sv.addArrangedView(textLabelEnglish)
            englishLabels.append(textLabelEnglish)
        }

        stackView.addArrangedView(sv)

        stackView.addSpacerView(Padding.large)

        labels.append(titleLabel)
        labels.append(textLabel)
    }

    private func addValueItem(value: (String?, String?), spacing: CGFloat = 0.0) {
        guard let v = value.0, let vEnglish = value.1
        else { return }

        let textLabel = Label(.text)
        textLabel.text = v
        textLabel.accessibilityIdentifier = "item_value_label"
        stackView.addArrangedView(textLabel)

        if spacing > 0.0 {
            stackView.addSpacerView(spacing)
        }

        let englishLabel = Label(.text, textColor: .cc_grey)
        englishLabel.text = vEnglish
        englishLabel.accessibilityIdentifier = "item_value_label_english"
        stackView.addArrangedView(englishLabel)

        stackView.addSpacerView(Padding.large)

        labels.append(textLabel)
        englishLabels.append(englishLabel)
    }

    private func addDividerLine(hasTopPadding _: Bool = true) {
        stackView.addArrangedView(DashedLineView())
        stackView.addSpacerView(Padding.large)
    }

    private func addIssuedDate(dateString: String?) {
        guard let d = dateString else { return }

        let values = UBLocalized.translationWithEnglish(key: .wallet_certificate_date_key)
        addValueItem(value: (values.0.replacingOccurrences(of: "{DATE}", with: d), values.1.replacingOccurrences(of: "{DATE}", with: d)), spacing: Padding.large)
    }

    // MARK: - Update

    private func applyLoadingState() {
        for l in labels {
            l.textColor = .cc_grey
        }
    }

    private func applySuccessState() {
        for l in labels {
            l.textColor = .cc_text
        }
    }

    private func applyErrorState() {
        for l in labels {
            l.textColor = .cc_grey
        }
    }

    private func update(animated: Bool) {
        // switch animatable states
        let actions = {            
            switch self.state {
            case .loading:
                self.applyLoadingState()
            case .success, .timeMissing:
                self.applySuccessState()
            case .error, .signatureInvalid:
                self.applyErrorState()
            case .dataExpired:
                self.applySuccessState()
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

    private func updateEnglishLabelVisibility() {
        for l in englishLabels {
            l.ub_setHidden(!showEnglishLabels)
            l.alpha = showEnglishLabels ? 1.0 : 0.0
        }
    }
}

class DashedLineView: UIView {
    
    enum Style {
        case thick
        case thin
    }
    
    private var shapeLayer = CAShapeLayer()
    private let style: Style

    // MARK: - Init

    init(style: Style = .thick) {
        self.style = style
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setup() {
        layer.addSublayer(shapeLayer)

        switch style {
        case .thick:
            shapeLayer.strokeColor = UIColor.cc_line.cgColor
            shapeLayer.lineWidth = 2.0
            shapeLayer.lineDashPattern = [NSNumber(value: Float(Padding.small)), NSNumber(value: Float(2.0 * Padding.small))]
            shapeLayer.lineCap = .round
        case .thin:
            shapeLayer.strokeColor = UIColor.cc_dashedLine.cgColor
            shapeLayer.lineWidth = 1.0
            shapeLayer.lineDashPattern = [NSNumber(value: Float(6)), NSNumber(value: Float(2.0))]
            shapeLayer.lineCap = .square
        }
        
    }

    // MARK: - Layout

    override func layoutSubviews() {
        super.layoutSubviews()

        let cgPath = CGMutablePath()
        let cgPoint = [CGPoint(x: 0, y: 0), CGPoint(x: frame.width, y: 0)]
        cgPath.addLines(between: cgPoint)
        shapeLayer.path = cgPath
    }
}
