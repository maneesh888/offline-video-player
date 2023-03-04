//
//  LessonDetailsTests.swift
//  Offline Video PlayerTests
//
//  Created by Maneesh M on 04/03/23.
//

import XCTest
import Combine
@testable import Offline_Video_Player

final class LessonDetailsTests: XCTestCase {
    
    var viewModel: VideoDetailsViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        let listVM = VideoListViewModel(networkService: MockNetworkService())
        let semaphore = DispatchSemaphore(value: 0)
        
        listVM.fetchLessons()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Loading list failed with error: \(error.localizedDescription)")
                case .finished:
                    break
                }
                
            }, receiveValue: { [unowned self] items in
                
                if let selected = items.lessons.first {
                    self.viewModel = VideoDetailsViewModel(lessons: items.lessons, selectedLesson: selected)
                    semaphore.signal()
                }else{
                    XCTFail("Selecting item form lessons failed")
                }
                
            })
            .store(in: &cancellables)
        semaphore.wait()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

}
