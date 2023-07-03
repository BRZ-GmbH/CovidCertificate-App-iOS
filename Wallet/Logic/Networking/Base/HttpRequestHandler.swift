//
/*
 * Copyright (c) 2022 BRZ GmbH
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

class HttpRequestHandler {
    class func makeGetRequest(url: URL) -> URLRequest {
        var request = URLRequest(url: url, timeoutInterval: 30.0)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    class func makePostRequest(url: URL, json: [String: Any]) -> URLRequest {
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        var request = URLRequest(url: url, timeoutInterval: 30.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        return request
    }

    class func sendRequest(_ request: URLRequest, delegate: URLSessionDelegate? = nil, handleResponse: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
        let dataTask: URLSessionDataTask? = session.dataTask(with: request, completionHandler: handleResponse)
        dataTask?.resume()
    }
}
