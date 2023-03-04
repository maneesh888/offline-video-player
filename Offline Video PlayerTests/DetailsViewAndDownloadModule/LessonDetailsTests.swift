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
                
                if let selected = items.lessons.last {
                    self.viewModel = VideoDetailsViewModel(lessons: items.lessons, selectedLesson: selected)
                }else{
                    XCTFail("Selecting item form lessons failed")
                }
                semaphore.signal()
            })
            .store(in: &cancellables)
        semaphore.wait()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGetState() throws {
        // This is an example of a functional test case.
        XCTAssertEqual(viewModel.getStateFor(asset: viewModel.selectedLesson), .notDownloaded)
    }
    
    func testGetURLFunc() {
        if viewModel.getStateFor(asset: viewModel.selectedLesson) != .downloaded {
            XCTAssertEqual(URL(string:viewModel.selectedLesson.videoURL ?? ""), viewModel.getURLForSelected())
        }else{
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent(String(viewModel.selectedLesson.assetId+".mp4"))
            
            XCTAssertEqual(destinationURL, viewModel.getURLForSelected())
        }
    }
    
    func testChooseNextLesson() {
        if viewModel.selectedLesson.id == viewModel.lessons.last?.id {
            // last item
            viewModel.chooseNextLesson()
            XCTAssertEqual(viewModel.selectedLesson.id, viewModel.lessons.last?.id)
        }else{
            if let currentItemId = viewModel.lessons.firstIndex(where: {$0.id == viewModel.selectedLesson.id}) {
                viewModel.chooseNextLesson()
                XCTAssertEqual(viewModel.selectedLesson.id, viewModel.lessons[currentItemId+1].id)
            }else {
                XCTFail()
            }
        }
    }
    
    func testDownload() {
        
        
        
        // Given
        let downloadStateChangeExpectation = XCTestExpectation(description: "Download complete")
        let downloadCompleteExpectation = XCTestExpectation(description: "Download complete")
        let progressExpectation = XCTestExpectation(description: "Progress update received")
        
        guard let dummyLesson = viewModel.lessons.last else {
            XCTFail()
            return
        }
        viewModel.selectedLesson = dummyLesson
        
        if viewModel.getStateFor(asset: dummyLesson) == .downloaded, let fileUrl =  viewModel.getURLForSelected(){
            do {
                try FileManager.default.removeItem(at: fileUrl)
            }catch {
                
            }
        }
        
        // Then
        viewModel.downloadSelectedLesson()
        self.measure {
            viewModel.downloadProgress
            
                .sink { (progress, state) in
                    print(progress, state)
                    if state == .downloading {
                        downloadStateChangeExpectation.fulfill()
                    }
                    progressExpectation.fulfill()
                    if state == .downloaded {
                        downloadCompleteExpectation.fulfill()
                    }
                    if state == .notDownloaded {
                        XCTFail("Download failed")
                    }
                    
                }
                .store(in: &cancellables)
        }
        // Then
        wait(for: [downloadCompleteExpectation], timeout: 30.0)
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsURL.appendingPathComponent(String(viewModel.selectedLesson.assetId+".mp4"))
        XCTAssertEqual(destinationURL, self.viewModel.getURLForSelected())
        
        
    }
    
    func testCancelDownload() {
        
        guard let firstItem = viewModel.lessons.first else {return}
        viewModel.selectedLesson = firstItem
        
        let downloadCancelExpectation = XCTestExpectation(description: "Download Cancel")
        let progressExpectation = XCTestExpectation(description: "Progress update received")
        
        if viewModel.getStateFor(asset: viewModel.selectedLesson) == .downloaded, let fileUrl =  viewModel.getURLForSelected(){
            do {
                try FileManager.default.removeItem(at: fileUrl)
            }catch {
                
            }
        }
        
        // Then
        viewModel.downloadSelectedLesson()
        self.measure {
            viewModel.downloadProgress
            
                .sink { [weak self] (progress, state) in
                    print(progress, state)
                    
                    if progress > 0.05 {
                        progressExpectation.fulfill()
                        self?.viewModel.cancelDownload()
                    }
                    
                    if state == .notDownloaded {
                        downloadCancelExpectation.fulfill()
                    }
                    
                }
                .store(in: &cancellables)
        }
        
        wait(for: [downloadCancelExpectation], timeout: 10.0)
        XCTAssertEqual(AssetDownloadState.notDownloaded, self.viewModel.getStateFor(asset: firstItem))
    
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
