//
//  NoteListContentView.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/12.
//

import UIKit
import SnapKit

class NoteListContentView: UIView {
    
    var containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    var checkButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "checkmark.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), for: .selected)
        view.setImage(UIImage(systemName: "checkmark.circle")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal), for: .normal)
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var firstRowView: UIView = {
        let view = UIView()
        view.layer.masksToBounds = true
        return view
    }()
    
    var secondRowView: UIView = {
        let view = UIView()
        return view
    }()
    
//    var backupStatusView: UIImageView = {
//        let view = UIImageView()
//        view.image = UIImage(systemName: "xmark.icloud.fill")
//        view.contentMode = .scaleAspectFit
//        view.isHidden = true
//        return view
//    }()
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .darkGray
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        view.image = UIImage(named: "Bottle")!
            .withTintColor(.CustomColor.subTextColor, renderingMode: .alwaysOriginal)
        return view
    }()
    
    var detailStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fill
        return view
    }()
    
    var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.textColor = .CustomColor.mainTextColor
        return view
    }()
    
    var commentLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.sub2
        view.textColor = .CustomColor.subTextColor
        view.numberOfLines = 2
        view.textAlignment = .left
        return view
    }()
    
    var categoryLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.sub2
        view.textColor = .CustomColor.mainTextColor
        return view
    }()
    
    var flexibleView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        showView()
    }
    
    func showView() {
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteListContentView: ViewableProtocol {
    func setupView() {
        self.addSubview(containerView)
        [checkButton, firstRowView, secondRowView].forEach {
            containerView.addArrangedSubview($0)
        }
        firstRowView.addSubview(imageView)
//        imageView.addSubview(backupStatusView)
        secondRowView.addSubview(detailStack)
        [titleLabel, categoryLabel, commentLabel].forEach {
            detailStack.addArrangedSubview($0)
        }
    }
    
    func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        checkButton.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0)
        }
        
        firstRowView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.275)
        }
        
//        backupStatusView.snp.makeConstraints {
////            $0.top.equalToSuperview().inset(2)
////            $0.trailing.equalToSuperview().inset(7)
//            $0.top.leading.equalToSuperview().inset(6)
//            $0.width.height.equalTo(12)
//        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(70)
            $0.center.equalToSuperview()
        }
        
        detailStack.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview()
        }
        
        commentLabel.snp.makeConstraints {
            $0.height.equalTo(categoryLabel.snp.height).multipliedBy(2.0)
        }
    }
}
