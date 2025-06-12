//
//  SearchTermContentView.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/21.
//

import UIKit
import SnapKit

class SearchTermContentView: UIView, UIContentView {
    
    lazy var containerStack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        return view
    }()
    
    lazy var keywordLabel: UILabel = {
        let view = UILabel()
        return view
    }()
    
    private var currentConfiguration: SearchTerm!
    var configuration: UIContentConfiguration {
        get {
            currentConfiguration
        }
        set {
            guard let configuration = newValue as? SearchTerm else { return }
            apply(configuration: configuration)
        }
    }
    
    init(with contentConfiguration: UIContentConfiguration) {
        super.init(frame: .zero)
        setupView()
        setupConstraints()
        apply(configuration: contentConfiguration as! SearchTerm)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func apply(configuration: SearchTerm) {
        if currentConfiguration == configuration {
            return
        }
        currentConfiguration = configuration
        
        keywordLabel.text = configuration.keyword
    }
}

extension SearchTermContentView: ViewableProtocol {
    func setupView() {
        self.addSubview(containerStack)
        [keywordLabel].forEach {
            containerStack.addArrangedSubview($0)
        }
    }
    
    func setupConstraints() {
        containerStack.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(10)
        }
    }
}
