//
//  PlaylistLoader.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

protocol PlaylistLoadable {
    var nextStreamResource: (String, StreamResource)? { get }
    func load(identifier: String, at url: URL, header: [String: String]?,
              completion: @escaping Completion<Result<Void, Error>>)
    func cancel(identifier: String)
}

final class PlaylistLoader: PlaylistLoadable {
    private let requestsInProgress = Atomic<[String: URLSessionDataTask]>([:])
    private var streamsResources = Atomic<[(identifier: String, StreamResource)]>([])
    private let requestable: Requestable

    init(requestable: Requestable = URLSession.shared) {
        self.requestable = requestable
    }

    // MARK: - PlaylistLoadable

    var nextStreamResource: (String, StreamResource)? {
        guard !streamsResources.value.isEmpty else {
            return nil
        }
        return streamsResources.value.removeFirst()
    }

    func load(identifier: String, at url: URL, header: [String: String]? = nil, completion: @escaping Completion<Result<Void, Error>>) {
        let handle: (HTTPURLResponse, Data) -> Void = { [weak self] response, data in
            let streamResource = StreamResource(response: response, data: data)
            self?.addStreamResource(streamResource, identifier: identifier)
            completion(.success(()))
        }

        var urlRequest =  URLRequest(url: url)

        header?.forEach({ urlRequest.addValue($0, forHTTPHeaderField: $1)})
        
        let dataTask = requestable.dataTask(with: urlRequest) { [weak self] data, response, error in
            self?.removeFromRelay(identifier)
            guard let response = response as? HTTPURLResponse, let data = data else {
                return completion(.failure(error ?? DownloadError.unknown))
            }
            handle(response, data)
        }
        dataTask.resume()

        addToRelay(identifier: identifier, dataTask: dataTask)
    }
    
    private func setupCookies(url: URL, with json: [[String: String]]) -> [String: Any]? {
           
           var cookies = [HTTPCookie]()
           
           for cookie in json {
               
               for key in cookie.keys {
                   
                   let cookieField = ["Set-Cookie": "\(key)=\(cookie[key] ?? "")"]
                   let cookie = HTTPCookie.cookies(withResponseHeaderFields: cookieField, for: url)
                   cookies.append(contentsOf: cookie)
               }
           }
           
           let values = HTTPCookie.requestHeaderFields(with: cookies)
           
           return ["AVURLAssetHTTPHeaderFieldsKey": values]
       }
    

    func cancel(identifier: String) {
        requestsInProgress.value[identifier]?.cancel()
        removeStreamResource(identifier: identifier)
        removeFromRelay(identifier)
    }

    // MARK: - Private

    private func addToRelay(identifier: String, dataTask: URLSessionDataTask) {
        var requests = requestsInProgress.value
        requests.removeValue(forKey: identifier)?.cancel()
        requests[identifier] = dataTask
        requestsInProgress.value = requests
    }

    private func removeFromRelay(_ identifier: String) {
        requestsInProgress.value[identifier] = nil
    }

    private func addStreamResource(_ streamResource: StreamResource, identifier: String) {
        streamsResources.value = streamsResources.value + [(identifier, streamResource)]
    }

    private func removeStreamResource(identifier: String) {
        streamsResources.value = streamsResources.value.filter { $0.identifier != identifier }
    }
}
