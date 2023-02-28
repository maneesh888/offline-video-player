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
                            NavigationLink(destination: DetailView()) {
                                HStack {
                                    Text(lesson.name)
                                        .font(.headline)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                    
                                }
                            }
                        }
                        //                    ForEach(items) { vodItem in
                        //                        Button(action: {
                        //                            self.selectedItem = vodItem
                        //                        }) {
                        //                            Image(vodItem.imageName)
                        //                                .resizable()
                        //                                .aspectRatio(contentMode: .fit)
                        //                                .frame(width: 50, height: 50)
                        //                            Text(vodItem.title)
                        //                                .font(.headline)
                        //                        }
                        ////                        .sheet(item: $selectedMovie) { movie in
                        ////                            //
                        ////                        }
                        //                    }
                    }
                }
                .navigationBarTitle(Text(StringConstants.videoListTitle))
            }
//            List(items) { item in
//                NavigationLink(destination: DetailView()) {
//                    HStack {
//                        Image(item.imageName)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 50, height: 50)
//                        Text(item.title)
//                            .font(.headline)
//                        //Spacer()
//
//                    }
//                }
//            }
            
        }
    }
}


struct DetailView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = VideoDetailsViewController
    
    func makeUIViewController(context: Context) -> VideoDetailsViewController {
        let vc = VideoDetailsViewController(nibName: "VideoDetailsViewController", bundle: nil)
       // vc.viewModel = VideoDetailsViewController()
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
