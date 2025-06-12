//
//  RootView.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/16.
//

import UIKit
import SnapKit
import AuthenticationServices

class RootView: UIView {
    
    lazy var loginButton: UIButton = {
        let view = UIButton()
        view.setTitle("간편하게 시작", for: .normal)
        view.setTitleColor(.black, for: .normal)
        view.titleLabel!.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        view.backgroundColor = .CustomColor.mainTextColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSizeMake(1, 2)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 3
        return view
    }()
    
    lazy var versionLabel: UILabel = {
        let view = UILabel()
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        view.text = version ?? "0.0"
        view.font = .CustomFont.sub2M
        view.textColor = .CustomColor.subColor
        return view
    }()
    
    var appleLoginButton: ASAuthorizationAppleIDButton = {
        let view = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        view.cornerRadius = 22
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSizeMake(1, 2)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 3
        return view
    }()
    
    var loginButtonStack: UIStackView = {
        let view = UIStackView()
        view.spacing = 12
        view.axis = .vertical
        return view
    }()
    
    var backgroundImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "wave.png")
        view.contentMode = .scaleAspectFill
        view.isUserInteractionEnabled = false
        return view
    }()
    
    var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
    var subTitleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.text = "나만의 테이스팅 노트 저장소"
        view.font = UIFont.customFont(.regular, 21)
        return view
    }()
    
    var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.text = "아쿠아노트"
        view.font = UIFont.customFont(.bold, 42)
//        let attributedString = NSMutableAttributedString(string: view.text!)
//        attributedString.addAttribute(.font, value: UIFont.customFont(.light, 15), range: (view.text! as NSString).range(of: "ver 1.0"))
//        view.attributedText = attributedString
        return view
    }()
    
    var bottomLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor.CustomColor.subColor
        view.text = "즐거웠던 경험 두고두고 기억할 수 있게"
        view.font = UIFont.CustomFont.sub2
        return view
    }()
    
    var loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.style = .large
        view.color = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RootView: ViewableProtocol {
    func setupView() {
        [backgroundImageView,
         stackView,
         bottomLabel,
         loginButtonStack,
         versionLabel].forEach { addSubview($0) }
        
        [appleLoginButton,
         loginButton].forEach {
            loginButtonStack.addArrangedSubview($0)
        }
        
        backgroundImageView.addSubview(loadingIndicator)
        stackView.addArrangedSubview(subTitleLabel)
        stackView.addArrangedSubview(titleLabel)
        
        backgroundColor = .white
    }
    
    func setupConstraints() {
        let safeArea = safeAreaLayoutGuide
        
        backgroundImageView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
//            $0.top.equalTo(180)
            $0.top.equalToSuperview().inset(-140)
        }
    
        stackView.snp.updateConstraints {
            $0.leading.trailing.equalTo(safeArea).inset(30)
            $0.top.equalTo(bounds.height * 0.2)
        }
        
        loginButtonStack.snp.makeConstraints {
            $0.top.equalTo(bounds.height * 0.7)
            $0.leading.equalTo(60)
            $0.trailing.equalTo(-60)
        }
        
        loginButton.snp.makeConstraints {
            $0.height.equalTo(42)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.height.equalTo(42)
        }

        bottomLabel.snp.makeConstraints {
            $0.top.equalTo(loginButtonStack.snp_bottomMargin).offset(38)
            $0.centerX.equalToSuperview()
        }

        loadingIndicator.snp.makeConstraints {
            $0.edges.centerX.equalToSuperview()
            $0.edges.centerY.equalToSuperview()
        }
        
        versionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    override func layoutSubviews() {
        setupConstraints()
        loginButton.layer.cornerRadius = 22
    }
}
