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
    
    var viewModel:VideoListViewModel!
    var lessons:[Lesson] = []
    var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        viewModel = VideoListViewModel(networkService: MockNetworkService())
        let semaphore = DispatchSemaphore(value: 0)
        
        viewModel.fetchLessons()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Loading list failed with error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                semaphore.signal()
            }, receiveValue: { [unowned self] items in
                self.lessons = items.lessons
            })
            .store(in: &cancellables)
        semaphore.wait()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testListIsNotEmpty() {
        // Ensure the list is not empty
        XCTAssertFalse(lessons.isEmpty)
    }
    
    func testListHasCorrectNumberOfItems() {
        // Ensure the list has the correct number of items
        XCTAssertEqual(lessons.count, 13)
    }
    
    func testListContainsExpectedItems() {
        // Ensure the list contains the expected items
        XCTAssertTrue(lessons.contains(where: {$0.id == 1}))
        XCTAssertTrue(lessons.contains(where: {$0.id == 0}))
        XCTAssertTrue(lessons.contains(where: {$0.id == 5630}))
    }
    
    func testListDoesNotContainUnexpectedItems() {
        // Ensure the list does not contain unexpected items
        // XCTAssertFalse(list.contains("Item 4"))
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
    }
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
}
