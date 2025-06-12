//
//  AquaListViewCell.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/14.
//

import UIKit
import SnapKit
import Kingfisher

class AquaListViewCell: UITableViewCell {

    static let identifier = "AquaListViewCell"
    let aquaListCV: AquaListContentView = AquaListContentView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        configureView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        aquaListCV.knameLabel.text = ""
        aquaListCV.enameLabel.text = ""
        aquaListCV.categoryLabel.text = ""
        aquaListCV.tagListView.removeAllTags()
    }
    
    func fill(item: Aqua) {
        aquaListCV.knameLabel.text = item.kname
        aquaListCV.enameLabel.text = item.ename
        aquaListCV.categoryLabel.text = item.category
        aquaListCV.tagListView.addTags(tags: [item.nose?[0] ?? "", item.palate?[0] ?? "", item.finish?[0] ?? ""])
        
        let deaultImage = UIImage(named: "Bottle")!
            .withTintColor(.CustomColor.subTextColor, renderingMode: .alwaysOriginal)
        
        if let urlString = item.image {
            guard let url = URL(string: urlString) else { return }
            let processor = DownsamplingImageProcessor(
                size: CGSize(width: 250, height: 250))
            aquaListCV.imageView.kf.indicatorType = .activity
            
            KF.url(url)
                .setProcessor(processor)
                .placeholder(deaultImage)
                .retry(maxCount: 2, interval: .seconds(4))
                .transition(.fade(0.7))
                .set(to: aquaListCV.imageView)
        }
    }
}

extension AquaListViewCell: ViewableProtocol {
    func setupView() {
        addSubview(aquaListCV)
    }
    
    func configureView() {
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        backgroundColor = .CustomColor.backgroundColor
    }
    
    func setupConstraints() {
        aquaListCV.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
