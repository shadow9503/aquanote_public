//
//  Toast.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/10.
//

import UIKit

public struct Toast<Target> {
    public let target: Target
    
    public init(_ target: Target) {
        self.target = target
    }
}

public protocol ToastCompatible {
    associatedtype ToastTarget
    var toast: Toast<ToastTarget> { get }
}

extension ToastCompatible {
    public var toast: Toast<Self> {
        get { Toast(self) }
        set { }
    }
}

extension Toast where Target: UIViewController {
    /// duration: pop되어있는 시간
    func pop(_ message: String, duration: CGFloat = 1.25) {
        if message.isEmpty { return }
        var height: CGFloat = 35
        var radius: CGFloat = 15
        if message.contains("\n") {
            height = 55
            radius = 30
        }
        DispatchQueue.main.async {
            let xOffset: CGFloat = 25
            let yOffset: CGFloat = target.view.frame.size.height * 0.55
            let label = UILabel(frame: CGRect(
                x: xOffset,
                y: yOffset,
                width: target.view.frame.size.width - 50,
                height: height))
            label.layer.zPosition = 1000
            label.numberOfLines = 0
            label.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            label.textColor = .CustomColor.mainTextColor
            label.font = .CustomFont.sub1
            label.textAlignment = .center;
            label.alpha = 0.0
            label.layer.cornerRadius = radius;
            label.clipsToBounds  =  true
            label.text = message
            label.restorationIdentifier = "toastLabel"
            target.view.subviews.forEach {
                if $0.restorationIdentifier == "toastLabel" {
                    $0.removeFromSuperview()
                }
            }
            
            self.target.view.addSubview(label)
            UIView.animate(withDuration: 0.45, delay: 0, options: [.curveEaseIn], animations: {
                label.transform = CGAffineTransform(translationX: 0, y: -10)
                label.alpha = 1.0
            }, completion: { isCompleted in
                UIView.animate(withDuration: 0.25, delay: duration, options: [.curveEaseOut], animations: {
                    label.transform = CGAffineTransform(translationX: 0, y: 10)
                    label.alpha = 0.0
                })
            })
        }
    }
}
