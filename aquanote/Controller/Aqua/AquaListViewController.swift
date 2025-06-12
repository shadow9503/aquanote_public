//
//  AquaListViewController.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/14.
//

import UIKit

class AquaListViewController: UIViewController {
    
    var presenter: AquaListViewPresenter!
    var searchController = UISearchController()
    
    var containerView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 20
        view.isLayoutMarginsRelativeArrangement = true
        return view
    }()
    
    var tableView: UITableView = {
        let view = UITableView(frame: .zero)
        view.separatorStyle = .none
        view.backgroundColor = .CustomColor.backgroundColor
        view.register(AquaListViewCell.self, forCellReuseIdentifier: AquaListViewCell.identifier)
        view.register(SearchTermCell.self, forCellReuseIdentifier: SearchTermCell.identifier)
        view.register(LoadingViewCell.self, forCellReuseIdentifier: LoadingViewCell.identifier)
        view.register(NoResultsCell.self, forCellReuseIdentifier: NoResultsCell.identifier)
        return view
    }()
    
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        Task {
            let _ = searchController.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        removeNotifications()
    }
    
    func showView() {
        setNavigationBar()
        presenter = AquaListViewPresenter(delegate: self)
        setupView()
        configureView()
        setupConstraints()
    }
    
    func setNavigationBar() {
//        navigationController?.navigationBar.tintColor = .CustomColor.mainTextColor
//        let menuButton = UIBarButtonItem(image: UIImage(named: "Menu")!.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), style: .plain, target: self, action: nil)
//        navigationItem.rightBarButtonItem = menuButton
        title = "주류 검색"
        
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController = UISearchController(searchResultsController: nil)
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.placeholder = "이름으로 검색해보세요"
        searchController.searchBar.showsCancelButton = false
//        searchController.searchBar.cancelButton!.setTitle("", for: .normal)
//        searchController.searchBar.cancelButton!.setImage(UIImage(named: "Filter")!.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), for: .normal)
        let searchIcon = UIImage(named: "Search")!
                .withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal)
        searchController.searchBar.setImage(searchIcon, for: .search, state: .normal)
        
        let keyboardAccessoryView = UIToolbar()
        keyboardAccessoryView.tintColor = .CustomColor.mainTextColor
        keyboardAccessoryView.sizeToFit()
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "완료", style: .done, target: nil, action: #selector(dismissSearchKeyboard))
        keyboardAccessoryView.items = [flexibleButton, doneButton]
        searchController.searchBar.searchTextField.inputAccessoryView = keyboardAccessoryView
        searchController.searchBar.searchTextField.layer.cornerRadius = 20
        searchController.searchBar.searchTextField.layer.masksToBounds = true
        
        navigationItem.searchController = searchController
    }
    
    deinit {
        print("deinit AquaListViewController")
    }
}

extension AquaListViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissSearchKeyboard()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if presenter.isFetching { return }
        switch presenter.getRowType(by: indexPath.section) {
        case .aqua, .searchterm, .noResult:
            presenter.didSelect(at: indexPath)
            break
        default: break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch presenter.getRowType(by: indexPath.section) {
        case .aqua: return tableView.estimatedRowHeight
        case .searchterm: return 40 // tableView.estimatedRowHeight
        case .noResult: return tableView.estimatedRowHeight
        default: return 60
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch presenter.getRowType(by: section) {
        case .aqua: return presenter.isSearching ? presenter.filteredItems.count : 0
        case .searchterm:
            tableView.separatorStyle = presenter.terms.count == 0 ? .none : .singleLine
            return presenter.isSearching ? 0 : presenter.terms.count
        case .loading: return presenter.isFetching ? 1 : 0
        case .noResult: return (!presenter.hasResults && presenter.isSearching) && !presenter.isFetching ? 1 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch presenter.getRowType(by: indexPath.section) {
        case .aqua:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AquaListViewCell.identifier) as? AquaListViewCell  else { return UITableViewCell() }
            cell.fill(item: presenter.getSelectedCellItem(by: indexPath) as Aqua)
            return cell
            
        case .searchterm:
            presenter.isFetching = false
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTermCell.identifier) as? SearchTermCell else { return UITableViewCell() }
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 40))
            button.setImage(UIImage(named: "Trash")!.withTintColor(.CustomColor.mainTextColor, renderingMode: .alwaysOriginal), for: .normal)
            button.addTarget(self, action: #selector(accessoryButtonTapped(_:)), for: .touchUpInside)
            cell.accessoryView = button
            cell.content = presenter.getSelectedCellItem(by: indexPath) as SearchTerm
            return cell
            
        case .loading:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadingViewCell.identifier) as? LoadingViewCell else { return UITableViewCell() }
            cell.startLoading()
            return cell
            
        case .noResult:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: NoResultsCell.identifier) as? NoResultsCell else { return UITableViewCell() }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // for button gradient in contentView
        switch presenter.getRowType(by: indexPath.section) {
        case .aqua: break
        case .searchterm: break
        case .loading: break
        case .noResult:
//            let cell = cell as! NoResultsCell
//            cell.requestButton.backgroundColorWithGradient(colors: [.CustomColor.purple, .CustomColor.pink], bounds: nil)
            break
        }
    }
    
    @objc func accessoryButtonTapped(_ button: UIButton){
        let buttonPosition: CGPoint = button.convert(.zero, to: tableView)
        let indexPath = tableView.indexPathForRow(at: buttonPosition)
        guard let row = indexPath?.row else {
            presenter.deleteSearchTerm(0)
            return
        }
        presenter.deleteSearchTerm(row)
        // do what you gotta do with the indexPath
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
}

extension AquaListViewController: AquaListViewDelegate {
    
    func showAquaRequestVC() {
        let vc = AquaRequestViewController()
        vc.delegate = self
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .formSheet
        presentView(vc)
    }
    
    func showAquaDetail(_ item: Aqua) {
        let vc = AquaDetailViewController()
        vc.item = item
        pushView(vc)
    }
    
    func updateSearchField(input searchString: String) {
        searchController.searchBar.text = searchString
    }
    
    func updateItems() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setupView() {
        view.addSubview(containerView)
        containerView.addArrangedSubview(tableView)
    }
    
    func configureView() {
        view.backgroundColor = UIColor.CustomColor.backgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.showsVerticalScrollIndicator = false
    }
    
    func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        containerView.snp.makeConstraints {
            $0.top.equalTo(safeArea).inset(20)
            $0.leading.trailing.bottom.equalTo(safeArea).inset(20)
        }
    }
    
    func didSuccessFetch() {
        updateItems()
    }
    
    func didFailedFetch() {
        //
    }
}

extension AquaListViewController: UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if presenter.lastSearchedString == searchText { return }
        presenter.textDidChange(input: searchText)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if presenter.lastSearchedString == text { return }
        presenter.searchItems(input: text)
    }
    
    // 필터 버튼으로 커스텀됨.
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // TODO: 필터기능 구현
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
//        super.present(viewControllerToPresent, animated: false)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
//        super.dismiss(animated: true)
    }
}

extension AquaListViewController {
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
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }

    @objc private func keyboardWillHide() {
        let contentInset = UIEdgeInsets.zero
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    @objc func dismissSearchKeyboard() {
        searchController.searchBar.searchTextField.endEditing(true)
    }
}

// cancelButton 커스텀을 위한
//extension UISearchBar {
//    public var cancelButton: UIButton? {
//        return self.value(forKey: "cancelButton") as? UIButton
//    }
//}
