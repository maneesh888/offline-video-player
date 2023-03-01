//
//  ViewControllerFactory.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import Foundation

struct ViewControllerFactory {
    static func getLocationList()-> VideoDetailsViewController {
        let vc = VideoDetailsViewController(nibName: "VideoDetailsViewController", bundle: nil)
       // vc.viewModel = VideoDetailsViewController()
        return vc
    }
    
    
    static func getLessonPlayer(lesson:Lesson)-> LessonPlayerViewController {
        let vc = LessonPlayerViewController(nibName: "LessonPlayerViewController", bundle: nil)
        vc.viewModel = LessonPlayerViewModel(assetPath: lesson.videoURL)
        return vc
    }
}
