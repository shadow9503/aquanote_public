//
//  NoResultsCell.swift
//  aquanote
//
//  Created by 유영훈 on 2023/02/15.
//

import UIKit
import SnapKit

class NoResultsCell: UITableViewCell {
    
    static let identifier = "NoResultsCell"
    
//    var requestButton: PaddingButton = {
//        let view = PaddingButton(padding: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
//        view.setTitle("\"해줘\"", for: .normal)
//        view.setTitleColor(.CustomColor.mainTextColor, for: .normal)
//        view.titleLabel?.font = UIFont.CustomFont.baseM
//        view.layer.cornerRadius = 17
//        view.isUserInteractionEnabled = false
//        view.layer.shadowColor = UIColor.black.cgColor
//        view.layer.shadowOffset = CGSizeMake(1, 2)
//        view.layer.shadowOpacity = 0.5
//        view.layer.shadowRadius = 3
//        return view
//    }()
    
    var messageLabel: UILabel = {
        let view = UILabel()
        view.text = "아직 등록되지 않은 주류가 많아요 :(\n빠른 시일에 추가해볼게요!" //"찾을 수 없는 술이에요\n 추가를 원하신다면..."
        view.textColor = .CustomColor.mainTextColor
        view.font = .CustomFont.base
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .CustomColor.backgroundColor
        selectionStyle = .none
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 7
        
        contentView.addSubview(stack)
        
//        let emptyView = UIView()
//        emptyView.addSubview(requestButton)
        
        [messageLabel].forEach {
            stack.addArrangedSubview($0)
        }
        
        stack.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(15)
        }
        
//        requestButton.snp.makeConstraints {
//            $0.centerX.equalToSuperview()
//            $0.top.bottom.equalToSuperview()
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
