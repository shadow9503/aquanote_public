//
//  RootViewController.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/03.
//

import UIKit
import FirebaseStorage
import AuthenticationServices

class RootViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .darkContent }
    
    var rootView: RootView!
    var presenter: RootViewPresenter!
    var appleLoginService: AppleLoginService!
    
    override func loadView() {
        rootView = RootView()
        super.view = rootView
        presenter = RootViewPresenter(delegate: self)
        navigationController?.isNavigationBarHidden = true
        navigationController?.delegate = self
        rootView.loginButton.addTarget(self, action: #selector(checkingApp), for: .touchUpInside)
        rootView.appleLoginButton.addTarget(self, action: #selector(loginWithApple), for: .touchUpInside)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appleLoginService = AppleLoginService()
        appleLoginService.setAppleLoginPresentationAnchorView(self)
        appleLoginService.delegate = self
        
        autoLogin()
    }
    
    @objc func becomeActive() {

    }
    
    func autoLogin() {
        appleLoginService.checkLoginSession { status in
            if status == .valid {
                self.checkingApp()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(becomeActive), name: .NSExtensionHostDidBecomeActive, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}

extension RootViewController {
    
    func startLoading() {
        DispatchQueue.main.async {
            self.view.setBlur(style: .systemThinMaterialDark,
                              text: "업데이트 체크가 진행되는동안\n종료하지 말아주세요",
                              opacity: 0.85) { _ in }
        }
    }
    
    func stopLoading() {
        DispatchQueue.main.async {
            self.view.removeBlur()
        }
    }
    
    @objc func checkingApp() {
        
        if !NetworkMonitor.shared.isConnected {
             needNetworkConnection()
            return
        }
        
        self.startLoading()
        Task {
            await self.presenter.appUpdateCheck()
        }
    }
    
    @objc func loginWithApple() {
        
        if !NetworkMonitor.shared.isConnected {
            needNetworkConnection()
            return
        }
        
        appleLoginService.checkLoginSession { status in
            if status == .valid {
                self.checkingApp()
            } else {
                let request = ASAuthorizationAppleIDProvider().createRequest() //request 생성
                //요청을 날릴 항목 설정 : 이름, 이메일
                request.requestedScopes = [.fullName, .email]
                //request를 보내줄 controller 생성
                let controller = ASAuthorizationController(authorizationRequests: [request])
                //controller의 delegate와 presentationContextProvider 설정
                controller.delegate = self.appleLoginService
                controller.presentationContextProvider = self.appleLoginService
                controller.performRequests() //요청 보냄
            }
        }
    }
}

extension RootViewController: AppleLoginServiceDelegate {
    func didSuccessSignInAccount() {
        checkingApp()
    }
    
    func didFailedSignInAccount() {
        stopLoading()
    }
}

extension RootViewController: RootViewDelegate {
    
    func needNetworkConnection() {
        stopLoading()
        let actions = [
            UIAlertAction(title: "확인", style: .cancel)]
        let alert = newAlertController(title: "알림", message: "앱 실행을 위해서는\n네트워크 연결이 필요해요!", actions: actions)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func didFailedUpdateApp(_ message: String) {
        stopLoading()
        toast(message, duration: 2.5)
    }
    
    func didUpdateCheck(_ status: VersionStatus) {
        stopLoading()
        if status == .old {
            let actions = [
                UIAlertAction(title: "확인", style: .cancel, handler: { action in
                    self.presenter.appVersionUpdate()
                })]
            let alert = newAlertController(title: "알림", message: "앱스토어에서 업데이트를 진행해주세요", actions: actions)
            DispatchQueue.main.async {
                self.present(alert, animated: true)
            }
        } else {
            DispatchQueue.main.async {
                let vc = NoteListViewController()
                self.setView(vc)
            }
        }
    }
    
    func didSuccessfulUpdateApp(_ message: String?) {
        DispatchQueue.main.async {
            let vc = NoteListViewController()
            self.setView(vc)
            vc.toast(message)
        }
    }
    
    func didFailedNotedataSync(_ message: String) {
        DispatchQueue.main.async {
            let vc = NoteListViewController()
            self.setView(vc)
            vc.toast(message, duration: 2.5)
        }
    }
    
    func didSuccessfulNotedataSync(_ message: String?) {
        DispatchQueue.main.async {
            let vc = NoteListViewController()
            self.setView(vc)
            vc.toast(message)
        }
    }
}
