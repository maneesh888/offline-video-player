//
//  VideoListView.swift
//  Offline Video Player
//
//  Created by Maneesh M on 27/02/23.
//

import SwiftUI

struct VideoListView: View {
    
    @ObservedObject private var viewModel = VideoListViewModel(networkService: URLSessionNetworkService())
    @State var navigate: Bool = false
    @State var selectedLesson:Lesson?{
        didSet{
            navigate = selectedLesson != nil
        }
    }
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView()
            }else{
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.lessons) { lesson in
                            
                                HStack {
                                    Text(lesson.name ?? "")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                    
                                }
                                .onTapGesture {
                                    selectedLesson = lesson
                                }
                        }
                        
                    }
                    if let selectedLesson = selectedLesson {
                        NavigationLink("",destination:VideoDetailView(viewModel: VideoDetailsViewModel(lessons: viewModel.lessons, selectedLesson: selectedLesson)),isActive: $navigate).navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .navigationBarTitle(Text(StringConstants.videoListTitle))
            }
            
        }
    }
}


struct VideoDetailView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = VideoDetailsViewController
    var viewModel:VideoDetailsViewModel!
    
    func makeUIViewController(context: Context) -> VideoDetailsViewController {
        let vc = VideoDetailsViewController(nibName: "VideoDetailsViewController", bundle: nil)
        vc.viewModel = viewModel
        return vc
    }
    
    func updateUIViewController(_ uiViewController: VideoDetailsViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
    static func dismantleUIViewController(_ uiViewController: VideoDetailsViewController, coordinator: ()) {
        print("Dismantled \(self)")
    }
}


//struct VideoListView_Previews: PreviewProvider {
//    static var previews: some View {
//        VideoListView()
//    }
//}
