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
    
//    init(networkService: NetworkService) {
//        self.networkService = networkService
//    }
    
    
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
                    print("Error: \(error.localizedDescription)")
                }
            }) { [weak self] lessons in
                guard let self = self else { return }
                self.lessons = lessons.lessons
            }
    }
    
//    private func loadPosts() -> AnyPublisher<[Post], Error> {
//        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
//        return URLSession.shared
//            .dataTaskPublisher(for: url)
//            .map { $0.data }
//            .decode(type: [Post].self, decoder: JSONDecoder())
//            .eraseToAnyPublisher()
//    }
    
    
    
    private func fetchPosts() -> AnyPublisher<LessonsServerModel, Error> {
       return networkService.fetch(.lessons)
//            .sink(
//                receiveCompletion: { [weak self] completion in
//                    if case let .failure(error) = completion {
//                        self?.error = error
//                    }
//                },
//                receiveValue: { [weak self] lessons in
//                    self?.lessons = lessons
//                }
//            )
//            .store(in: &cancellables)
    }
}

struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let body: String
}
