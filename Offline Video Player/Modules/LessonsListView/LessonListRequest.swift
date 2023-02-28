//
//  LessonListRequest.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import Foundation

enum LessonListRequest: NetworkRequest {
    case lessons
    
    
    var path: String {
        switch self {
        case .lessons:
            return "https://iphonephotographyschool.com/test-api/lessons"
        }
    }
    var mockPath: String? {
        switch self {
        case .lessons:
            return "mockLessons"
        }
        
    }
    
    
}
