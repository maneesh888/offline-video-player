//
//  VideoDetailsViewModel.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import Foundation

final class VideoDetailsViewModel {
    var lessons = [Lesson]()
    var selectedLesson:Lesson
    
    init(lessons: [Lesson] = [Lesson](), selectedLesson: Lesson) {
        self.lessons = lessons
        self.selectedLesson = selectedLesson
    }
}
