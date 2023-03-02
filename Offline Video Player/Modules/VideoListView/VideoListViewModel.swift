//
//  VideoListViewModel.swift
//  Offline Video Player
//
//  Created by Maneesh M on 28/02/23.
//

import Foundation
import Combine


//final class PostListViewModel: ObservableObject {
//
//
//    var subscriptions: [String: AnyCancellable] = [:]
//    @Published var posts: [Post] = []
//    @Published var error: Error?
//
//
//}



final class VideoListViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var error:Error?
    @Published var lessons = [Lesson]()
    
    private let networkService: NetworkService
    private var cancellable :AnyCancellable?
    
    init(networkService: NetworkService) {
        self.networkService = networkService
        
        self.isLoading = true
        self.cancellable = self.fetchPosts()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    self.isLoading = false
                case .failure(let error):
                    self.isLoading = false
                    self.error = error
                    print("Error: \(error.localizedDescription)")
                }
            }) { [weak self] lessons in
                guard let self = self else { return }
                self.lessons = lessons.lessons
            }
    }
    
    private func fetchPosts() -> AnyPublisher<LessonsServerModel, Error> {
       return networkService.fetch(LessonListRequest.lessons)
    }
}

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}
