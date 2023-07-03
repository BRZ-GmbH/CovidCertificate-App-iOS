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

import Foundation
import ValidationCore
import JSON
import jsonlogic
import CertLogic

/**
 Utility class for making JSONLogic rule evaluation easier
 */
class JsonLogicValidator {
    
    /**
     Returns a JSON object encoding the given EU Health certificate and external parameters
     */
    class func jsonObjectForValidation(forCertificate certificate: HealthCert, externalParameter: String) -> JSON? {
        let certificatePayload = try! JSONEncoder().encode(certificate)
        let payloadString = String(data: certificatePayload, encoding: .utf8)!
        
        let validationString = getJSONStringForValidation(externalJsonString: externalParameter, payload: payloadString)
        
        return JSON(string: validationString)
    }
    
    /**
     Evaluates the given JSONLogic rule on the passed validation object. If the rule does not evaluate to a boolean or throws an error, nil is returned
     */
    class func evaluateBooleanRule(_ rule: JsonLogic, forValidationObject validationObject: JSON?) -> Bool? {
        do {
            return try rule.applyRuleInternal(to: validationObject)
        } catch {
        }
        return nil
    }
    
    private class func getJSONStringForValidation(externalJsonString: String, payload: String) -> String {
        var result = ""
        result = "{" + "\"external\":" + "\(externalJsonString)" + "," + "\"payload\":" + "\(payload)"  + "}"
        return result
    }
    
    /**
     Encodes the given external parameters to the appropriate parameter string for JSONLogic rule validation
     */
    class func getExternalParameterStringForValidation(valueSets: [String:[String]], validationClock: Date, issuedAt: Date, expiresAt: Date) -> String {
        let externalParameter = ExternalParameter(validationClock: validationClock, valueSets: valueSets, exp: expiresAt, iat: issuedAt, issuerCountryCode: "AT")
        guard let jsonData = try? defaultEncoder.encode(externalParameter) else { return ""}
        return String(data: jsonData, encoding: .utf8)!
    }
    
    private class func evaluatePlaceholderSubstitution(withValue variablePath: String, data: JSON?) -> JSON {
        guard let data = data else {
            return JSON.Null
        }
        let variablePathParts = variablePath.split(separator: ".").map({String($0)})
        var partialResult: JSON? = data
        for key in variablePathParts {
            if partialResult?.type == .array {
              if let index = Int(key), let maxElement = partialResult?.array?.count,  index < maxElement, index >= 0  {
                partialResult = partialResult?[index]
              } else {
                partialResult = partialResult?[key]
              }
            } else {
              partialResult = partialResult?[key]
            }
        }
        return partialResult ?? JSON.Null
    }
    
    /**
     Searches for placeholders (contained between two hash symbols - e.g. #name#) in the given string and evaluates the referenced path in the given JSON object to replace them with actual values or an empty string if they are not successfully evaluated
     */
    class func evaluatePlaceholdersInString(_ string: String, data: JSON?) -> String {
        var evaluationString = string
        var placeHolderRange = evaluationString.range(of: #"#[^#]*#"#, options: .regularExpression)
        while placeHolderRange != nil {
            let placeholder = evaluationString[placeHolderRange!].replacingOccurrences(of: "#", with: "")
            let placeholderValue = JsonLogicValidator.evaluatePlaceholderSubstitution(withValue: placeholder, data: data)
            switch placeholderValue {
            case .Null, .Error(_), .Bool(_), .Array(_), .Dictionary(_):
                evaluationString.replaceSubrange(placeHolderRange!, with: "")
            case .Int(let int64):
                evaluationString.replaceSubrange(placeHolderRange!, with: "\(int64)")
            case .Double(let double):
                evaluationString.replaceSubrange(placeHolderRange!, with: "\(double)")
            case .String(let string):
                evaluationString.replaceSubrange(placeHolderRange!, with: "\(string)")
            case .Date(let date):
                evaluationString.replaceSubrange(placeHolderRange!, with: "\(DateFormatter.ub_dayString(from: date))")
            }
            placeHolderRange = evaluationString.range(of: #"#[^#]*#"#, options: .regularExpression)
        }
        
        return evaluationString
    }
}
