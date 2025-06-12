//
//  NoteDetailContentView.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/02.
//

import UIKit
import SnapKit
import TagListView
import Kingfisher

class NoteDetailContentView: UIView {
    
    var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.layer.zPosition = 0
        return view
    }()
    
    var containerStack: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 12
        return view
    }()
    
    var headerStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    var sayLabel: PaddingLabel = {
        let view = PaddingLabel(padding: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0))
        view.text = "\"제정신은 건강에 해로우니까.\""
        view.font = .customFont(.regular, 18)
        return view
    }()
    
    var sayWhoLabel: UILabel = {
        let view = UILabel()
        view.text = "by 남자의 취미"
        view.font = .customFont(.light, 14)
        return view
    }()
    
    var contentStack: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 18
        return view
    }()
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Bottle_s")!.withTintColor(.CustomColor.lightgray, renderingMode: .alwaysOriginal)
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    var titleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 13
        view.distribution = .fill
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    var addedOnLabel: PaddingLabel = {
        let view = PaddingLabel(padding: UIEdgeInsets(top: 0, left: 0, bottom: 7, right: 0))
        view.font = .customFont(.light, 14)
        view.textColor = .CustomColor.mainTextColor
        view.textAlignment = .right
        return view
    }()
    
    var titleLabel: UILabel = {
        let view = UILabel()
        view.text = "whiskey_name"
        view.numberOfLines = 0
        view.lineBreakMode = .byTruncatingMiddle
        view.font = .customFont(.bold, 22)
        view.textColor = .CustomColor.mainTextColor
//        view.backgroundColor = .red
        return view
    }()

    var summaryStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 13
        view.distribution = .fill
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    var summarySectionTitle: UILabel = {
        let view = UILabel()
        view.text = "소개"
        view.font = .customFont(.medium, 20)
        view.textColor = .CustomColor.mainTextColor
        return view
    }()
    
    var summaryLabel: UILabel = {
        let view = UILabel()
        view.text = ""
        view.font = .customFont(.regular, 15)
        view.textColor = .CustomColor.darkGray
        view.numberOfLines = 0
        return view
    }()
    
    var informationStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fill
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    var tagtitleLabel: PaddingLabel = {
        let view = PaddingLabel(padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        view.font = .CustomFont.subtitleM
        view.text = "테이스팅 태그"
        view.textColor = .CustomColor.mainTextColor
        return view
    }()
    
    var tagListView: TagListView = {
        let view = TagListView()
        view.tagBackgroundColor = .CustomColor.darkpurple
        view.paddingX = 7.5
        view.paddingY = 5
        view.marginY = 7
        view.textColor = .white
        view.textFont = .CustomFont.sub1
        view.cornerRadius = 11
        view.clipsToBounds = true
        view.addTag("태그 없음")
        return view
    }()
    
    var detailNoteLabel: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
//        view.spacing = 6
//        let image = UIImageView()
//        image.image = UIImage(named: "Editline")!
//        image.contentMode = .bottomLeft
        let label = PaddingLabel(padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        label.font = .CustomFont.subtitleM
        label.text = "상세 노트"
        let flexibleView = UIView()
        flexibleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.textColor = .CustomColor.mainTextColor
//        view.addArrangedSubview(image)
        view.addArrangedSubview(label)
        view.addArrangedSubview(flexibleView)
        return view
    }()
    
    var noseStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var noseInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "Nose 향"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var noseInput: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = .CustomFont.base
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.textColor = .CustomColor.mainTextColor //.CustomColor.darkGray
        view.backgroundColor = .CustomColor.backgroundColor//.CustomColor.lightgray
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        return view
    }()
    
    var palateStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var palateInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "Palate 맛"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var palateInput: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = .CustomFont.base
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.textColor = .CustomColor.mainTextColor //.CustomColor.darkGray
        view.backgroundColor = .CustomColor.backgroundColor//.CustomColor.lightgray
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        return view
    }()
    
    var finishStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var finishInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "Finish 후향"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var finishInput: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = .CustomFont.base
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.textColor = .CustomColor.mainTextColor //.CustomColor.darkGray
        view.backgroundColor = .CustomColor.backgroundColor//.CustomColor.lightgray
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        return view
    }()
    
    var commentStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var commentInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "코멘트"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var commentInput: UITextView = {
        let view = UITextView()
        view.isEditable = false
        view.font = .CustomFont.base
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.textColor = .CustomColor.mainTextColor //.CustomColor.darkGray
        view.backgroundColor = .CustomColor.backgroundColor//.CustomColor.lightgray
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        return view
    }()
    
    func wrappingByStackView(subViews: [UIView], margins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), axis: NSLayoutConstraint.Axis = .horizontal, spacing: CGFloat = 0) -> UIStackView {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = margins
        view.axis = axis
        view.spacing = spacing
        subViews.forEach {
            view.addArrangedSubview($0)
        }
        return view
    }
    
    func addInformation(title: String, content: String?) -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 25
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .customFont(.medium, 15)
        titleLabel.textColor = .CustomColor.darkGray2
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.addArrangedSubview(titleLabel)
        
        let content = content ?? ""
        let contentLabel = UILabel()
        
        switch title {
        case "도수":
            contentLabel.text = content.isEmpty ? "-" : "\(content) %"
        case "숙성":
            contentLabel.text = content.isEmpty ? "-" : "\(content) 년"
        case "가격":
            contentLabel.text = content.isEmpty ? "-" : "\(content) 원"
        default:
            contentLabel.text = content.isEmpty ? "-" : content
        }
        contentLabel.font = .customFont(.regular, 15)
        contentLabel.textColor = .CustomColor.lightgray
        view.addArrangedSubview(contentLabel)
        return view
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        showView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showView() {
        setupView()
        setupConstraints()        
    }
    
    func fill(item: Note) {
        [("국가", item.nation),
         ("도수", item.strength),
         ("종류", item.category),
         ("숙성", item.age),
         ("가격", item.price?.toDecimal()),
         ("시음", item.tastingDate?.toKRString(format: .kr))].forEach {
            informationStack.addArrangedSubview(
                addInformation(title: $0.0, content: $0.1))
        }
        
        titleLabel.text = item.title
        noseInput.text = item.nose
        palateInput.text = item.palate
        finishInput.text = item.finish
        commentInput.text = item.comment
        addedOnLabel.text = "\(item.addedOn!.toKRString(format: .simple)) 작성됨"
        
        if let tags = item.tags {
            if !tags.isEmpty {
                tagListView.removeAllTags()
                tags.forEach { tagListView.addTag($0) }
            }
        }
     
        if let urlString = item.images?.first {
            guard let url = URL(string: urlString) else { return }
            let deaultImage = UIImage(named: "Bottle_s")!
                .withTintColor(.CustomColor.lightgray, renderingMode: .alwaysOriginal)
            let processor = DownsamplingImageProcessor(
                size: CGSize(width: 700, height: 700))
            imageView.kf.indicatorType = .activity
            
            KF.url(url)
                .setProcessor(processor)
                .placeholder(deaultImage)
                .retry(maxCount: 2, interval: .seconds(4))
                .transition(.fade(0.7))
                .set(to: imageView)
        }
    }
    
    override func layoutSubviews() {
        titleStack.useBottomLine()
    }
}

extension NoteDetailContentView: ViewableProtocol {
    func setupView() {
        addSubview(scrollView)
        scrollView.addSubview(containerStack)
        
        [headerStack, contentStack].forEach {
            containerStack.addArrangedSubview($0)
        }
        
        [sayLabel,
         sayWhoLabel,
         addedOnLabel,
         wrappingByStackView(subViews: [imageView])].forEach {
            headerStack.addArrangedSubview($0)
        }
        
        let detailNoteStack = wrappingByStackView(subViews: [detailNoteLabel, noseStack, palateStack, finishStack], axis: .vertical, spacing: 18)
        let tagStack = wrappingByStackView(subViews: [tagtitleLabel, tagListView], axis: .vertical, spacing: 10)
        
        [titleStack,
         informationStack,
         tagStack,
         detailNoteStack,
         commentStack].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        [titleLabel].forEach {
            titleStack.addArrangedSubview($0)
        }
        
        [noseInputLabel, noseInput].forEach {
            noseStack.addArrangedSubview($0)
        }
        
        [palateInputLabel, palateInput].forEach {
            palateStack.addArrangedSubview($0)
        }
        
        [finishInputLabel, finishInput].forEach {
            finishStack.addArrangedSubview($0)
        }
        
        [commentInputLabel, commentInput].forEach {
            commentStack.addArrangedSubview($0)
        }
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.equalTo(safeArea)
            $0.leading.trailing.equalTo(safeArea).inset(20)
        }
        
        containerStack.snp.makeConstraints {
            $0.width.equalTo(scrollView)
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(50)
        }

        imageView.snp.makeConstraints {
            $0.height.equalTo(240)
            $0.width.equalToSuperview().multipliedBy(0.45)
        }
        
        tagListView.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
        
        noseInput.snp.makeConstraints {
            $0.height.equalTo(170)
        }
        
        palateInput.snp.makeConstraints {
            $0.height.equalTo(170)
        }
        
        finishInput.snp.makeConstraints {
            $0.height.equalTo(170)
        }
        
        commentInput.snp.makeConstraints {
            $0.height.equalTo(100)
        }
        
        headerStack.setCustomSpacing(10, after: sayWhoLabel)
        headerStack.setCustomSpacing(10, after: imageView)
    }
}

extension UIView {
    func useBottomLine() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0) // Border Width
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y : (self.frame.size.height + 6) - (borderWidth)), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
