//
//  ++UIViewController.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/14.
//

import UIKit

extension UIView {
    func setBlur(style: UIBlurEffect.Style, text: String = "", opacity: CGFloat = 0.75, duration: TimeInterval = 0.5, zPosition: CGFloat = 1000, indicatorStyle: UIActivityIndicatorView.Style = .large, indicatorColor: UIColor = .CustomColor.mainTextColor, completion: @escaping(UIVisualEffectView) -> Void) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            let blur = UIBlurEffect(style: style)
            let blurView = UIVisualEffectView(effect: blur)
            blurView.frame = self.superview!.frame
            blurView.layer.zPosition = zPosition
            blurView.alpha = 0
            self.addSubview(blurView)
            
            let indicator = UIActivityIndicatorView()
            indicator.startAnimating()
            indicator.style = indicatorStyle
            indicator.color = indicatorColor
            blurView.contentView.addSubview(indicator)
            indicator.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(-30)
            }
            
            let label = UILabel()
            label.text = text
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .CustomFont.sub1
            label.textColor = text.isEmpty ? .clear : .CustomColor.mainTextColor
            blurView.contentView.addSubview(label)
            label.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(indicator.snp_bottomMargin).offset(20)
            }
            
            DispatchQueue.main.async {
                UIView.animate(withDuration: duration, delay: 0) {
                    blurView.alpha = opacity
                }
            }
            completion(blurView)
        }
    }
    
    func setBlur(style: UIBlurEffect.Style, text: String = "", opacity: CGFloat = 0.75, duration: TimeInterval = 0.5, zPosition: CGFloat = 1000, indicatorStyle: UIActivityIndicatorView.Style = .large, indicatorColor: UIColor = .CustomColor.mainTextColor) {
        self.isUserInteractionEnabled = false
        guard let superview = self.superview else { return }
        DispatchQueue.main.async {
            let blur = UIBlurEffect(style: style)
            let blurView = UIVisualEffectView(effect: blur)
            blurView.frame = superview.frame
            blurView.layer.zPosition = zPosition
            blurView.alpha = 0
            self.addSubview(blurView)
            
            let indicator = UIActivityIndicatorView()
            indicator.startAnimating()
            indicator.style = indicatorStyle
            indicator.color = indicatorColor
            blurView.contentView.addSubview(indicator)
            indicator.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(-30)
            }
            
            let label = UILabel()
            label.text = text
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .CustomFont.sub1
            label.textColor = text.isEmpty ? .clear : .CustomColor.mainTextColor
            blurView.contentView.addSubview(label)
            label.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalTo(indicator.snp_bottomMargin).offset(20)
            }
            
            UIView.animate(withDuration: duration, delay: 0) {
                blurView.alpha = opacity
            }
        }
    }
    
    @objc func removeBlur() {
        self.isUserInteractionEnabled = true
        DispatchQueue.main.async {
            self.subviews.forEach {
                if $0 is UIVisualEffectView {
                    $0.removeFromSuperview()
                }
            }
        }
    }
}

extension UIViewController {
    
    func presentView(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.present(viewController, animated: animated)
    }
    
    func pushView(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
    
    func popView(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func setView(_ viewController: UIViewController, animated: Bool = true) {
        navigationController?.setViewControllers([viewController], animated: animated)
    }
    
    @objc func popView() {
        navigationController?.popViewController(animated: true)
    }
}

extension UIViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        switch operation {
        case .none:
            return nil
        case .push:
            if fromVC.classForCoder == RootViewController.classForCoder() {
                return Animator(originFrame: toVC.view.frame, animationType: .set, duration: 0.25)
            } else {
                return Animator(originFrame: toVC.view.frame, animationType: .push, duration: 0.25)
            }
        case .pop:
            return nil //Animator(originFrame: toVC.view.frame, animationType: .dismiss, duration: 0.25)
        @unknown default:
            return nil
        }
    }
}

enum AnimationType {
    case present
    case push
    case set
    case dismiss
}

class Animator: NSObject, UIViewControllerAnimatedTransitioning {

    private let originFrame: CGRect
    private let duration: Double
    private let animationType: AnimationType
    
    init(originFrame: CGRect, animationType: AnimationType, duration: Double) {
        self.originFrame = originFrame
        self.animationType = animationType
        self.duration = duration
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        
        switch animationType {
        case .push:
            let containerView = transitionContext.containerView
            let finalFrame = transitionContext.finalFrame(for: toVC)

            snapshot.frame = originFrame
            
            containerView.addSubview(toVC.view)
            containerView.addSubview(snapshot)
            
            // view prepare
            toVC.view.transform = CGAffineTransform(translationX: finalFrame.width, y: 0)
            snapshot.transform = CGAffineTransform(translationX: finalFrame.width, y: 0)
            
            // view animate
            UIView.animate(withDuration: duration, delay: 0, animations: {
                toVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
                snapshot.transform = CGAffineTransform(translationX: 0, y: 0)
            }) { isComplete in
                UIView.animate(withDuration: 0.25, delay: 0, animations: {
                    snapshot.alpha = 0
                }) { _ in
                    snapshot.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            }
            
            break
        case .set:
            let containerView = transitionContext.containerView
            let finalFrame = transitionContext.finalFrame(for: toVC)

            snapshot.frame = originFrame
            
            containerView.addSubview(toVC.view)
            containerView.addSubview(snapshot)
            
            // view prepare
            toVC.view.transform = CGAffineTransform(translationX: 0, y: finalFrame.height)
            snapshot.transform = CGAffineTransform(translationX: 0, y: finalFrame.height)
            
            // view animate
            UIView.animate(withDuration: duration, delay: 0, animations: {
                toVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
                snapshot.transform = CGAffineTransform(translationX: 0, y: 0)
            }) { isComplete in
                UIView.animate(withDuration: 0.25, delay: 0, animations: {
                    snapshot.alpha = 0
                }) { _ in
                    snapshot.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            }
            
            break
        case .present:
            let containerView = transitionContext.containerView
            let finalFrame = transitionContext.finalFrame(for: toVC)

            snapshot.frame = originFrame
            
            containerView.addSubview(toVC.view)
            containerView.addSubview(snapshot)
            
            // view prepare
            toVC.view.transform = CGAffineTransform(translationX: 0, y: finalFrame.height)
            snapshot.transform = CGAffineTransform(translationX: 0, y: finalFrame.height)
            
            // view animate
            UIView.animate(withDuration: duration, delay: 0, animations: {
                toVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
                snapshot.transform = CGAffineTransform(translationX: 0, y: 0)
//                fromVC.view.transform = CGAffineTransform(translationX: 0, y: -finalFrame.height)
            }) { isComplete in
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    snapshot.alpha = 0
                }) { _ in
                    snapshot.removeFromSuperview()
                    transitionContext.completeTransition(true)
                }
            }
            
            break
        case .dismiss:
            // 2
            let containerView = transitionContext.containerView
            let finalFrame = transitionContext.finalFrame(for: toVC)
            
            snapshot.frame = originFrame
            
            containerView.insertSubview(toVC.view, at:0 )
            containerView.addSubview(snapshot)
            
            // view prepare
            toVC.view.transform = CGAffineTransform(translationX: 0, y: -finalFrame.height)
            
            // view animate
            UIView.animate(withDuration: duration, delay: 0, animations: {
                toVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
                snapshot.transform = CGAffineTransform(translationX: 0, y: finalFrame.height)
                fromVC.view.transform = CGAffineTransform(translationX: 0, y: finalFrame.height)
            }) { isComplete in
                snapshot.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
            
            break
        }
    }
}


extension UIView {
    
    enum GradientDirection {
        case fromLeft
        case fromRight
        case fromTop
        case fromBottom
        case custom(CGPoint, CGPoint)
    }
    
    func backgroundColorWithGradient(colors: [UIColor], bounds: CGRect?, paintingDirection: GradientDirection = .fromTop) {
        self.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.cornerRadius = self.layer.cornerRadius
        gradientLayer.masksToBounds = true
        
        switch paintingDirection {
        case .fromLeft:
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
            break
        case .fromRight:
            gradientLayer.startPoint = CGPoint(x:1, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0, y: 0.5)
            break
        case .fromTop:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
            break
        case .fromBottom:
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
            break
        case .custom(let startPoint, let endPoint):
            gradientLayer.startPoint = startPoint
            gradientLayer.endPoint = endPoint
            break
        }
        
        if let bounds = bounds {
            gradientLayer.frame = bounds
        } else {
            gradientLayer.frame = self.layer.bounds
        }
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIViewController: ToastCompatible {
    
    func toast(_ message: String?, duration: CGFloat = 1.25) {
        guard let message = message else { return }
        toast.pop(message, duration: duration)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func newAlertController(title: String ,message: String,style: UIAlertController.Style = .alert, actions: [UIAlertAction]) -> UIAlertController {
        let alert = UIAlertController(title: title,
                                      message: message, preferredStyle: style)
        actions.forEach {
            alert.addAction($0)
        }
        
        return alert
    }
}
