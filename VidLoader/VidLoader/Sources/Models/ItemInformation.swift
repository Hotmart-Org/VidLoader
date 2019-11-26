//
//  ItemInformation.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

/// ItemInformation is a stream description that is used and saved in the download task
public struct ItemInformation: Codable {
    /// Item unique identifier
    public let identifier: String
    /// The path where the stream was downloaded
    public let path: String?
    /// String url of the stream
    public let mediaLink: String
    /// Current item state
    public let state: DownloadState
    /// Item title that will be presented in the phone settings
    public let title: String?
    /// Current downloaded bytes
    public let downloadedBytes: Double
    /// Item thumbnail that will be presented in the phone settings
    let artworkData: Data?
    /// Current item download progress
    let progress: Double

    init(identifier: String, title: String?, path: String? = nil,
         mediaLink: String = "", progress: Double = 0,
         state: DownloadState, downloadedBytes: Double = 0,
         artworkData: Data?) {
        self.identifier = identifier
        self.title = title
        self.path = path
        self.mediaLink = mediaLink
        self.progress = progress
        self.state = state
        self.downloadedBytes = downloadedBytes
        self.artworkData = artworkData
    }

    public var location: URL? {
        guard let path = path else { return nil }

        return URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(path)
    }

    var isReachable: Bool {
        guard let location = location else { return false }

        return (try? location.checkResourceIsReachable()) ?? false
    }

    var isFailed: Bool {
        switch state {
        case .failed: return true
        case .assetInfoLoaded, .canceled, .completed, .running,
             .unknown, .waiting, .suspended, .prefetching: return false
        }
    }
    
    var inProgress: Bool {
        switch state {
        case .failed, .canceled, .completed, .unknown, .prefetching, .waiting: return false
        case .running, .suspended, .assetInfoLoaded: return true
        }
    }

    var isCancelled: Bool {
        switch state {
        case .canceled: return true
        case .assetInfoLoaded, .failed,
             .completed,
             .running, .unknown, .waiting,
             .suspended, .prefetching: return false
        }
    }
}

extension ItemInformation {
    static let _state = Lens<ItemInformation, DownloadState>(
        get: { $0.state },
        set: { ItemInformation(identifier: $1.identifier, title: $1.title, path: $1.path,
                                mediaLink: $1.mediaLink, progress: $1.progress,
                                state: $0, downloadedBytes: $1.downloadedBytes,
                                artworkData: $1.artworkData) }
    )

    static let _path = Lens<ItemInformation, String?>(
        get: { $0.path },
        set: { ItemInformation(identifier: $1.identifier, title: $1.title, path: $0,
                                mediaLink: $1.mediaLink, progress: $1.progress,
                                state: $1.state, downloadedBytes: $1.downloadedBytes,
                                artworkData: $1.artworkData) }
    )

    static let _progress = Lens<ItemInformation, Double>(
        get: { $0.progress },
        set: { ItemInformation(identifier: $1.identifier, title: $1.title, path: $1.path,
                                mediaLink: $1.mediaLink, progress: $0,
                                state: $1.state, downloadedBytes: $1.downloadedBytes,
                                artworkData: $1.artworkData) }
    )

    static let _downloadedBytes = Lens<ItemInformation, Double>(
        get: { $0.downloadedBytes },
        set: { ItemInformation(identifier: $1.identifier, title: $1.title, path: $1.path,
                                mediaLink: $1.mediaLink, progress: $1.progress,
                                state: $1.state, downloadedBytes: $0,
                                artworkData: $1.artworkData) }
    )
}