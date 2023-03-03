//
//  NaviagationBarColorModifier.swift
//  Offline Video Player
//
//  Created by Maneesh M on 04/03/23.
//

import SwiftUI

struct NavigationBarColorModifier: ViewModifier {
    var backgroundColor: UIColor?
    var tintColor: UIColor?
    var largeTitleColor: UIColor?
 
    init(backgroundColor: UIColor?, tintColor: UIColor?, largeTitleColor: UIColor?) {
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
        self.largeTitleColor = largeTitleColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
 
        if let backgroundColor = backgroundColor {
            appearance.backgroundColor = backgroundColor
        }
 
        if let tintColor = tintColor {
            appearance.titleTextAttributes = [.foregroundColor: tintColor]
            appearance.largeTitleTextAttributes = [.foregroundColor: tintColor]
        }
 
        if let largeTitleColor = largeTitleColor {
            appearance.largeTitleTextAttributes = [.foregroundColor: largeTitleColor]
        }
 
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
 
    func body(content: Content) -> some View {
        content
    }
}

extension View {
    func navigationBarColor(backgroundColor: UIColor?, tintColor: UIColor?, largeTitleColor: UIColor?) -> some View {
        self.modifier(NavigationBarColorModifier(backgroundColor: backgroundColor, tintColor: tintColor, largeTitleColor: largeTitleColor))
    }
}
