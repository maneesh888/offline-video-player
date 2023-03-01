//
//  VideoListView.swift
//  Offline Video Player
//
//  Created by Maneesh M on 27/02/23.
//

import SwiftUI

struct VideoListView: View {
    
    @ObservedObject private var viewModel = VideoListViewModel(networkService: MockNetworkService())
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
               // ActivityIndicator(isAnimating: .constant(true), style: .large)
            }else{
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.lessons) { lesson in
                            NavigationLink(destination: VideoDetailView(viewModel: VideoDetailsViewModel(lessons: viewModel.lessons, selectedLesson: lesson))) {
                                HStack {
                                    Text(lesson.name ?? "")
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                    
                                }
                            }
                        }
                    }
                }
                .navigationBarTitle(Text(StringConstants.videoListTitle))
            }
            
        }
    }
}


struct VideoDetailView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = VideoDetailsViewController
    var viewModel:VideoDetailsViewModel
    init(viewModel:VideoDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    func makeUIViewController(context: Context) -> VideoDetailsViewController {
        let vc = VideoDetailsViewController(nibName: "VideoDetailsViewController", bundle: nil)
        vc.viewModel = viewModel
        return vc
    }
    
    func updateUIViewController(_ uiViewController: VideoDetailsViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
    
}


struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
