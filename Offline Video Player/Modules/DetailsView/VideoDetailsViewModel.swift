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
    var selectedLesson:Lesson
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(lessons: [Lesson] = [Lesson](), selectedLesson: Lesson) {
        self.lessons = lessons
        self.selectedLesson = selectedLesson
    }
    
    func downloadSelectedVideo() {
        guard DownloadService.shared.checkAssetDownloadStatus(asset: selectedLesson) == .notDownloaded  else {return}
         DownloadService.shared.downloadVideo(asset: selectedLesson)
        
        DownloadService.shared.progressPublisher
                    .receive(on: DispatchQueue.main)
                    .sink { (id, progress, state, error) in
                       print(id, progress, state, error)
                    }
                    .store(in: &cancellables)
        
    }
    
}
