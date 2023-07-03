//
/*
 * Copyright (c) 2021 Ubique Innovation AG <https://www.ubique.ch>
 * Copyright (c) 2021 BRZ GmbH <https://www.brz.gv.at>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import UIKit

struct Intro: Codable {
    let intros: LocalizedValue<[String: [StaticContentViewModel]]>

    public static var introModelForCurrentVersion: [StaticContentViewModel] {
        guard let url = Bundle.main.url(forResource: "intros", withExtension: "json"),
              let json = try? String(contentsOf: url),
              let data = json.data(using: .utf8),
              let decodedIntro = try? JSONDecoder().decode(Intro.self, from: data),
              let allIntrosForCurrentLanguage = decodedIntro.intros.dic[UBLocalized.language_key],
              let firstIntroForCurrentVersion = allIntrosForCurrentLanguage[ConfigManager.shortAppVersion] else {
            return []
        }
        return firstIntroForCurrentVersion
    }

    static var hasAvailableIntro: Bool {
        return !introModelForCurrentVersion.isEmpty
    }
}

// MARK: - ExpandableTextGroup

struct ExpandableTextGroup: Codable, Equatable {
    var link: URL? {
        guard let string = linkUrl else { return nil }
        return URL(string: string)
    }

    let title: String
    let text: String
    let linkTitle: String?
    let linkUrl: String?

    static func == (lhs: ExpandableTextGroup, rhs: ExpandableTextGroup) -> Bool {
        return lhs.title == rhs.title &&
            lhs.text == rhs.text &&
            lhs.linkTitle == rhs.linkTitle &&
            lhs.linkUrl == rhs.linkUrl
    }
}

// MARK: - TextGroup

struct TextGroup: Codable, Equatable {
    var loadAccessibilityImage: AccessibilityImage? {
        guard let image = loadImageWithColor else { return nil }
        return AccessibilityImage(image: image, altText: imageAltText)
    }

    var loadImageWithColor: UIImage? {
        guard let imageName = image, !imageName.isEmpty else { return nil }

        if let imgColor = imageColor, let color = UIColor(ub_hexString: imgColor) {
            return UIImage(named: imageName)?.ub_image(with: color)
        }
        return UIImage(named: imageName)
    }

    let image: String?
    let imageColor: String?
    let imageAltText: String?
    let text: String
    let accessibilityIdentifier: String?

    static func == (lhs: TextGroup, rhs: TextGroup) -> Bool {
        return lhs.image == rhs.image &&
            lhs.imageColor == rhs.imageColor &&
            lhs.imageAltText == rhs.imageAltText &&
            lhs.text == rhs.text
    }
}

// MARK: - ExternalLink

struct ExternalLink: Codable, Equatable {
    let label: String
    let linkUrl: String
    let accessibilityIdentifier: String?

    var url: URL? {
        return URL(string: linkUrl)
    }
}
