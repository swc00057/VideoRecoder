//
//  UIKit+.swift
//  VideoRecorder
//
//  Created by 홍다희 on 2022/10/12.
//

import UIKit

extension UIViewController {
    func addChildViewController(_ child: UIViewController, toContainerView containerView: UIView) {
        addChild(child)
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }
}
