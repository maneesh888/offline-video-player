//
//  VideoListScreenUITests.swift
//  Offline Video PlayerUITests
//
//  Created by Maneesh M on 04/03/23.
//

import XCTest
import Combine
import AVKit

final class VideoListScreen: XCTestCase {

    var viewModel: VideoListViewModel!
    var cancellables: Set<AnyCancellable> = []
    var lessons:[Lesson] = []
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        
        continueAfterFailure = false
                app = XCUIApplication()
                app.launch()
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        viewModel = VideoListViewModel(networkService: URLSessionNetworkService())
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
        self.viewModel = nil
        self.app = nil
        XCUIDevice.shared.orientation = .portrait
    }

    func testVisibleItems() throws {

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        for lesson in self.lessons {
            let id = lesson.id
            print("MM \(id)")
            let element = XCUIApplication().scrollViews.otherElements.staticTexts["com.myapp.lesson_list_screen_item_\(id)"]
            if  element.exists {
                XCTAssertEqual(lesson.name, element.label)
//                XCTAssertTrue(XCUIApplication().scrollViews.images["com.myapp.lesson_list_screen_item_imageView_\(lesson.id)"].exists)
//                XCTAssertTrue(XCUIApplication().scrollViews.images["com.myapp.lesson_list_screen_item_arrorw_\(lesson.id)"].exists)
            }
            
        }
                
    }
    
    func testItemSelect() {
        
        // Given
        
        if let firstLesson = self.lessons.first {
            
            // When
            
            XCUIApplication().scrollViews.otherElements.staticTexts["com.myapp.lesson_list_screen_item_\(firstLesson.id)"].tap()
            
            // Then
            
            XCTAssertTrue(app.otherElements["com.myapp.video_detailscreen_view"].waitForExistence(timeout: 3.0), "VideoDetailsViewController should be visible")
            
            XCTAssertEqual(app.staticTexts["com.myapp.video_detailscreen_title"].label,firstLesson.name ?? "")
            XCTAssertEqual(app.staticTexts["com.myapp.video_detailscreen_description"].label,firstLesson.description ?? "")
               
            XCTAssertTrue(app.buttons["com.myapp.video_detailscreen_playNextbutton"].exists)
            
            
            
            let downloadButton = XCUIApplication().navigationBars.buttons["com.myapp.video_detailscreen_downloadProgressView"]
            XCTAssert(downloadButton.exists)
            
           // XCTAssertTrue(downloadButton.otherElements["com.myapp.DownloadButtonView.progressButton"].exists)
           // XCTAssertTrue(downloadButton.otherElements["com.myapp.DownloadButtonView.statusLabel"].exists)
            
            
           // XCTAssertEqual(app.staticTexts["com.myapp.DownloadButtonView.statusLabel"].label, DownloadService.shared.checkAssetDownloadStatus(asset: firstLesson). )
            
                        
        }
    }
    
    func testVideoPlayer() {
        // Given
        if let firstLesson = self.lessons.first {
            
            // When
            
            XCUIApplication().scrollViews.otherElements.staticTexts["com.myapp.lesson_list_screen_item_\(firstLesson.id)"].tap()
            
            let videoPlayerContainer = app.otherElements["com.myapp.video_detailscreen_player_container"]
            let playButton = app.buttons["com.myapp.video_detailscreen_playbutton"]
            
            sleep(2)
            
            // When
            playButton.tap()
            sleep(5) // Wait for video to play for 5 seconds
            
            // Then
            XCTAssertTrue(videoPlayerContainer.exists)
            XCTAssertTrue(videoPlayerContainer.isHittable)
           // XCTAssertFalse(playButton.exists)
            
            
            
//            let player = videoPlayerContainer.value(forKey: "com.myapp.video_detailscreen_avplayer") as? AVPlayer
//
//            XCTAssertNotNil(player, "AVPlayer should not be nil")
//            XCTAssertEqual(player?.status, .readyToPlay, "AVPlayer should be ready to play")
            
           
            let orient = [UIDeviceOrientation.landscapeLeft, UIDeviceOrientation.landscapeRight]
            XCUIDevice.shared.orientation = orient[Int(arc4random_uniform(UInt32(orient.count)))]
            
            XCTAssertTrue(app.otherElements["com.myapp.video_detailscreen_fullScreenPlaayer"].waitForExistence(timeout: 3.0), "Full Screen player should be visible")
            
            
            
            XCUIDevice.shared.orientation = .portrait
            
            XCTAssertTrue(app.otherElements["com.myapp.video_detailscreen_view"].waitForExistence(timeout: 1.0), "VideoDetailsViewController should be visible")
        }
        
    }
    
    func testNextItemSelect() {
        
        
        
        // Given
        
        if let firstLesson = self.lessons.first {
            
            // When
            
            XCUIApplication().scrollViews.otherElements.staticTexts["com.myapp.lesson_list_screen_item_\(firstLesson.id)"].tap()
            
            // Then
            
            XCTAssertTrue(app.otherElements["com.myapp.video_detailscreen_view"].waitForExistence(timeout: 3.0), "VideoDetailsViewController should be visible")
            
            
            let nextButton = app.buttons["com.myapp.video_detailscreen_playNextbutton"]
            XCTAssert(nextButton.exists)
            
            nextButton.tap()
            
            guard let firstIndex = self.lessons.firstIndex(where: {$0.id == firstLesson.id}) else { return }
            
            guard self.lessons.count > firstIndex else {return}
            
            let nextItem = self.lessons[firstIndex+1]
            
            XCTAssertEqual(app.staticTexts["com.myapp.video_detailscreen_title"].label,nextItem.name ?? "")
            XCTAssertEqual(app.staticTexts["com.myapp.video_detailscreen_description"].label,nextItem.description ?? "")
            
            
            
            
        }
    }
    


//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
