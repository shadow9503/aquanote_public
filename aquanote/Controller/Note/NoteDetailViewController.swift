//
//  NoteDetailViewController.swift
//  aquanote
//
//  Created by 유영훈 on 2023/01/26.
//

import UIKit
import SnapKit

class NoteDetailViewController: UIViewController, AppleLoginServiceDelegate {

    var presenter: NoteDetailViewPresenter!
    var appleLoginService: AppleLoginService!
    var contentView = NoteDetailContentView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showView()
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(_:)))
        swipe.direction = .right
        view.addGestureRecognizer(swipe)
    }
    
    convenience init(item: Note) {
        self.init()
        appleLoginService = AppleLoginService()
        appleLoginService.setAppleLoginPresentationAnchorView(self)
        appleLoginService.delegate = self
        
        presenter = NoteDetailViewPresenter(delegate: self)
        presenter.item = item
        contentView.fill(item: item)
    }
    
    @objc func swipeRight(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right {
            popView()
        }
    }
    
    func showView() {
        setNavigationBar()
        setupView()
        configureView()
        setupConstraints()
    }
    
    func setNavigationBar() {
        navigationController?.navigationBar.tintColor = .CustomColor.mainTextColor
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Menu", image: UIImage(named: "Menu")!, menu: menu)
        self.title = "테이스팅 노트"
    }
    
    @objc func editNote() {
        let vc = NoteInputViewController()
        vc.note = presenter.item
        pushView(vc)
    }
    
    func deleteNote() {
        self.appleLoginService.checkLoginSession { status in
            if self.presenter.deleteNote(backup: status == .valid) {
                DispatchQueue.main.async {
                    let vc = NoteListViewController()
                    self.setView(vc)
                }
            }
        }
    }
}

extension NoteDetailViewController: ViewableProtocol {
    func setupView() {
        view.addSubview(contentView)
    }
    
    func configureView() {
        view.backgroundColor = .CustomColor.backgroundColor
    }
    
    func setupConstraints() {
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension NoteDetailViewController: NoteDetailViewDelegate {
    func didSuccessFetch(item: Note) {
        contentView.fill(item: item)
    }
    
    func didFailedFetch() {
        // can not load note
        // TODO: alert
    }
}

extension NoteDetailViewController: UIContextMenuInteractionDelegate {
    private var menuItems: [UIAction] {
        return [
//            UIAction(title: "설정", image: UIImage(systemName: "gearshape")!, handler: { [weak self] _ in
//                guard let self = self else { return }
//                // TODO: 설정 화면
//            }),
            UIAction(title: "수정", image: UIImage(named: "Edit")?.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), handler: { [weak self] _ in
                guard let self = self else { return }
                self.editNote()
            }),
            UIAction(title: "삭제", image: UIImage(systemName: "xmark.circle.fill")?
                .withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                     handler: { [weak self] _ in
                        guard let self = self else { return }
                        let alert = UIAlertController(title: "주의", message: "노트가 영구적으로 삭제돼요\n그래도 삭제할까요?", preferredStyle: .alert)
                        let deleteAction = UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] action in
                            guard let self = self else { return }
                            self.deleteNote()
                        })
                        let cancelAction = UIAlertAction(title: "취소", style: .default)
                        alert.addAction(deleteAction)
                        alert.addAction(cancelAction)
                        
                        self.present(alert, animated: true)
                    })
        ]
    }
    
    private var menu: UIMenu {
        return UIMenu(title: "메뉴", options: [.displayInline], children: menuItems)
    }
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            return self.menu
        })
    }
}
