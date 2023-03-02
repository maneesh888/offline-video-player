//
//  VODDownloadService.swift
//  Offline Video Player
//
//  Created by Maneesh M on 01/03/23.
//

import Foundation
import AVFoundation
import Combine

protocol Downloadable {
    var assetId: String {get}
    var assetURL: String? {get}
}

enum AssetDownloadState {
    case notDownloaded, waiting, downloading, downloaded
}

final class DownloadService {
    
    private let progressSubject = PassthroughSubject<(String, Double, AssetDownloadState, Error?), Never>()
    var progressPublisher: AnyPublisher<(String, Double, AssetDownloadState, Error?), Never> {
            return progressSubject.eraseToAnyPublisher()
        }
    var activeDownloadMap:[ String:(URLSessionDownloadTask,NSKeyValueObservation)] = [:]
//    /// The AVAssetDownloadURLSession to use for managing AVAssetDownloadTasks.
//    fileprivate var assetDownloadURLSession: AVAssetDownloadURLSession!
//    /// Internal map of AVAggregateAssetDownloadTask to its corresponding Asset.
//    fileprivate var activeDownloadsMap = [AVAggregateAssetDownloadTask: any Downloadable]()
    
    private init(){
//        // Create the configuration for the AVAssetDownloadURLSession.
//        let backgroundConfiguration = URLSessionConfiguration.background(withIdentifier: "AAPL-Identifier")
//
//        // Create the AVAssetDownloadURLSession using the configuration.
//        assetDownloadURLSession =
//            AVAssetDownloadURLSession(configuration: backgroundConfiguration,
//                                      assetDownloadDelegate: self, delegateQueue: OperationQueue.main)
    }
    static let shared = DownloadService()
    
    func checkAssetDownloadStatus(asset:any Downloadable) -> AssetDownloadState {
        if let activeItem = activeDownloadMap[asset.assetId] {
            switch activeItem.0.state {
                
            case .running:
                return .downloading
            case .suspended:
                return .notDownloaded
            case .canceling:
                return .waiting
            case .completed:
                return .downloaded
            @unknown default:
                return .notDownloaded
            }
        }else if let _ = getURLFor(asset: asset) {
            return .downloaded
        }
        
        return .notDownloaded
       
    }
    
    func getURLFor(asset:any Downloadable) -> URL? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsURL.appendingPathComponent(String(asset.assetId+".mp4"))
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            // The file exists at the destination URL
            return destinationURL
        } else {
            // The file does not exist at the destination URL
            return nil
        }
    }
    
    func downloadVideo<T:Downloadable>(asset: T) {
        
        // create a URL from the video URL string
        guard let url = URL(string: asset.assetURL ?? "") else {
           // completionBlock(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            self.progressSubject.send((asset.assetId, 0.0, .notDownloaded, NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // create a download task
        let task = URLSession.shared.downloadTask(with: url) { (location, response, error) in
            
            if let error = error {
               // completionBlock(.failure(error))
                self.progressSubject.send((asset.assetId, 0.0, .notDownloaded, error))
                return
            }
            
            guard let location = location else {
                //completionBlock(.failure(NSError(domain: "Invalid location", code: 0, userInfo: nil)))
                self.progressSubject.send((asset.assetId, 0.0, .notDownloaded, NSError(domain: "Invalid location", code: 0, userInfo: nil)))
                return
            }
            
            // move the downloaded file to the Documents directory
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent(String(asset.assetId+".mp4"))
            
            do {
                try FileManager.default.moveItem(at: location, to: destinationURL)
              
               // completionBlock(.success(asset))
                self.progressSubject.send((asset.assetId, 1.0, .downloaded,nil))
            } catch {
               // completionBlock(.failure(error))
                self.progressSubject.send((asset.assetId, 0.0, .notDownloaded,error))
            }
        }
        
        // create a progress observer
        let progressObserver = task.progress.observe(\.fractionCompleted) { (progress, _) in
           
           // progressBlock(progress.fractionCompleted)
            self.progressSubject.send((asset.assetId, progress.fractionCompleted, .downloading, nil))
        }
    
        task.resume()
        activeDownloadMap[asset.assetId] = (task,progressObserver)
    }
    
    func cancelDownload(asset: any Downloadable) {
        
    }
}
