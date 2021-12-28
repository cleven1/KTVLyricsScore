//
//  AgoraMusicLrcCell.swift
//  AgoraKaraokeScore
//
//  Created by zhaoyongqiang on 2021/12/10.
//

import UIKit

class AgoraMusicLrcCell: UITableViewCell {
    private lazy var lrcLabel: AgoraLrcLabel = {
        let label = AgoraLrcLabel()
        label.text = "歌词"
        label.textColor = .blue
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()

    var lrcConfig: AgoraLrcConfigModel? {
        didSet {
            lrcLabel.textColor = lrcConfig?.lrcNormalColor
            lrcLabel.lrcHighlightColor = lrcConfig?.lrcHighlightColor
            lrcLabel.font = lrcConfig?.lrcFontSize
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupMusicLrcProgress(with progress: CGFloat) {
        lrcLabel.progress = progress
        lrcLabel.font = lrcConfig?.lrcHighlightFontSize
    }

    func setupMusicLrc(with lrcModel: AgoraMiguLrcSentence?,
                       progress: CGFloat) {
        lrcLabel.text = lrcModel?.toSentence()
        lrcLabel.progress = progress
        lrcLabel.font = lrcConfig?.lrcFontSize
    }

    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        lrcLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(lrcLabel)
        lrcLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        lrcLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        lrcLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        lrcLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
}

class AgoraLrcLabel: UILabel {
    var lrcHighlightColor: UIColor?
    var progress: CGFloat = 0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        super.drawText(in: rect)
        let fillRext = CGRect(x: 0,
                              y: 0,
                              width: bounds.width * progress,
                              height: bounds.height)
        lrcHighlightColor?.set()
        UIRectFillUsingBlendMode(fillRext, .sourceIn)
    }
}
