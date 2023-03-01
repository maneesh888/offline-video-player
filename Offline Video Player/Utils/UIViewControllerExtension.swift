//
//  UIViewControllerExtension.swift
//  Offline Video Player
//
//  Created by Maneesh M on 01/03/23.
//

import UIKit

extension UIViewController {
    func add(_ child: UIViewController,to view:UIView) {
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    func remove(_ child: UIViewController) {
        child.view.removeFromSuperview()
        child.willMove(toParent: nil)
        child.removeFromParent()
    }
}
