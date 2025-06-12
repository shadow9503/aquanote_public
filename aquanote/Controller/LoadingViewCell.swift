//
//  LoadingViewCell.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/21.
//

import UIKit
import SnapKit

class LoadingViewCell: UITableViewCell {
    static let identifier = "LoadingViewCell"
    
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .medium
        view.tintColor = .CustomColor.lightgray
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .CustomColor.backgroundColor
        selectionStyle = .none
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func stopLoading() {
        loadingIndicator.stopAnimating()
    }
    
    func startLoading() {
        loadingIndicator.startAnimating()
    }
}

extension LoadingViewCell: ViewableProtocol {
    func setupView() {
        self.addSubview(loadingIndicator)
    }
    
    func setupConstraints() {
        loadingIndicator.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
