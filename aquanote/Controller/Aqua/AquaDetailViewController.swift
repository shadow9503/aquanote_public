//
//  AquaDetailViewController.swift
//  aquanote
//
//  Created by 유영훈 on 2023/01/06.
//

import UIKit
import SnapKit
import TagListView
import Kingfisher

class AquaDetailViewController: UIViewController {
    
    var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.layer.zPosition = 0
        return view
    }()
    
    var containerStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 12
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Bottle")!.withTintColor(.CustomColor.subTextColor, renderingMode: .alwaysOriginal)
        view.contentMode = .scaleAspectFill
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    var titleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 4
        view.distribution = .fill
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        return view
    }()
    
    var knameLabel: UILabel = {
        let view = UILabel()
        view.text = "kname"
        view.font = .customFont(.bold, 22)
        view.textColor = .CustomColor.mainTextColor
//        view.backgroundColor = .red
        return view
    }()
    
    var enameLabel: UILabel = {
        let view = UILabel()
        view.text = "ename"
        view.font = .customFont(.regular, 18)
        view.textColor = .CustomColor.subTextColor
//        view.backgroundColor = .blue
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
        view.textColor = .CustomColor.lightgray
        view.numberOfLines = 0
//        view.backgroundColor = .cyan
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
    
    var informationSectionTitle: UILabel = {
        let view = UILabel()
        view.text = "정보"
        view.font = .customFont(.medium, 20)
        view.textColor = .CustomColor.mainTextColor
        return view
    }()
    
    var noteStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 8
        view.distribution = .fill
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    var noteSectionTitle: UILabel = {
        let view = UILabel()
        view.text = "테이스팅 노트"
        view.font = .customFont(.medium, 20)
        view.textColor = .CustomColor.mainTextColor
        return view
    }()
    
    var noteButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "NoteEdit")!, for: .normal)
        view.setImage(UIImage(named: "NoteEdit")!, for: .highlighted)
        view.layer.cornerRadius = 25
        view.layer.zPosition = 999
        view.layer.zPosition = 999
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSizeMake(1, 2)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 3
        return view
    }()
    
    var item: Aqua?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showView()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }
    
    @objc func swipeRight(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            popView()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        noteButton.backgroundColorWithGradient(colors: [.CustomColor.purple, .CustomColor.pink], bounds: nil, paintingDirection: .fromBottom)
    }
    
    func showView() {
        setNavigationBar()
        setupView()
        configureView()
        setupConstraints()
    }

    func setNavigationBar() {
//        navigationController?.navigationBar.tintColor = .CustomColor.mainTextColor
//        let menuButton = UIBarButtonItem(image: UIImage(named: "Menu")!.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
//        navigationItem.rightBarButtonItem = menuButton
        self.title = "주류 정보"
    }
    
    func addInformation(title: String, content: String) -> UIStackView {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 25
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .customFont(.medium, 15)
        titleLabel.textColor = .CustomColor.darkGray2
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = .customFont(.regular, 15)
        contentLabel.textColor = .CustomColor.lightgray
        view.addArrangedSubview(titleLabel)
        view.addArrangedSubview(contentLabel)
        return view
    }
    
    func addTastingNote(krTitle: String, enTitle: String, tags: [String]) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 6
        let titleWrapper = UIStackView()
        titleWrapper.axis = .horizontal
        titleWrapper.spacing = 6
        let enTitleLabel = UILabel()
        enTitleLabel.text = enTitle
        enTitleLabel.font = .customFont(.medium, 15)
        enTitleLabel.textColor = .CustomColor.darkGray2
        enTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        let krTitleLabel = UILabel()
        krTitleLabel.text = krTitle
        krTitleLabel.font = .customFont(.regular, 13)
        krTitleLabel.textColor = .CustomColor.lightgray
        krTitleLabel.textAlignment = .left
        titleWrapper.addArrangedSubview(enTitleLabel)
        titleWrapper.addArrangedSubview(krTitleLabel)
        let tagListView = TagListView()
        tagListView.tagBackgroundColor = .CustomColor.darkpurple
        tagListView.paddingX = 7.5
        tagListView.paddingY = 5
        tagListView.marginX = 7
        tagListView.marginY = 7
        tagListView.textColor = .CustomColor.mainTextColor
        tagListView.textFont = .CustomFont.sub1
        tags.forEach { tagListView.addTag($0) }
        tagListView.tagViews.forEach {
            $0.layer.cornerRadius = 11
            $0.layer.masksToBounds = true
        }
        
        container.addArrangedSubview(titleWrapper)
        container.addArrangedSubview(tagListView)
        
        return container
    }
    
    func addTag(_ tags: [String]) -> TagListView {
        let tagListView = TagListView()
        tagListView.addTags(tags)
        tagListView.tagBackgroundColor = .CustomColor.darkpurple
        tagListView.paddingX = 7.5
        tagListView.paddingY = 5
        tagListView.marginX = 7
        tagListView.marginY = 7
        tagListView.textColor = .CustomColor.mainTextColor
        tagListView.textFont = .CustomFont.sub1
        tagListView.tagViews.forEach {
            $0.layer.cornerRadius = 11
            $0.layer.masksToBounds = true
        }
        informationStack.addArrangedSubview(tagListView)
        return tagListView
    }
    
    @objc func goToWriting() {
        let vc = NoteInputViewController()
        vc.aqua = item
        pushView(vc)
    }
    
    deinit {
        print("deinit")
    }
}

extension AquaDetailViewController: ViewableProtocol {
    func setupView() {
        view.addSubview(scrollView)
        view.addSubview(noteButton)
        scrollView.addSubview(containerStack)
        
        let wrapper = UIStackView()
        wrapper.axis = .vertical
        wrapper.alignment = .leading
        wrapper.addArrangedSubview(imageView)
        
        [titleStack, wrapper, summaryStack, informationStack, noteStack].forEach {
            containerStack.addArrangedSubview($0)
        }

        [knameLabel, enameLabel].forEach {
            titleStack.addArrangedSubview($0)
        }

        [summarySectionTitle, summaryLabel].forEach {
            summaryStack.addArrangedSubview($0)
        }

        [informationSectionTitle].forEach {
            informationStack.addArrangedSubview($0)
        }
        
        [noteSectionTitle].forEach {
            noteStack.addArrangedSubview($0)
        }

        knameLabel.text = item?.kname ?? "-"
        enameLabel.text = item?.ename ?? "-"
        summaryLabel.text = item?.summary?.replacingOccurrences(of: "\\n", with: "\n") ?? ""
        
        [("국가", item?.nation ?? "-"),
         ("도수", item?.strength ?? "-"),
         ("종류", item?.category ?? "-"),
         ("숙성", item?.age != "NAS" ? "\(item?.age ?? "-") 년" : "NAS")].forEach {
            informationStack.addArrangedSubview(addInformation(title: $0.0, content: $0.1))
        }
        
        [("Nose", "향", item?.nose ?? ["태그 없음"]),
         ("Palate", "맛", item?.palate ?? ["태그 없음"]),
         ("Finish", "후향", item?.finish ?? ["태그 없음"])].forEach {
            noteStack.addArrangedSubview(addTastingNote(krTitle: $0.1, enTitle: $0.0, tags: $0.2))
        }
        
        if let urlString = item?.image {
            guard let url = URL(string: urlString) else { return }
            let deaultImage = UIImage(named: "Bottle_s")!
                .withTintColor(.CustomColor.subTextColor, renderingMode: .alwaysOriginal)
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
    
    func configureView() {
        view.backgroundColor = UIColor.CustomColor.backgroundColor
        noteButton.addTarget(self, action: #selector(goToWriting), for: .touchUpInside)
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.equalTo(safeArea)
            $0.leading.trailing.equalTo(safeArea).inset(20)
        }
        
        containerStack.snp.makeConstraints {
            $0.width.equalTo(scrollView)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
        }
        
        imageView.snp.makeConstraints {
            $0.height.equalTo(240)
            $0.width.equalToSuperview().multipliedBy(0.45)
        }
        
        noteButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(safeArea).inset(20)
            $0.size.equalTo(50)
        }
        
        noteStack.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.8)
        }
    }
}

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
