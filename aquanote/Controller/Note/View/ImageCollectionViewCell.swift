//
//  ImageCollectionViewCell.swift
//  aquanote
//
//  Created by 유영훈 on 2023/01/27.
//

import UIKit
import SnapKit
import Kingfisher

class ImageCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "ImageCollectionViewCell"
    
    var imageView: CustomImageView = {
        let view = CustomImageView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        showView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill<T>(_ item: T) {
        switch T.self {
        case is Data.Type:
            let image = UIImage(data: item as! Data)!
            if image.isSymbolImage {
                let config = UIImage.SymbolConfiguration(pointSize: 45)
                imageView.contentMode = .center
                imageView.image = image.withConfiguration(config).withTintColor(.CustomColor.subTextColor, renderingMode: .alwaysOriginal)
            } else {
                imageView.contentMode = .scaleAspectFit
                imageView.image = image.resized(to: CGSize(width: 250, height: 250))
            }
            break
        case is String.Type:
            let item = item as! String
            guard let url = URL(string: item) else { return }
            let deaultImage = UIImage(named: "Bottle")!
                .withTintColor(.CustomColor.lightgray, renderingMode: .alwaysOriginal)
            let processor = DownsamplingImageProcessor(
                size: CGSize(width: 250, height: 250))
            imageView.kf.indicatorType = .activity
            KF.url(url)
                .setProcessor(processor)
                .placeholder(deaultImage)
                .retry(maxCount: 2, interval: .seconds(4))
                .transition(.fade(0.7))
                .set(to: imageView)
            
            break
        case is UIImage.Type:
            let image = item as! UIImage
            if image.isSymbolImage {
                let config = UIImage.SymbolConfiguration(pointSize: 45)
                imageView.contentMode = .center
                imageView.image = image.withConfiguration(config).withTintColor(.CustomColor.subTextColor, renderingMode: .alwaysOriginal)
            } else {
                imageView.contentMode = .scaleAspectFit
                imageView.image = image.resized(to: CGSize(width: 250, height: 250))
            }
        default:
            break
        }
    }
    
    func showView() {
        setupView()
        configureView()
        setupConstraints()
    }
}

extension ImageCollectionViewCell: ViewableProtocol {
    func setupView() {
        addSubview(imageView)
    }
    
    func configureView() {
        layer.cornerRadius = 20
        layer.masksToBounds = true
        backgroundColor = .darkGray
    }
    
    func setupConstraints() {
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

class CustomImageView: UIImageView {
    
    override var image: UIImage? {
        willSet {
            beginLoading()
        }
        didSet {
            endLoading()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func beginLoading() {
        let indicator = UIActivityIndicatorView()
        indicator.style = .medium
        indicator.color = .CustomColor.mainTextColor
        indicator.startAnimating()
        self.addSubview(indicator)
        indicator.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func endLoading() {
        self.subviews.forEach {
            let view = $0 as! UIActivityIndicatorView
            view.removeFromSuperview()
        }
    }
}
