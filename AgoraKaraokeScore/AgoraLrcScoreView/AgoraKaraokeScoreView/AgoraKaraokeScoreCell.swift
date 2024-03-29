//
//  AgoraKaraokeScoreCell.swift
//  lineTTTT
//
//  Created by zhaoyongqiang on 2021/12/8.
//  Copyright © 2021 km. All rights reserved.
//

import UIKit

class AgoraKaraokeScoreCell: UICollectionViewCell {
    private var scoreLayer: CAShapeLayer?
    private lazy var scoreLineView: UIView = {
        let view = UIView(frame: contentView.frame)
        view.isHidden = true
        view.backgroundColor = .gray
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    private let label = UILabel()
    private var startPoi: CGFloat = 0
    private var scoreModel: AgoraScoreItemModel?
    private var scoreConfig: AgoraScoreItemConfigModel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        contentView.addSubview(scoreLineView)
        contentView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        label.textColor = .white
    }

    func setScore(with model: AgoraScoreItemModel?,
                  config: AgoraScoreItemConfigModel)
    {
        guard let model = model else { return }
        let time = (model.endTime - model.startTime).keep2
        label.text = model.word + "\(time)"
        label.isHidden = true
        scoreModel = model
        scoreConfig = config
        scoreLineView.isHidden = model.isEmptyCell
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        scoreLineView.frame = CGRect(x: 0,
                                     y: model.top,
                                     width: model.width,
                                     height: config.lineHeight)
        scoreLineView.backgroundColor = config.normalColor
        scoreLineView.layer.cornerRadius = config.lineHeight * 0.5
        keepAddingMaskLayer(offsetX: model.offsetX)
        CATransaction.commit()
    }

    private func keepAddingMaskLayer(offsetX: CGFloat) {
        guard let model = scoreModel else { return }
        let hasLayer: Bool = (scoreLineView.layer.sublayers?.count ?? 0) != 0
        switch model.status {
        case .`init`:
            if hasLayer {
                scoreLineView.layer.sublayers?.forEach {
                    $0.removeFromSuperlayer()
                }
            } else {
                scoreLayer = CAShapeLayer()
                scoreLayer?.fillColor = scoreConfig?.highlightColor.cgColor
                scoreLayer?.lineCap = .round
            }
            return
        case .new_layer:
            stopAddingMaskLayer(offsetX: offsetX)
            return
        case .end:
            return;

        default: break
        }
        let layerL = hasLayer ? (startPoi - model.left) : startPoi
        let layerW = offsetX - (hasLayer ? startPoi : model.left)
        let lineH = scoreConfig?.lineHeight ?? 5
        scoreLayer?.path = UIBezierPath(roundedRect: CGRect(x: layerL,
                                                            y: 0,
                                                            width: layerW,
                                                            height: lineH),
                                        cornerRadius: lineH * 0.5).cgPath
        if let layer = scoreLayer, model.isEmptyCell == false {
            scoreLineView.layer.addSublayer(layer)
        }
    }

    private func stopAddingMaskLayer(offsetX: CGFloat) {
        scoreLayer = CAShapeLayer()
        scoreLayer?.fillColor = scoreConfig?.highlightColor.cgColor
        scoreLayer?.lineCap = .round
        startPoi = offsetX
    }
}

extension Double {
    /// 保留2位小数
    var keep2: Double {
        return Double(Darwin.round(self * 100)/100)
    }
}
