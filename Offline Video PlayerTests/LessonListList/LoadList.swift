//
//  LoadList.swift
//  Offline Video PlayerTests
//
//  Created by Maneesh M on 04/03/23.
//

import XCTest
import Combine
@testable import Offline_Video_Player

final class LoadList: XCTestCase {
    
    
    var cancellables: Set<AnyCancellable> = []
    var lessons = [Lesson]()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
      
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testLoadList() {
        // Given
        let viewModel = VideoListViewModel(networkService: MockNetworkService())
        let expectation = XCTestExpectation(description: "Mock list loaded")
        
        
        // When
        viewModel.fetchLessons()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Loading list failed with error: \(error.localizedDescription)")
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { [unowned self] items in
                self.lessons = items.lessons
            })
            .store(in: &cancellables)
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertFalse(lessons.isEmpty, "Loaded list should not be empty")
        XCTAssertEqual(lessons.count, 12)
        XCTAssertTrue(lessons.contains(where: {$0.id == 1000}))
    }
    
    
    func testPerformanceExample() throws {
        
        // Given
        let expectation = XCTestExpectation(description: "API response received")
        let viewModel = VideoListViewModel(networkService: URLSessionNetworkService())
        
        // When
        // When
        measure {
            viewModel.fetchLessons()
                .sink(receiveCompletion: { _ in },
                      receiveValue: { _ in
                    expectation.fulfill()
                })
                .store(in: &cancellables)
        }
        
        
        // Then
        wait(for: [expectation], timeout: 5.0)
    }
    
}
