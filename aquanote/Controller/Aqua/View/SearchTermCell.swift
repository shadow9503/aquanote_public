//
//  SearchTermCell.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/21.
//

import UIKit

class SearchTermCell: UITableViewCell {
    static let identifier = "SearchTermCell"
    var content: SearchTerm?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        separatorInset = .zero
        backgroundColor = .CustomColor.backgroundColor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var newConfiguration = SearchTerm().updated(for: state)
        newConfiguration.id = content!.id
        newConfiguration.keyword = content!.keyword
        newConfiguration.validation = content!.validation
        contentConfiguration = newConfiguration
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let originFrame = accessoryView?.frame else { return }
        let finalFrame = CGRect(x: originFrame.maxX - 10, y: 0, width: originFrame.width, height: originFrame.height)
        accessoryView?.frame = finalFrame
    }
}

