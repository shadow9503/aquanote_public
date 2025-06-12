//
//  RevokeMemberViewController.swift
//  aquanote
//
//  Created by 유영훈 on 2023/03/01.
//

import UIKit
import SnapKit

class RevokeMemberViewController: UIViewController {

    var appleLoginService: AppleLoginService!
    
    var revokeButton: PaddingButton = {
        let view = PaddingButton(padding: .init(top: 0, left: 20, bottom: 0, right: 20))
        view.setTitleColor(.CustomColor.mainTextColor, for: .normal)
        view.setTitleColor(.lightGray, for: .highlighted)
        view.setTitle("회원탈퇴", for: .normal)
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSizeMake(1, 2)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 3
        return view
    }()
    
    override func loadView() {
        super.view = .init(frame: .zero)
    
        appleLoginService = AppleLoginService()
        appleLoginService.setAppleLoginPresentationAnchorView(self)
        appleLoginService.delegate = self
        
        let titleLabel = UILabel()
        titleLabel.text = "회원탈퇴 안내"
        titleLabel.font = .customFont(.bold, 32)
        titleLabel.textColor = .CustomColor.mainTextColor
        
        let label = UILabel()
        let text = "회원 탈퇴를 진행할 경우 기존 작성한 노트 및 백업본까지 모두 소멸됩니다.\n이후 모든 데이터는 복구할 수 없어요!\n\n그래도 회원 탈퇴를 원하신다면 아래 버튼을 눌러 진행해주세요"
        
        let attributedString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2.5
        attributedString.addAttribute(.foregroundColor,
                                      value: UIColor.CustomColor.mainTextColor,
                                      range: (text as NSString).range(of: "이후 모든 데이터는 복구할 수 없어요!"))
        attributedString.addAttribute(.backgroundColor,
                                      value: UIColor.systemRed,
                                      range: (text as NSString).range(of: "이후 모든 데이터는 복구할 수 없어요!"))
        label.attributedText = attributedString
        label.layer.masksToBounds = true
        label.font = .customFont(.regular, 18)
        label.numberOfLines = 0
        
        view.backgroundColor = .CustomColor.backgroundColor
        view.addSubview(titleLabel)
        view.addSubview(label)
        view.addSubview(revokeButton)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(80)
            $0.leading.equalToSuperview().inset(30)
        }
        
        label.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp_bottomMargin).offset(45)
            $0.leading.trailing.equalToSuperview().inset(30)
        }
        
        revokeButton.addTarget(self, action: #selector(revoke), for: .touchUpInside)
    }
    
    @objc func revoke() {
        let actions = [
            UIAlertAction(title: "회원탈퇴", style: .destructive)
            { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.isNavigationBarHidden = true
                self.view.setBlur(style: .systemThickMaterialDark, text: "회원탈퇴를 진행중이에요...")
                Task {
                    guard let refreshToken = UserDefaults.standard.string(forKey: "refreshToken") else {
                        self.view.removeBlur()
                        self.toast("로그인이 필요한 서비스에요")
                        return
                    }
                    
                    await self.appleLoginService.appleAuthorizationTokenRevoke(refreshToken: refreshToken)
                }
            },
            UIAlertAction(title: "취소", style: .cancel)
            { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.dismiss(animated: true)
                }
            }
        ]
        
        let alert = self.newAlertController(title: "주의", message: "정말로 회원탈퇴를 진행할까요?", style: .actionSheet, actions: actions)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        revokeButton.snp.makeConstraints {
            $0.top.equalTo(view.bounds.height * 0.7)
            $0.centerX.equalToSuperview()
        }
        
        revokeButton.backgroundColorWithGradient(colors: [.CustomColor.purple, .CustomColor.pink], bounds: nil, paintingDirection: .fromBottom)
    }
}


extension RevokeMemberViewController: AppleLoginServiceDelegate {
    func didFailedRevokeAccount() {
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = false
            self.view.removeBlur()
        }
    }
    
    func diduccessRevokeAccount() {
        DispatchQueue.main.async {
            self.navigationController?.isNavigationBarHidden = false
            self.setView(RootViewController())
        }
    }
    
}
