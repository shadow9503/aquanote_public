//
//  AquaListContentView.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/14.
//

import UIKit
import SnapKit
import TagListView

class AquaListContentView: UIView {
    
    var containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    var firstRowView: UIView = {
        let view = UIView()
        return view
    }()
    
    var secondRowView: UIView = {
        let view = UIView()
        return view
    }()
    
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
    
    var knameLabel: PaddingLabel = {
        let view = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0))
        view.font = .CustomFont.baseM
        view.textColor = .CustomColor.mainTextColor
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    // TODO: 들어갈 컨텐츠 정하기
    var enameLabel: PaddingLabel = {
        let view = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 0))
        view.font = .CustomFont.sub2
        view.textColor = .CustomColor.subTextColor
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    var categoryLabel: PaddingLabel = {
        let view = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 3, bottom: 3, right: 0))
        view.font = .CustomFont.sub2
        view.textColor = .CustomColor.mainTextColor
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    lazy var tagListView: TagListView = {
        let view = TagListView()
        view.tagBackgroundColor = .CustomColor.darkpurple
        view.paddingX = 5.5
        view.paddingY = 3
        view.textColor = .CustomColor.mainTextColor
        view.textFont = .CustomFont.sub2M
        view.cornerRadius = 9.5
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AquaListContentView: ViewableProtocol {
    func setupView() {
        self.addSubview(containerView)
        [firstRowView, secondRowView].forEach {
            containerView.addArrangedSubview($0)
        }
        firstRowView.addSubview(imageView)
        secondRowView.addSubview(detailStack)
        
        let flexibleView = UIView()
        flexibleView.setContentHuggingPriority(.defaultLow, for: .vertical)
        [knameLabel, enameLabel, categoryLabel, flexibleView, tagListView].forEach {
            detailStack.addArrangedSubview($0)
        }
    }
    
    func setupConstraints() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        firstRowView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.275)
        }
        
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(75)
            $0.center.equalToSuperview()
        }
        
        detailStack.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.equalToSuperview()
        }
        
        tagListView.snp.makeConstraints {
            $0.height.equalTo(18)
        }
    }
}
        
extension TagListView {
    func addTags(tags: [String]) {
        tags.forEach {
            self.addTag($0)
        }
    }
}
