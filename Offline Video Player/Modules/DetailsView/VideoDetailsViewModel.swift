//
//  VideoDetailsViewModel.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import Foundation
import Combine

final class VideoDetailsViewModel {
    
    var lessons = [Lesson]()
    @Published var selectedLesson:Lesson
    
    var userInitiatedPlayback = false
    var currentIndex: Int? {
        return lessons.firstIndex(where: {$0.id == selectedLesson.id})
    }
    
    var hideNextButton: Bool {
        if let currentIndex = currentIndex {
            return lessons.count == currentIndex+1
        }
        return false
    }
    
    var downloadState: AssetDownloadState {
        return downloadService.checkAssetDownloadStatus(asset: selectedLesson)
    }
    
    var downloadService: DownloadService {
        return DownloadService.shared
    }
    
    let downloadProgress = PassthroughSubject<(Double, AssetDownloadState), Never>()
    private var cancellables: Set<AnyCancellable> = []
    
    init(lessons: [Lesson] = [Lesson](), selectedLesson: Lesson) {
        self.lessons = lessons
        self.selectedLesson = selectedLesson
        
        downloadService.progressPublisher
                    .receive(on: DispatchQueue.main)
                    .filter({ [weak self] (assetId, _, _, _) in
                        guard let self = self else {return false}
                        return self.selectedLesson.assetId == assetId
                    })
                    .sink { [weak self] (id, progress, state, error) in
                       print(id, progress, state, error)
                        self?.downloadProgress.send((progress, state))
                    }
                    .store(in: &cancellables)
    }
    
    func downloadButtonAction() {
        
        let state = downloadService.checkAssetDownloadStatus(asset: selectedLesson)
        
        switch state {
        case .notDownloaded:
            downloadService.downloadVideo(asset: selectedLesson)
        case .waiting:
            break
        case .downloading:
            downloadService.cancelDownload(asset: selectedLesson)
        case .downloaded:
            break
        }
    }
    func getStateFor(asset:any Downloadable) -> AssetDownloadState {
        return downloadService.checkAssetDownloadStatus(asset: selectedLesson)
    }
    
    func getURLForSelected()-> URL? {
        if let url = downloadService.getURLFor(asset: selectedLesson) {
            return url
        }else{
            return URL(string: selectedLesson.videoURL ?? "")
        }
    }
    
    func chooseNextLesson() {
        if let currentIndex = currentIndex, lessons.count > currentIndex+1 {
            selectedLesson = lessons[currentIndex+1]
        }
    }
    
}
