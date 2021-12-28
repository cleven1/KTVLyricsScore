//
//  AgoraLrcView.swift
//  AgoraKaraokeScore
//
//  Created by zhaoyongqiang on 2021/12/10.
//

import UIKit

class AgoraLrcView: UIView {
    /// 滚动歌词后设置播放器时间
    var seekToTime: ((TimeInterval) -> Void)?
    /// 当前播放的歌词
    var currentPlayerLrc: ((String, CGFloat) -> Void)?

    var lrcConfig: AgoraLrcConfigModel = .init() {
        didSet {
            updateUI()
        }
    }

    var miguSongModel: AgoraMiguSongLyric? {
        didSet {
            dataArray = miguSongModel?.sentences
        }
    }

    private var dataArray: [AgoraMiguLrcSentence]? {
        didSet {
            tableView.reloadData()
        }
    }

    private var progress: CGFloat = 0 {
        didSet {
            let cell = tableView.cellForRow(at: IndexPath(row: scrollRow, section: 0)) as? AgoraMusicLrcCell
            cell?.setupMusicLrcProgress(with: progress)
        }
    }

    /// 当前歌词所在的位置
    private var preRow: Int = 0
    private var scrollRow: Int = -1 {
        didSet {
            if scrollRow == oldValue { return }
            if preRow > 0 {
                tableView.reloadRows(at: [IndexPath(row: preRow, section: 0)], with: .none)
            }
            tableView.scrollToRow(at: IndexPath(row: scrollRow, section: 0), at: .middle, animated: true)
            preRow = scrollRow
        }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.scrollsToTop = false
        tableView.register(AgoraMusicLrcCell.self, forCellReuseIdentifier: "AgoaraLrcViewCell")
        return tableView
    }()

    /** 提示 */
    private lazy var tipsLabel: UILabel = {
        let view = UILabel()
        view.textColor = .blue
        view.text = "纯音乐，无歌词"
        view.font = .systemFont(ofSize: 17)
        view.isHidden = true
        return view
    }()

    private lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        view.isHidden = true
        return view
    }()

    private var isDragging: Bool = false {
        didSet {
            lineView.isHidden = !isDragging
        }
    }

    private var currentTime: TimeInterval = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let margin = tableView.frame.height * 0.5
        tableView.contentInset = UIEdgeInsets(top: 0,
                                              left: 0,
                                              bottom: margin,
                                              right: 0)
    }

    private func setupUI() {
        backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        lineView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tableView)
        tableView.addSubview(tipsLabel)
        addSubview(lineView)
        tableView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        tipsLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor).isActive = true
        tipsLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true

        lineView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        lineView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor).isActive = true

        updateUI()
    }

    func start(currentTime: TimeInterval) {
        if tableView.backgroundColor != .clear {
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
        }
        guard !(dataArray?.isEmpty ?? false) else { return }
        self.currentTime = currentTime * 1000
        updatePerSecond()
    }

    private func updateUI() {
        tipsLabel.text = lrcConfig.tipsString
        tipsLabel.textColor = lrcConfig.tipsColor
        tipsLabel.font = lrcConfig.tipsFont
        lineView.backgroundColor = lrcConfig.separatorLineColor
    }

    // MARK: - 更新歌词的时间

    private func updatePerSecond() {
        if let lrc = getLrc() {
            scrollRow = lrc.index ?? 0
            progress = lrc.progress ?? 0
//            print("progress == \(progress)")
            currentPlayerLrc?(lrc.lrcText ?? "", progress)
        }
    }

    // MARK: - 获取播放歌曲的信息
    private func getLrc() -> (index: Int?,
                              lrcText: String?,
                              progress: CGFloat?)?
    {
        guard let lrcArray = dataArray,
              !lrcArray.isEmpty else { return nil }
        var i = 0
        var progress: CGFloat = 0.0
        // 歌词滚动显示
        for (index, lrc) in lrcArray.enumerated() {
            let currentLrc = lrc
            var nextLrc: AgoraMiguLrcSentence?
            // 获取下一句歌词
            var nextStartTime: TimeInterval = 0
            if index == lrcArray.count - 1 {
                nextLrc = lrcArray[index]
                nextStartTime = nextLrc?.endTime() ?? 0
            } else {
                nextLrc = lrcArray[index + 1]
                nextStartTime = nextLrc?.startTime() ?? 0
            }
            if currentTime >= currentLrc.startTime(),
               currentLrc.startTime() > 0,
               currentTime < nextStartTime
            {
                i = index
                progress = (currentTime - currentLrc.startTime()) / (nextStartTime - currentLrc.startTime())
                return (i, currentLrc.toSentence(), progress)
            }
        }
        return nil
    }
}

extension AgoraLrcView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        dataArray?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AgoaraLrcViewCell", for: indexPath) as! AgoraMusicLrcCell
        cell.lrcConfig = lrcConfig
        let lrcModel = dataArray?[indexPath.row]
        cell.setupMusicLrc(with: lrcModel, progress: 0)
        return cell
    }

    func scrollViewWillBeginDragging(_: UIScrollView) {
        isDragging = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate _: Bool) {
        dragCellHandler(scrollView: scrollView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        dragCellHandler(scrollView: scrollView)
    }

    private func dragCellHandler(scrollView: UIScrollView) {
        isDragging = false
        let point = CGPoint(x: 0, y: scrollView.contentOffset.y + scrollView.bounds.height * 0.5)
        guard let indexPath = tableView.indexPathForRow(at: point) else { return }
        guard let model = dataArray?[indexPath.row] else { return }
        seekToTime?(model.startTime() / 1000)
    }
}
