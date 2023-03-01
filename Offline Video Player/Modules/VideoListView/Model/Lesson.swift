//
//  Lesson.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import Foundation

// MARK: - LessonsServerModel
struct LessonsServerModel: Codable {
    let lessons: [Lesson]
}

// MARK: - Lesson
struct Lesson: Codable, Identifiable {
    let id: Int
    let name, description: String?
    let thumbnail: String?
    let videoURL: String?
    
    var isDownloaded: Bool = false
    var progress: Double = 0.0

    enum CodingKeys: String, CodingKey {
        case id, name, description, thumbnail
        case videoURL = "video_url"
    }
}

extension Lesson: Downloadable {
    var assetURL: String? {
        return videoURL
    }
    
    
}
