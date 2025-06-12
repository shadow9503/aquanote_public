//
//  NoteListViewController.swift
//  auanote
//
//  Created by 유영훈 on 2022/12/05.
//

import UIKit
import SnapKit
import AuthenticationServices

class NoteListViewController: UIViewController {
    
    var presenter: NoteListViewPresenter!
    var appleLoginService: AppleLoginService!
    
    var beforeDraggingOffsetY: Double = 0.0
    
    lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        let text = "" //"제정신이라는게 건강에 해로우니까요."
        let nsString = NSMutableAttributedString(string: text)
        let range = (text as NSString).range(of: text)
        nsString.addAttribute(.font, value: UIFont(name: "NotoSansKR-Light", size: 14)!, range: range)
        nsString.addAttribute(.foregroundColor, value: UIColor.white, range: range)
        view.attributedTitle = nsString
        view.tintColor = .CustomColor.mainTextColor
        view.layer.zPosition = -1
        return view
    }()
    
    var containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        view.isLayoutMarginsRelativeArrangement = true
        view.layer.zPosition = 0
        return view
    }()
    
    var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        view.allowsMultipleSelection = true
        view.separatorStyle = .none
        view.backgroundColor = .CustomColor.backgroundColor
        return view
    }()
    
    var noteButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "NoteEdit")!, for: .normal)
        view.setImage(UIImage(named: "NoteEdit")!.withTintColor(.CustomColor.lightgray, renderingMode: .alwaysOriginal), for: .highlighted)
        view.layer.cornerRadius = 25
        view.backgroundColor = .CustomColor.purple
        view.showsMenuAsPrimaryAction = true
        view.layer.zPosition = 999
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSizeMake(1, 2)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 3
        return view
    }()
    
    var defaultView: UIView = {
        let label = UILabel()
        label.text = "현재 작성된 노트가 없어요 XD"
        label.textAlignment = .center
        label.font = .CustomFont.baseM
        label.textColor = .CustomColor.subTextColor
        
        let container = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Editline")?.withTintColor(.CustomColor.subTextColor, renderingMode: .alwaysOriginal)
        imageView.contentMode = .scaleAspectFill
        container.addSubview(imageView)
        
        let view = UIView()
        view.isHidden = true
        view.addSubview(imageView)
        view.addSubview(label)
        
        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        imageView.snp.makeConstraints {
            $0.centerX.equalTo(label)
            $0.bottom.equalTo(label).inset(30)
            $0.width.height.equalTo(40)
        }
        
        return view
    }()
    
    var menuButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "Menu")!.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), for: .normal)
        view.showsMenuAsPrimaryAction = true
        return view
    }()
    
    var deleteButton: UIButton = {
        let view = UIButton()
        view.setTitle("삭제", for: .normal)
        view.setTitleColor(.systemRed, for: .normal)
        view.isHidden = true
        return view
    }()
    
    var cancelButton: UIButton = {
        let view = UIButton()
        view.setTitle("취소", for: .normal)
        view.setTitleColor(.CustomColor.mainTextColor, for: .normal)
        return view
    }()
    
    var appLogo: UIButton = {
        let view = UIButton()
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        view.setTitle("aquanote", for: .normal)
        view.setTitleColor(.CustomColor.lightgray, for: .normal)
        return view
    }()
    
    override func loadView() {
        super.view = .init()
        navigationController?.isNavigationBarHidden = false
    }
    
    func needNetworkConnection() {
        let actions = [
            UIAlertAction(title: "확인", style: .cancel)]
        let alert = newAlertController(title: "알림", message: "네트워크 연결이 필요한 서비스에요\n연결 후 다시 시도해주세요", actions: actions)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    @objc func loginWithApple() {
        
        if !NetworkMonitor.shared.isConnected {
            needNetworkConnection()
            return
        }
        
        startPageLoading()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showView()
        presenter.initDataSource()
        presenter.ifNeedBackupList()
        
        appleLoginService = AppleLoginService()
        appleLoginService.setAppleLoginPresentationAnchorView(self)
        appleLoginService.delegate = self
        
//        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeft(_:)))
//        swipe.direction = .left
//        view.addGestureRecognizer(swipe)
    }
    
    @objc func swipeLeft(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            let vc = AquaListViewController()
            self.pushView(vc)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        noteButton.backgroundColorWithGradient(colors: [.CustomColor.purple, .CustomColor.pink],
                                               bounds: nil, paintingDirection: .fromBottom)
        menuUpdate()
    }
    
    func showView() {
        presenter = NoteListViewPresenter(delegate: self)
        setNavigationBar()
        setupView()
        configureView()
        setupConstraints()
    }
    
    func setNavigationBar() {
        // UIRefreshControl과 함께 사용시 UI 이슈 있음.
//        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .CustomColor.mainTextColor
        deleteButton.addTarget(self, action: #selector(deleteList), for: .touchUpInside)
        
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.setTitleColor(.CustomColor.mainTextColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(toggleEditingMode), for: .touchUpInside)
        
        let topMenuStack = UIStackView()
        topMenuStack.spacing = 10
        topMenuStack.addArrangedSubview(deleteButton)
        topMenuStack.addArrangedSubview(menuButton)
    
        navigationItem.setLeftBarButton(UIBarButtonItem(customView: appLogo), animated: true)
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: topMenuStack)]
        navigationItem.backButtonTitle = "목록"
//        self.title = "노트 목록"
    }
    
    @objc func toggleEditingMode() {
        isEditing = !isEditing
        tableView.bounces = !isEditing
        deleteButton.isHidden = !isEditing
        guard let navItem = navigationController?.topViewController?.navigationItem else { return }
        navItem.setLeftBarButton(UIBarButtonItem(customView: isEditing ? cancelButton : appLogo), animated: true)
        updateItems()
    }
    
    @objc func deleteList() {
        guard let selectedRows = self.tableView.indexPathsForSelectedRows else {
            toast("삭제할 노트를 선택해주세요.")
            return
        }
        
        let actions = [
            UIAlertAction(title: "삭제", style: .destructive)
            { [weak self] action in
                guard let self = self else { return }
                self.appleLoginService.checkLoginSession { status in
                    let _ = self.presenter.deleteList(selectedRows, backup: status == .valid)
                }
            },
            UIAlertAction(title: "취소", style: .cancel)
        ]
        
        let alert = newAlertController(title: "경고", message: "선택된 노트들이 영구적으로 삭제되요.",
                                       style: .alert, actions: actions)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func appleLoginAlert() {
        let actions = [
            UIAlertAction(title: "로그인", style: .destructive)
            { action in
                self.loginWithApple()
            },
            UIAlertAction(title: "취소", style: .cancel)
        ]
        
        let alert = newAlertController(title: "알림", message: "로그인이 필요한 서비스에요",
                                       actions: actions)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    deinit {
        print("deinit")
    }
}

extension NoteListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.height
        
        // 하단 offsetY 좌표를 indexPath로
        if let row = tableView.indexPathForRow(at: CGPoint(x: 0, y: (offsetY + height)))?.row {
            if row != 0 {
                presenter.fetchList(row)
            }
        }
        
        // 상단 드래깅 - 새로고침
        if offsetY < 0 {
            if refreshControl.isRefreshing {
                presenter.willRefresh = true
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if presenter.willRefresh && !isEditing {
            presenter.refreshList()
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if presenter.willRefresh && !isEditing {
            startPageLoading()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if !isEditing {
                let vc = NoteDetailViewController(item: presenter.totalItems[indexPath.row])
                pushView(vc)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return tableView.estimatedRowHeight
        case 1: return 100
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return presenter.numberOfRows
        case 1: return presenter.isPaging ? 1 : 0
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteListViewCell.identifier) as? NoteListViewCell else { return UITableViewCell() }
            cell.fill(note: presenter.totalItems[indexPath.row])
            cell.isEditing = self.isEditing
            return cell
        default:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadingViewCell.identifier) as? LoadingViewCell else { return UITableViewCell() }
            cell.loadingIndicator.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        // TODO: 다중선택모드
    }
}

extension NoteListViewController: NoteListViewDelegate {
    
    func startPageLoading(style: UIBlurEffect.Style = .systemThickMaterialDark, text: String = "", opacity: CGFloat = 0.85) {
        DispatchQueue.main.async {
            self.menuButton.isEnabled = false
            self.view.setBlur(style: style,
                              text: text,
                              opacity: opacity)
        }
    }
    
    func endPageLoading() {startPageLoading()
        DispatchQueue.main.async {
            self.menuButton.isEnabled = true
            self.view.removeBlur()
        }
    }
    
    func needsBackupList() {
        let actions = [
            UIAlertAction(title: "확인", style: .destructive,
                          handler: { [weak self] action in
                              guard let self = self else { return }
                              print(NetworkMonitor.shared.isConnected)
                          }
            ),
            UIAlertAction(title: "취소", style: .cancel)
        ]
        
        let alert = newAlertController(title: "알림", message: "노트들을 모두 백업할게요", style: .alert, actions: actions)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
    
    func didFinishedBackupProcess(_ message: String) {
        presenter.refreshList()
        endPageLoading()
        toast(message)
    }
    
    func didFailedNoteDelete() {
        //
    }
    
    func didFinishedSyncronizeProcess(_ message: String) {
        presenter.refreshList()
        endPageLoading()
        toast(message)
    }
    
    func didSuccessNoteDelete() {
//        if presenter.numberOfRows == 0 { toggleEditingMode() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateItems()
            self.endPageLoading()
        }
    }
    
    func willNoteDelete() {
        startPageLoading()
    }
    
    func beginListLoading() {
        presenter.isPaging = true
        tableView.reloadData()
    }
    
    func endListLoading() {
        presenter.isPaging = false
    }
    
    @objc func updateItems() {
        endListLoading()
        refreshControl.endRefreshing()
        defaultView.isHidden = presenter.numberOfRows != 0
        tableView.separatorStyle = presenter.numberOfRows != 0 ? .singleLine : .none
        tableView.bounces = presenter.numberOfRows != 0
        tableView.reloadData()
    }
    
    func didNothingFetched() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.toast("더이상 불러올 노트가 없어요")
            self.updateItems()
        }
    }
     
    func didSuccessFetch() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            self.updateItems()
        }
    }
    
    func didFailedFetch() {
        //
    }
    
    func setupView() {
        view.addSubview(containerView)
        view.addSubview(noteButton)
        containerView.addArrangedSubview(tableView)
        tableView.addSubview(defaultView)
        view.setNeedsUpdateConstraints()
    }
    
    func configureView() {
        view.backgroundColor = .CustomColor.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
        tableView.register(NoteListViewCell.self, forCellReuseIdentifier: NoteListViewCell.identifier)
        tableView.register(LoadingViewCell.self, forCellReuseIdentifier: LoadingViewCell.identifier)
        tableView.refreshControl = refreshControl
        noteButton.menu = floatingMenu
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        containerView.snp.makeConstraints {
            $0.top.equalTo(safeArea)
            $0.leading.bottom.trailing.equalTo(safeArea).inset(10)
        }
        
        noteButton.snp.makeConstraints {
            $0.bottom.trailing.equalTo(safeArea).inset(20)
            $0.size.equalTo(50)
        }
        
        defaultView.snp.makeConstraints {
            $0.leading.trailing.equalTo(view)
            $0.centerY.equalTo(view)
        }
    }
}

extension NoteListViewController: AppleLoginServiceDelegate {
    
    func didEndAuthorization() {
        endPageLoading()
    }
    
    func diduccessRevokeAccount() {
        DispatchQueue.main.async {
            let vc = RootViewController()
            vc.toast("회원탈퇴 처리가 완료되었어요ㅠ")
            self.setView(vc)
        }
    }
    
    func didFailedRevokeAccount() {
        endPageLoading()
        toast("회원탈퇴 처리에 실패했어요")
    }
    
    func didSuccessSignOutAccount() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.endPageLoading()
            self.menuUpdate()
        }
    }
    
    func didSuccessSignInAccount() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            self.endPageLoading()
            self.menuUpdate()
        }
    }

    func menuUpdate() {
        let beforeLoginActions = [
            UIAction(title: "로그인") { _ in
                self.loginWithApple()
            }
        ]
        let afterLoginActions = [
            UIAction(title: "로그아웃") { _ in
                let actions = [
                    UIAlertAction(title: "확인", style: .destructive)
                    { [weak self] action in
                        guard let self = self else { return }
                        self.startPageLoading(text: "로그아웃중...")
                        self.appleLoginService.logout()
                    },
                    UIAlertAction(title: "취소", style: .cancel)
                ]

                let alert = self.newAlertController(title: "알림", message: "현재 로그인된 아이디를 로그아웃할게요", style: .alert, actions: actions)
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            },
            UIAction(title: "회원탈퇴", attributes: .destructive) { _ in
                let vc = RevokeMemberViewController()
                self.pushView(vc)
            }
        ]
        
//        let createDummy = UIAction(title: "더미 생성30")
//        { _ in
//
//            var array = [NoteModel]()
//            for i in stride(from: 0, to: 30, by: 1) {
//                let note = NoteModel(uid: "uid", uuid: UUID(), addedOn: Date(), editedOn: Date(), title: "test_title_\(i)", images: [], tastingDate: nil, nation: "", category: "", strength: "50", age: "9", price: "73000", tags: [], nose: "nose~", palate: "palate~", finish: "finish~", comment: "comment~", etc: "etc~", isBackup: false)
//                array.append(note)
//            }
//
//            try? CoreDataService.shared.batchInsertion(array)
//            self.presenter.refreshList()
//        }
//
//        let deleteDummy = UIAction(title: "더미 모두 삭제")
//        { _ in
//            try? CoreDataService.shared.deleteAllRecord(.notes)
//            self.presenter.refreshList()
//        }
        
        appleLoginService.checkLoginSession { status in
            DispatchQueue.main.async {
                let elements = status == .valid ? afterLoginActions : beforeLoginActions
                let accountMenu = self.menuBuilder(title: "계정", image: UIImage(systemName: "gearshape")!, options: [], children: elements)
                self.menuButton.menu = self.menuBuilder(title: "메뉴", image: nil, options: .displayInline,
                                                children: [accountMenu, self.advancedMenu, self.selectionAction])
            }
        }
    }
    
    func didFailedSignInAccount() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.endPageLoading()
            self.toast("로그인에 실패했어요!")
        }
    }
}

extension NoteListViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            return self.floatingMenu
        })
    }
    
    private var floatingMenu: UIMenu {
        let actions = [
//            UIAction(title: "주류 검색", image: UIImage(named: "Search")!
//                .withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal),
//                     handler: { [weak self] _ in
//                        guard let self = self else { return }
//                        if self.isEditing { self.toggleEditingMode() }
//                        let vc = AquaListViewController()
//                        self.pushView(vc)
//                    }),
            UIAction(title: "노트 작성", image: UIImage(named: "NoteEdit")!
                .withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal),
                     handler: { [weak self] _ in
                        guard let self = self else { return }
                        if self.isEditing { self.toggleEditingMode() }
                        let vc = NoteInputViewController()
                        self.pushView(vc)
                    })
        ]
        return UIMenu(title: "도구", options: [.displayInline], children: actions)
    }
    
    private var selectionAction: UIAction {
        return UIAction(title: "선택", image: UIImage(systemName: "checkmark.circle.fill")!
            .withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                 handler: { [weak self] _ in
                    guard let self = self else { return }
                        if self.presenter.numberOfRows == 0 {
                            self.toast("선택할 노트가 없어요")
                        } else {
                            self.toggleEditingMode()
                        }
                 })
        
//        UIAction(title: "보기", image: UIImage(systemName: "list.dash")!,
//            handler: { [weak self]  _ in
//                // TODO: view type
//                guard let self = self else { return }
//                if self.isEditing { self.toggleEditingMode() }
//            }),
//        UIAction(title: "정렬", image: UIImage(systemName: "arrow.up.arrow.down")!,
//            handler: { [weak self] _ in
//                // TODO: sorting note list
//                guard let self = self else { return }
//                if self.isEditing { self.toggleEditingMode() }
//            }),
    }
    
    private var advancedMenu: UIMenu {
        let backupAction = UIAction(title: "노트 백업", image: UIImage(systemName: "tray.and.arrow.up")!
            .withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal),
                handler: { [weak self] _ in
                    guard let self = self else { return }
            
                    let count = self.presenter.getNotBackupedItemsCount()
                    if count == 0 {
                        let actions = [
                            UIAlertAction(title: "확인", style: .default)
                        ]
                        
                        let alert = self.newAlertController(title: "알림", message: "현재 더이상 백업할 노트가 없습니다.", style: .actionSheet, actions: actions)
                        DispatchQueue.main.async {
                            self.present(alert, animated: true)
                        }
                        return
                    }
            
                    if self.isEditing { self.toggleEditingMode() }
            
                    if !NetworkMonitor.shared.isConnected {
                        self.needNetworkConnection()
                        return
                    }
            
                    if FIRStoreService.shared.isWaitingPendingWrites {
                        self.toast("누락된 네트워크 작업을 진행중이에요\n잠시만 기다려주세요...")
                        return
                    }
                    
                    self.appleLoginService.checkLoginSession { status in
                    switch status {
                        case .valid:
                            let count = self.presenter.getItemsCount()
                            let actions = [
                                UIAlertAction(title: "백업", style: .destructive)
                                { _ in
                                    self.startPageLoading(text: "노트 백업중...")
                                    self.presenter.backupList()
                                },
                                UIAlertAction(title: "취소", style: .cancel)
                            ]
                            
                            let alert = self.newAlertController(title: "알림", message: "현재 작성된 \(count)개의 노트들이 안전하게 백업됩니다.", style: .actionSheet, actions: actions)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true)
                            }
                            break
                            
                        case .invalid:
                            self.appleLoginAlert()
                            break
                        }
                    }
                })
        
        let syncAction = UIAction(title: "노트 복원", image: UIImage(systemName: "tray.and.arrow.down.fill")!
            .withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), attributes: .destructive,
                handler: { [weak self] _ in
                    guard let self = self else { return }
                    if self.isEditing { self.toggleEditingMode() }
            
                    // network check
                    if !NetworkMonitor.shared.isConnected {
                        self.needNetworkConnection()
                        return
                    }
            
                    // pedingWrites check
                    if FIRStoreService.shared.isWaitingPendingWrites {
                        self.toast("누락된 네트워크 작업을 진행중이에요\n잠시만 기다려주세요...")
                        return
                    }
            
                    // login status
                    self.appleLoginService.checkLoginSession { status in
                        switch status {
                        case .valid:
                            
                            // 더이상 백업이 필요한 노트가 로컬에 존재하지않음.
                            // alert start
                            let actions = [
                                UIAlertAction(title: "복원", style: .destructive, handler: { _ in
                                    self.startPageLoading(text: "노트 복원중...")
                                    self.presenter.syncronizeList()
                                }),
                                UIAlertAction(title: "취소", style: .default, handler: { _ in })
                            ]
                            
                            let alert = self.newAlertController(title: "알림", message: "서버에 백업된 노트들을 불러옵니다\n현재 앱에 작성된 노트들을 덮어씁니다\n복원를 진행할까요?", style: .actionSheet, actions: actions)
                            DispatchQueue.main.async {
                                self.present(alert, animated: true)
                            }
                            break
                        case .invalid:
                            self.appleLoginAlert()
                            break
                        }
                    }
                })
      
        return UIMenu(title: "고급", image: UIImage(systemName: "wrench.and.screwdriver"),
                          children: [backupAction, syncAction])
    }
}

extension NoteListViewController {
    func menuBuilder(title: String, image: UIImage?, options: UIMenu.Options, children: [UIMenuElement]) -> UIMenu {
        return UIMenu(title: title, image: image, options: options,  children: [UIDeferredMenuElement { provider in
            DispatchQueue.main.async {
                provider(children)
            }
        }])
    }
}
