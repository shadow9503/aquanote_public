//
//  NoteInputViewController.swift
//  aquanote
//
//  Created by 유영훈 on 2023/01/14.
//

import UIKit
import SnapKit
import PhotosUI
import TagListView
import Kingfisher
import FirebaseFirestore

class NoteInputViewController: UIViewController, AppleLoginServiceDelegate {
    
    var presenter: NoteInputViewPresenter!
    var appleLoginService: AppleLoginService!
    var aqua: Aqua?
    var note: Note?
    
    var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.layer.zPosition = 0
//        view.decelerationRate = .fast
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
    
    var titleStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var titleInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "제목"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var titleInput: PaddingTextField = {
        let view = PaddingTextField(padding: UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.attributedPlaceholder = NSAttributedString(string: "노트 제목", attributes: [.foregroundColor : UIColor(named: "PlaceHolder")!])
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        return view
    }()
    
    var imageCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        view.backgroundColor = .CustomColor.backgroundColor
        return view
    }()
    
    var imageAddButton: UIButton = {
        let view = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "plus")?.withConfiguration(config)
        view.setImage(image!.withTintColor(.CustomColor.backgroundColor, renderingMode: .alwaysOriginal), for: .highlighted)
        view.setImage(image!.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), for: .normal)
        return view
    }()
    
    var imageRemoveButton: UIButton = {
        let view = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "minus")?.withConfiguration(config)
        view.setImage(image!.withTintColor(.CustomColor.backgroundColor, renderingMode: .alwaysOriginal), for: .highlighted)
        view.setImage(image!.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), for: .normal)
        return view
    }()
    
    var imageStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var imageViewLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "이미지"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var imageViewContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    var dateStack: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var dateInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "테이스팅 날짜"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var dateInput: PaddingTextField = {
        let view = PaddingTextField(padding: UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.attributedPlaceholder = NSAttributedString(string: "1995년 03월 03일", attributes: [.foregroundColor : UIColor(named: "PlaceHolder")!])
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        
        let keyboardAccessoryView = UIToolbar()
        keyboardAccessoryView.sizeToFit()
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: #selector(didSelectDate))
        keyboardAccessoryView.items = [flexibleButton, doneButton]
        keyboardAccessoryView.tintColor = .CustomColor.mainTextColor
        view.inputAccessoryView = keyboardAccessoryView
        return view
    }()
    
//    var calendarButton: UIButton = {
//        let view = UIButton()
//        view.setImage(UIImage(named: "Calendar")!, for: .normal)
//        return view
//    }()
    
    var nationStack: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var nationInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "국가"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var nationInput: PaddingTextField = {
        let view = PaddingTextField(padding: UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.attributedPlaceholder = NSAttributedString(string: "생산지국가", attributes: [.foregroundColor : UIColor(named: "PlaceHolder")!])
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        return view
    }()
    
    var categoryStack: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var categoryInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "종류"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var categoryInput: PaddingTextField = {
        let view = PaddingTextField(padding: UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.attributedPlaceholder = NSAttributedString(string: "싱글몰트", attributes: [.foregroundColor : UIColor(named: "PlaceHolder")!])
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        return view
    }()
    
    var strengthStack: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var strengthInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "도수"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var strengthInput: PaddingTextField = {
        let view = PaddingTextField(padding: UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.attributedPlaceholder = NSAttributedString(string: "", attributes: [.foregroundColor : UIColor(named: "PlaceHolder")!])
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        view.keyboardType = .numberPad
        return view
    }()
    
    var ageStack: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var ageInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "숙성기간"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var ageInput: PaddingTextField = {
        let view = PaddingTextField(padding: UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.attributedPlaceholder = NSAttributedString(string: "", attributes: [.foregroundColor : UIColor(named: "PlaceHolder")!])
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        view.keyboardType = .numberPad
        return view
    }()
    
    var ageSegment: UISegmentedControl = {
        let view = UISegmentedControl()
        view.insertSegment(withTitle: "직접입력", at: 0, animated: true)
        view.insertSegment(withTitle: "NAS", at: 1, animated: true)
        view.selectedSegmentIndex = 0
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.addTarget(nil, action: #selector(didChangeSegment), for: .valueChanged)
        return view
    }()
    
    var priceStack: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var priceInputLabel: UILabel = {
        let view = UILabel()
        view.font = .CustomFont.baseM
        view.text = "가격"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var priceInput: PaddingTextField = {
        let view = PaddingTextField(padding: UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.attributedPlaceholder = NSAttributedString(string: "", attributes: [.foregroundColor : UIColor(named: "PlaceHolder")!])
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        view.keyboardType = .numberPad
        return view
    }()
    
    var tagTitleLabel: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 6
//        let image = UIImageView()
//        image.image = UIImage(systemName: "tag")
//        image.contentMode = .bottomLeft
        let label = PaddingLabel(padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        label.font = .CustomFont.subtitleM
        label.text = "테이스팅 태그"
        let flexibleView = UIView()
        flexibleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.textColor = .CustomColor.mainTextColor
//        view.addArrangedSubview(image)
        view.addArrangedSubview(label)
        view.addArrangedSubview(flexibleView)
        return view
    }()
    
    var tagCountLabel: PaddingLabel = {
        let view = PaddingLabel(padding: UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0))
        view.text = "0 / 10"
        return view
    }()
    
    lazy var tagInput: PaddingTextField = {
        let view = PaddingTextField(padding: UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.attributedPlaceholder = NSAttributedString(string: "추가할 태그명 입력", attributes: [.foregroundColor : UIColor(named: "PlaceHolder")!])
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        
        let keyboardAccessoryView = UIToolbar()
        keyboardAccessoryView.sizeToFit()
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let removeButton = UIBarButtonItem(title: "삭제", style: .plain, target: nil, action: #selector(removeTag))
        removeButton.tintColor = .systemRed
        let doneButton = UIBarButtonItem(title: "추가", style: .plain, target: nil, action: #selector(addTag))
        doneButton.tintColor = .CustomColor.mainTextColor
        keyboardAccessoryView.items = [flexibleButton, removeButton, doneButton]
        view.inputAccessoryView = keyboardAccessoryView
        return view
    }()
    
    var addTagButton: UIButton = {
        let view = UIButton()
        view.contentHorizontalAlignment = .leading
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "plus")?.withConfiguration(config)
        view.setImage(image!.withTintColor(.CustomColor.backgroundColor, renderingMode: .alwaysOriginal), for: .highlighted)
        view.setImage(image!.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), for: .normal)
        return view
    }()
    
    var removeTagButton: UIButton = {
        let view = UIButton()
        view.contentHorizontalAlignment = .leading
        let config = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "minus")?.withConfiguration(config)
        view.setImage(image!.withTintColor(.CustomColor.backgroundColor, renderingMode: .alwaysOriginal), for: .highlighted)
        view.setImage(image!.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), for: .normal)
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
        return view
    }()
    
    var detailNoteLabel: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 6
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
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        
//        let keyboardAccessoryView = UIToolbar()
//        keyboardAccessoryView.sizeToFit()
//        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: #selector(dismissKeyboard))
//        keyboardAccessoryView.items = [flexibleButton, doneButton]
//        keyboardAccessoryView.tintColor = .purple
//        view.inputAccessoryView = keyboardAccessoryView
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
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.mainTextColor.withAlphaComponent(0.75).cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        
//        let keyboardAccessoryView = UIToolbar()
//        keyboardAccessoryView.sizeToFit()
//        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: #selector(dismissKeyboard))
//        keyboardAccessoryView.items = [flexibleButton, doneButton]
//        keyboardAccessoryView.tintColor = .purple
//        view.inputAccessoryView = keyboardAccessoryView
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
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        
//        let keyboardAccessoryView = UIToolbar()
//        keyboardAccessoryView.sizeToFit()
//        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
//        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: #selector(dismissKeyboard))
//        keyboardAccessoryView.items = [flexibleButton, doneButton]
//        keyboardAccessoryView.tintColor = .purple
//        view.inputAccessoryView = keyboardAccessoryView
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
        view.text = "코멘트 (목록에 보여짐)"
        view.textColor = .CustomColor.darkGray2
        return view
    }()
    
    var commentInput: UITextView = {
        let view = UITextView()
        view.font = .CustomFont.base
        view.autocorrectionType = .no
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.layer.borderWidth = 1
        view.textColor = .CustomColor.mainTextColor
        view.backgroundColor = .CustomColor.backgroundColor
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        return view
    }()
    
    var saveButton: PaddingButton = {
        let view = PaddingButton(padding: UIEdgeInsets(top: 5, left: 22, bottom: 5, right: 22))
        view.setTitle("작성 완료", for: .normal)
        view.titleLabel!.font = .CustomFont.baseM
        view.backgroundColor = .CustomColor.purple
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setBlur(style: .systemChromeMaterialDark) { blurView in }
        showView()
    }
    
    deinit {
        print("deinit")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.view.removeBlur()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeNotifications()
        presenter = nil
    }
    
    func showView() {
        presenter = NoteInputViewPresenter(delegate: self)
        appleLoginService = AppleLoginService()
        appleLoginService.setAppleLoginPresentationAnchorView(self)
        appleLoginService.delegate = self
        setNavigationBar()
        setupView()
        configureView()
        setupConstraints()
    }
    
    func setNavigationBar() {
        navigationController?.navigationBar.tintColor = .CustomColor.mainTextColor
        let cancelButton = UIButton()
        cancelButton.setImage(UIImage(systemName: "xmark.circle.fill")!
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 24))
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal), for: .normal)
        cancelButton.addTarget(self, action: #selector(moveToPrevious), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancelButton)
        
        self.title = "노트 작성"
    }
    
    func setNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }
    
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func moveToPrevious() {
        let actions = [
            UIAlertAction(title: "확인", style: .destructive)
            { [weak self] _ in
                guard let self = self else { return }
                self.popView(animated: true)
            },
            UIAlertAction(title: "취소", style: .cancel)
        ]
        
        let alert = newAlertController(title: "알림", message: "작성중인 노트가 삭제돼요!\n취소할까요?", actions: actions)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func createFlexibleView(axis: NSLayoutConstraint.Axis = .horizontal) -> UIView {
        let view = UIView()
        view.setContentHuggingPriority(.defaultLow, for: axis)
        return view
    }
}

extension NoteInputViewController: ViewableProtocol {
    
    func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerStack)
        
        [headerStack, contentStack].forEach {
            containerStack.addArrangedSubview($0)
        }
        
        [sayLabel, sayWhoLabel].forEach {
            headerStack.addArrangedSubview($0)
        }
        
        let tagTitleStack = wrappingByStackView(subViews: [tagTitleLabel, tagCountLabel])
        let tagButtonStack = wrappingByStackView(subViews: [tagInput, addTagButton, removeTagButton, createFlexibleView()], spacing: 10)
        let tagListViewWrapper = wrappingByStackView(subViews: [tagListView])
        let tagStack = wrappingByStackView(subViews: [tagTitleStack, tagButtonStack, tagListViewWrapper], axis: .vertical, spacing: 17)
        
        let imageViewLabelStack = wrappingByStackView(subViews: [imageViewLabel, createFlexibleView(), imageAddButton, imageRemoveButton], spacing: 10)

        [titleStack, imageStack, dateStack, nationStack, categoryStack, strengthStack, ageStack, priceStack, tagStack, detailNoteLabel, noseStack, palateStack, finishStack, commentStack, saveButton].forEach {
            contentStack.addArrangedSubview($0)
        }
        
        [commentInputLabel, commentInput].forEach {
            commentStack.addArrangedSubview($0)
        }
        
        [titleInputLabel, titleInput].forEach {
            titleStack.addArrangedSubview($0)
        }
        
        [imageViewLabelStack, imageCollectionView].forEach {
            imageStack.addArrangedSubview($0)
        }

        [dateInputLabel, dateInput].forEach {
            dateStack.addArrangedSubview($0)
        }

        [nationInputLabel, nationInput].forEach {
            nationStack.addArrangedSubview($0)
        }

        [categoryInputLabel, categoryInput].forEach {
            categoryStack.addArrangedSubview($0)
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

        [strengthInputLabel, strengthInput].forEach {
            strengthStack.addArrangedSubview($0)
        }

        [ageInputLabel, ageInput].forEach {
            ageStack.addArrangedSubview($0)
        }

        [priceInputLabel, priceInput].forEach {
            priceStack.addArrangedSubview($0)
        }
        
        if let aqua = aqua {
            titleInput.text = "\(aqua.kname!)"
            dateInput.text = Date().toKRString()
            nationInput.text = aqua.nation
            categoryInput.text = aqua.category
            ageInput.text = aqua.age
            strengthInput.text = aqua.strength
            ageSegment.selectedSegmentIndex = aqua.age == "NAS" ? 1 : 0
            
            guard let image = aqua.image else {
                presenter.initImageCollectionView()
                return
            }
            
            self.presenter.addImage(image)
            
        } else if let note = note {
            titleInput.text = "\(note.title!)"
            presenter.needImageUpdate = false
            dateInput.text = note.tastingDate?.toKRString(format: .kr)
            nationInput.text = note.nation
            categoryInput.text = note.category
            ageInput.text = note.age
            strengthInput.text = note.strength
            priceInput.text = note.price?.toDecimal()
            ageSegment.selectedSegmentIndex = note.age == "NAS" ? 1 : 0
            noseInput.text = note.nose
            palateInput.text = note.palate
            finishInput.text = note.finish
            commentInput.text = note.comment
            
            if let tags = note.tags {
                tags.forEach { tagListView.addTag($0) }
                tagCountLabel.text = "\(tags.count) / 10"
            }
            
            if let images = note.images {
                presenter.uploadedUrls = images
                images.forEach {
                    self.presenter.addImage($0)
                }
                if images.isEmpty {
                    presenter.initImageCollectionView()
                }
            } else {
                presenter.initImageCollectionView()
            }
        } else {
            presenter.initImageCollectionView()
        }
    }
    
    func configureView() {
        view.backgroundColor = .CustomColor.backgroundColor

        noseInput.delegate = self
        palateInput.delegate = self
        finishInput.delegate = self
        scrollView.delegate = self
        nationInput.delegate = self
        strengthInput.delegate = self
        ageInput.delegate = self
        categoryInput.delegate = self
        tagInput.delegate = self
        priceInput.delegate = self
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self

        
        let datePicker = UIDatePicker(frame: .zero)
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko_kr")
        dateInput.inputView = datePicker
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        addTagButton.addTarget(self, action: #selector(addTag), for: .touchUpInside)
        removeTagButton.addTarget(self, action: #selector(removeTag), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonPressed), for: .touchUpInside)
        imageAddButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        imageRemoveButton.addTarget(self, action: #selector(deleteImage), for: .touchUpInside)
        
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.equalTo(safeArea)
            $0.leading.trailing.equalTo(safeArea).inset(20)
        }
        
        containerStack.snp.makeConstraints {
            $0.width.equalTo(scrollView)
            $0.top.equalTo(scrollView)
            $0.leading.trailing.equalTo(scrollView)
            $0.bottom.equalTo(scrollView).inset(50)
        }
        
        dateStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: view.frame.width*0.5)
        nationStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: view.frame.width*0.4)
        categoryStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: view.frame.width*0.4)
        strengthStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: view.frame.width*0.6)
        ageStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: view.frame.width*0.6)
        priceStack.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: view.frame.width*0.5)

        tagInput.snp.makeConstraints {
            $0.width.equalToSuperview().multipliedBy(0.7)
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
        
        imageCollectionView.snp.makeConstraints {
            let itemWidth = (self.view.frame.width - (60 + 40)) / 3
            $0.height.equalTo(itemWidth)
        }
        
        contentStack.setCustomSpacing(10, after: detailNoteLabel)
        
//        calendarButton.snp.makeConstraints {
//            $0.trailing.equalTo(dateStack).offset(30)
//            $0.centerY.equalTo(dateInput)
//        }
    }
}

extension NoteInputViewController {
    
    @objc func addImage() {
        showPhotoPicker()
    }
    
    @objc func deleteImage() {
        presenter.deleteImage()
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        
        let responders = [titleInput, dateInput, ageInput, nationInput, strengthInput, categoryInput, tagInput, priceInput, noseInput, palateInput, finishInput, commentInput].filter {
            $0.isFirstResponder
        }
        
        if let firstResponder = responders.first {
            if let textView = firstResponder as? UITextView {
                scrollView.contentInset.bottom = keyboardFrame.size.height
                let targetFrame = textView.superview!.frame
                if textView == commentInput {
                    let detinationFrame = CGRect(x: 0, y: targetFrame.maxY + 30, width: targetFrame.width, height: targetFrame.height)
                    scrollView.scrollRectToVisible(detinationFrame, animated: false)
                } else {
                    let detinationFrame = CGRect(x: 0, y: targetFrame.midY + 30, width: targetFrame.width, height: targetFrame.height)
                    scrollView.scrollRectToVisible(detinationFrame, animated: false)
                }
            } else {
                scrollView.contentInset.bottom = keyboardFrame.size.height + 120
            }
        }
    }

    @objc private func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc func didSelectDate() {
        let datePicker = dateInput.inputView as! UIDatePicker
        dateInput.text = datePicker.date.toKRString()
        dismissKeyboard()
    }
    
    @objc func didChangeSegment(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            ageInput.text = ""
            ageInput.isEnabled = true
            ageInput.textColor = .CustomColor.mainTextColor
            ageInput.becomeFirstResponder()
            break
        case 1:
            ageInput.text = "NAS"
            ageInput.isEnabled = false
            ageInput.textColor = .lightGray
            break
        default:
            break
        }
    }
    
    @objc func addTag() {
        guard let text = tagInput.text else { return }
        let tagName = text.trimmingCharacters(in: .whitespaces)
        if tagName.isEmpty { return }
        let tagCount = tagListView.tagViews.count
        if tagCount > 9 { return }
        tagCountLabel.text = "\(tagCount + 1) / 10"
        tagListView.addTag(tagName)
        tagInput.text = ""
    }
    
    @objc func removeTag() {
        guard let tag = tagListView.tagViews.last else { return }
        tagCountLabel.text = "\(tagListView.tagViews.count - 1) / 10"
        tagListView.removeTagView(tag)
    }
    
    func needNetworkConnection() {
        let actions = [
            UIAlertAction(title: "확인", style: .cancel)
            { _ in
                self.scrollView.scrollRectToVisible(self.imageCollectionView.frame, animated: true)
            }
        ]
        let alert = newAlertController(title: "알림", message: "네트워크 연결에 문제가있어요\n이미지를 제거 혹은 네트워크를 확인 해주세요", actions: actions)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    @objc func saveButtonPressed() {
        if !NetworkMonitor.shared.isConnected && !presenter.willUploadImages.isEmpty {
            needNetworkConnection()
        } else {
            let actions = [
                UIAlertAction(title: "확인", style: .destructive)
                { [weak self] action in
                    guard let self = self else { return }
                    self.view.setBlur(style: .systemChromeMaterialDark)
                    if self.presenter.needImageUpdate {
                        // after trigger saveNote
                        self.presenter.uploadImages()
                    } else {
                        // directly save note
                        self.saveNote()
                    }
                },
                UIAlertAction(title: "취소", style: .cancel)
            ]
            
            let alert = newAlertController(title: "알림", message: "작성된 내용을 저장할까요?", actions: actions)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        }
    }
    
    func saveNote(_ willUploadImageUrls: [String] = []) {
        DispatchQueue.main.async {
            // validation
            guard let title = self.titleInput.text else { return }
            if title.isEmpty {
                self.view.removeBlur()
                self.titleInput.becomeFirstResponder()
                self.toast.pop("제목은 필수입니다.")
                return
            }
            
            // create model
            let tags = self.tagListView.tagViews.map { return $0.titleLabel!.text }
            var note = NoteModel(
                uid: self.note?.uid ?? (UserDefaults.standard.string(forKey: "userid") ?? ""),
                uuid: self.note?.uuid ?? UUID(),
                addedOn: self.note?.addedOn ?? Date(),
                editedOn: self.note?.editedOn,
                title: title,
                images: [],
                tastingDate: self.dateInput.text?.toDate(format: .kr),
                nation: self.nationInput.text,
                category: self.categoryInput.text,
                strength: self.strengthInput.text?.split(separator: " ").first?.description,
                age: self.ageInput.text,
                price: self.priceInput.text?.toNumber(),
                tags: tags as? [String] ?? [],
                nose: self.noseInput.text,
                palate: self.palateInput.text,
                finish: self.finishInput.text,
                comment: self.commentInput.text,
                etc: "",
                isBackup: false
            )
            
            if self.presenter.needImageUpdate {
                note.images = self.presenter.willUploadImageUrls
            } else {
                note.images = self.presenter.uploadedUrls.isEmpty ? self.note?.images : self.presenter.uploadedUrls
            }
            
            self.appleLoginService.checkLoginSession { status in
                guard let _ = self.note?.uuid else {
                    self.presenter.createNote(note: note, backup: status == .valid)
                    return
                }
                self.presenter.updateNote(note: note, backup: status == .valid)
            }
        }
    }
}

extension NoteInputViewController: NoteInputViewDelegate {
    func toastMessage(_ message: String) {
        self.toast.pop(message)
    }
    
    func didAddedImage(_ ifFullOfImage: Bool) {
        DispatchQueue.main.async {
            self.imageAddButton.isHidden = ifFullOfImage
            self.imageRemoveButton.isHidden = !ifFullOfImage
        }
    }
    
    func didRemovedImages() {
        DispatchQueue.main.async {
            self.imageAddButton.isHidden = false
            self.imageRemoveButton.isHidden = true
        }
    }
    
    
    func updateItems() {
        DispatchQueue.main.async {
            self.imageCollectionView.reloadData()
        }
    }
    
    func didFinishedUpdate() {
        DispatchQueue.main.async {
            let noteListVC = self.navigationController!.viewControllers.first as! NoteListViewController
            noteListVC.presenter.refreshList()
            self.setView(noteListVC)
        }
    }
    
    func didFinishedCreate() {
        DispatchQueue.main.async {
            let noteListVC = self.navigationController!.viewControllers.first as! NoteListViewController
            noteListVC.presenter.createdNote()
            self.setView(noteListVC)
        }
    }
    
    func didSuccessUpload() {
        //
    }
    
    func didFailedUplaod() {
        DispatchQueue.main.async {
            self.view.removeBlur()
            self.toast.pop("이미지 업데이트에 실패했어요.")
        }
    }
    
    func didSuccessFetch() {
        //
    }
    
    func didFailedFetch() {
        toast.pop("일부 내용을 불러오는데 실패했어요")
    }
}

extension NoteInputViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // single image picker
        picker.dismiss(animated: true)
        self.view.removeBlur()
        let result = results.first?.itemProvider
        guard let _ = result?.canLoadObject(ofClass: UIImage.self) else {
            self.toast("이미지를 불러오는데 실패했어요")
            return
        }
        
        result?.loadObject(ofClass: UIImage.self, completionHandler: { [weak self] image, error in
            guard let self = self else { return }
            guard let img = image else {
                self.toast("이미지를 불러오는데 실패했어요")
                return
            }
            self.presenter.addImage(img as! UIImage)
        })
    }
    
    @objc func showPhotoPicker() {
        self.view.setBlur(style: .systemChromeMaterialDark) { blurView in }
        var photoPickerViewConfig = PHPickerConfiguration()
        photoPickerViewConfig.filter = .images
        photoPickerViewConfig.preferredAssetRepresentationMode = .current
//        photoPickerViewConfig.selection = .default
        photoPickerViewConfig.selectionLimit = 1
        let photoPickerVC = PHPickerViewController(configuration: photoPickerViewConfig)
        photoPickerVC.modalPresentationStyle = .overCurrentContext 
        photoPickerVC.delegate = self
        present(photoPickerVC, animated: true)
    }
}

extension NoteInputViewController: UITextFieldDelegate, UITextViewDelegate, UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let targetFrame = textView.superview!.frame
        let scrollOffestY = scrollView.contentOffset.y
        
        if scrollOffestY > targetFrame.minY {
            UIView.animate(withDuration: 0.15, delay: 0) {
                self.scrollView.contentOffset = CGPoint(x: 0, y: targetFrame.minY - 100)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let targetFrame = textField != tagInput ? textField.superview!.frame : textField.superview!.superview!.frame
        let scrollOffestY = scrollView.contentOffset.y
        if scrollOffestY > targetFrame.minY {
            UIView.animate(withDuration: 0.15, delay: 0) {
                self.scrollView.contentOffset = CGPoint(x: 0, y: targetFrame.minY - 100)
            }
        }
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case priceInput:
            textField.text = textField.text?.toDecimal()
            break
        case tagInput:
            if (textField.text?.count ?? 0) > 30 {
                let _ = textField.text?.popLast()
            }
            break
        default: break
        }
    }
}

extension NoteInputViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.imageSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else { return UICollectionViewCell() }
        cell.fill(presenter.imageSources[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = (self.view.frame.width - (60 + 40)) / 3
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
