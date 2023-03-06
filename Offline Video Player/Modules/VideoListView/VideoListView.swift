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
                    Spacer(minLength: 30)
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.lessons) { lesson in
                            
                            HStack () {
                                AsyncImage(url: URL(string: lesson.thumbnail ?? "")) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProgressView()
                                }
                                .frame(width: 110, height: 70)
                                .cornerRadius(5.0)
                                .padding(.trailing)
                                .padding(.leading)
                                
                                
                                Text(lesson.name ?? "")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .layoutPriority(1)
                                    .lineLimit(3)
                                    .frame(width: 200, height: 80, alignment: .leading)
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.blue).padding(.trailing,30)
                                
                            }
                            .frame(height: 50)
                            .onTapGesture {
                                selectedLesson = lesson
                            }.accessibilityIdentifier("com.myapp.lesson_list_screen_item_\(lesson.id)")
                            
                            Divider()
                                .frame(height: 2)
                                .background(Color(ColorUtil.dividerColor))
                                .padding(.leading, 150)
                            
                        }
                        
                    }
                    if let selectedLesson = selectedLesson {
                        NavigationLink("",destination:VideoDetailView(viewModel: VideoDetailsViewModel(lessons: viewModel.lessons, selectedLesson: selectedLesson)),isActive: $navigate).navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .navigationBarTitle(Text(StringConstants.videoListTitle))
                
                .background(Color(ColorUtil.backgroundColor))
            }
            
        }
        .navigationBarTitle("Title")
        .navigationBarColor(backgroundColor: ColorUtil.backgroundColor, tintColor: .white, largeTitleColor: .white)
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


struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
