//
//  AquaRequestViewController.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/16.
//

import UIKit
import SnapKit
import Alamofire

class AquaRequestViewController: UIViewController {
    
    lazy var placeholder: String = "찾는 주류 정보를 입력해주세요."
    weak var delegate: AquaListViewController!
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.layer.zPosition = 0
        return view
    }()
    
    lazy var containerStack: UIStackView = {
        let view = UIStackView()
        view.isLayoutMarginsRelativeArrangement = true
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    
    var requestInputLabel: PaddingLabel = {
        let view = PaddingLabel(padding: UIEdgeInsets(top: 20, left: 0, bottom: 7, right: 0))
        let text = "추가를 원하시는\n주류 정보를 알려주세요. \n최대한 빠르게 추가해드릴게요."
        let nsRange = (text as NSString).range(of: "주류 정보를 알려주세요. ")
        let attributedString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2.5
        attributedString.addAttribute(.foregroundColor, value: UIColor.CustomColor.backgroundColor, range: nsRange)
        attributedString.addAttribute(.backgroundColor, value: UIColor.CustomColor.mainTextColor, range: nsRange)
        attributedString.addAttribute(.paragraphStyle, value: style, range: NSMakeRange(0, attributedString.length))
        view.attributedText = attributedString
        view.layer.masksToBounds = true
        view.font = .customFont(.regular, 18)
        view.numberOfLines = 0
        return view
    }()
    
    lazy var requestInput: PaddingTextView = {
        let view = PaddingTextView(padding: UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12))
        view.font = .CustomFont.base
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.CustomColor.lightgray.cgColor
        view.text = placeholder
        view.textColor = .CustomColor.mainTextColor //.CustomColor.darkGray
        view.backgroundColor = .CustomColor.backgroundColor//.CustomColor.lightgray
        view.textContainerInset = UIEdgeInsets(top: 18, left: 12, bottom: 18, right: 12)
        view.delegate = self
        return view
    }()
    
    var requestButton: PaddingButton = {
        let view = PaddingButton(padding: UIEdgeInsets(top: 10, left: 24, bottom: 10, right: 24))
        view.setTitle("요청하기", for: .normal)
        view.setTitleColor(.CustomColor.mainTextColor, for: .normal)
        view.setTitleColor(.CustomColor.lightgray, for: .highlighted)
        view.titleLabel?.font = UIFont.customFont(.medium, 18)
        view.layer.cornerRadius = 30
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSizeMake(1, 2)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 3
        return view
    }()
    
    override func loadView() {
        super.view = .init()
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerStack)
        
        let viewWrapper = UIView()
        viewWrapper.addSubview(requestButton)
        
        containerStack.addArrangedSubview(requestInputLabel)
        containerStack.addArrangedSubview(requestInput)
        containerStack.addArrangedSubview(viewWrapper)
    
        let safeArea = view.safeAreaLayoutGuide
        
        scrollView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        containerStack.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(100)
            $0.bottom.equalToSuperview().inset(50)
        }
        
        requestInput.snp.makeConstraints {
            $0.height.equalTo(200)
        }
        
        requestButton.snp.makeConstraints {
            $0.centerX.bottom.equalToSuperview()
            $0.top.equalToSuperview().inset(30)
        }
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        view.backgroundColor = .CustomColor.backgroundColor
        
        requestButton.addTarget(self, action: #selector(requestAqua), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        requestButton.backgroundColorWithGradient(colors: [.CustomColor.purple, .CustomColor.pink], bounds: nil, paintingDirection: .fromTop)
    }
    
    @objc func requestAqua() {
        view.setBlur(style: .systemChromeMaterial) { _ in }
        Task {
            let params = [ "content": requestInput.text ].toParameter
            guard let response = try? await AquanoteAPI.request(router: .post(.app, "/requests", params)) else {
                view.removeBlur()
                dismiss(animated: true)
                delegate.toast.pop("내부 에러가 발생했어요.")
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
                self.dismiss(animated: true)
                self.view.removeBlur()
                self.delegate.toast.pop("요청되었어요.")
            }
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
                return
        }
        let contentInset = UIEdgeInsets(
                top: 0.0,
                left: 0.0,
                bottom: keyboardFrame.size.height,
                right: 0.0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }

    @objc private func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
}

extension AquaRequestViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        if text.isEmpty || text == placeholder {
            textView.text = placeholder
        }
    }
}
