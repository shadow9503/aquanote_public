//
//  NoteListViewCell.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/06.
//

import UIKit
import SnapKit
import Kingfisher

class NoteListViewCell: UITableViewCell {

    static let identifier = "NoteListViewCell"
    let noteListCV: NoteListContentView = NoteListContentView()
    
    override var isEditing: Bool {
        didSet {
            if isEditing {
                UIView.animate(withDuration: 0.25) {
                    self.noteListCV.checkButton.snp.removeConstraints()
                    self.noteListCV.checkButton.snp.makeConstraints {
                        $0.width.equalTo(self.noteListCV.containerView).multipliedBy(0.1)
                    }
                    self.noteListCV.superview?.layoutIfNeeded()
                }
            } else {
                self.noteListCV.checkButton.snp.removeConstraints()
                self.noteListCV.checkButton.snp.makeConstraints {
                    $0.width.equalTo(self.noteListCV.containerView.snp.width).multipliedBy(0)
                }
                self.noteListCV.superview?.layoutIfNeeded()
            }
        }
    }
    
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
        noteListCV.checkButton.isSelected = noteListCV.checkButton.isSelected ? false: selected
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        noteListCV.checkButton.isSelected = false
        noteListCV.imageView.image = nil
        noteListCV.titleLabel.text = nil
        noteListCV.categoryLabel.text = nil
        noteListCV.commentLabel.text = nil
//        noteListCV.backupStatusView.isHidden = true
    }
    
    func fill(note: Note) {
        noteListCV.checkButton.isSelected = isSelected
        noteListCV.titleLabel.text = note.title
        noteListCV.categoryLabel.text = note.category == "" ? "-" : note.category
        noteListCV.commentLabel.text = note.comment
//        noteListCV.backupStatusView.isHidden = note.isBackup
        
        let deaultImage = UIImage(named: "Bottle")!
            .withTintColor(.CustomColor.subTextColor, renderingMode: .alwaysOriginal)
        
        if let urlString = note.images?.first {
            guard let url = URL(string: urlString) else { return }
            let processor = DownsamplingImageProcessor(
                size: CGSize(width: 250, height: 250))
            noteListCV.imageView.kf.indicatorType = .activity
            
            KF.url(url)
                .setProcessor(processor)
                .placeholder(deaultImage)
                .retry(maxCount: 2, interval: .seconds(4))
                .transition(.fade(0.7))
                .set(to: noteListCV.imageView)
        } else {
            noteListCV.imageView.image = deaultImage
        }
    }
}

extension NoteListViewCell: ViewableProtocol {
    func setupView() {
        contentView.addSubview(noteListCV)
    }
    
    func configureView() {
        contentView.backgroundColor = .CustomColor.backgroundColor
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    func setupConstraints() {
        noteListCV.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
