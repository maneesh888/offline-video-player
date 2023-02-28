//
//  VideoListView.swift
//  Offline Video Player
//
//  Created by Maneesh M on 27/02/23.
//

import SwiftUI

struct VideoListView: View {
    var body: some View {
        NavigationView {
            List(items) { item in
                NavigationLink(destination: DetailView()) {
                    HStack {
                        Image(item.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        Text(item.title)
                            .font(.headline)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarTitle(Text("Items"))
        }
    }
}

struct Item: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
}

let items = [
    Item(imageName: "photo1", title: "Item 1"),
    Item(imageName: "photo2", title: "Item 2"),
    Item(imageName: "photo3", title: "Item 3")
]

struct DetailView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = DetailViewController
    
    func makeUIViewController(context: Context) -> DetailViewController {
        let vc = DetailViewController()
        // Do some configurations here if needed.
        return vc
    }
    
    func updateUIViewController(_ uiViewController: DetailViewController, context: Context) {
        // Updates the state of the specified view controller with new information from SwiftUI.
    }
    
}

class DetailViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        title = "UIKit View"
    }
}


struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
