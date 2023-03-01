//
//  LessonPlayerViewModel.swift
//  Offline Video Player
//
//  Created by Maneesh M on 01/03/23.
//

import Foundation

final class LessonPlayerViewModel {
     var assetPath:String?
     var lesson:Lesson?{
        didSet{
            self.assetPath = lesson?.videoURL
        }
    }
    
    init(assetPath: String? = nil, lesson: Lesson? = nil) {
        self.assetPath = assetPath
        self.lesson = lesson
        if assetPath == nil {
            self.assetPath = lesson?.videoURL
        }
    }
}
