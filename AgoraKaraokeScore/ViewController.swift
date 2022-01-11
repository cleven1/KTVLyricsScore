//
//  ViewController.swift
//  AgoraKaraokeScore
//
//  Created by zhaoyongqiang on 2021/12/9.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    private lazy var lrcScoreView: AgoraLrcScoreView = {
        let lrcScoreView = AgoraLrcScoreView(delegate: self)
        lrcScoreView.config.scoreConfig.scoreViewHeight = 100
        lrcScoreView.config.scoreConfig.emitterColors = [.systemPink]
        lrcScoreView.config.lrcConfig.lrcFontSize = .systemFont(ofSize: 15)
        return lrcScoreView
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton()
        button.setTitle("播放", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(clickResetButton), for: .touchUpInside)
        return button
    }()
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .brown
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    private var timer = GCDTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
//        let imageView = UIImageView(image: UIImage(named: "bgImage"))
//        imageView.contentMode = .scaleAspectFill
//        lrcScoreView.config.backgroundImageView = imageView
        lrcScoreView.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lrcScoreView)
        view.addSubview(resetButton)
        lrcScoreView.downloadDelegate = self
        lrcScoreView.scoreDelegate = self
        lrcScoreView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lrcScoreView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        lrcScoreView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lrcScoreView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        resetButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        
        resetButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        resetButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        scoreLabel.topAnchor.constraint(equalTo: lrcScoreView.topAnchor, constant: 40).isActive = true
        
        setupPlayer()
        createData()
    }
    
    private func createData() {
        // 下载歌词
        lrcScoreView.setLrcUrl(url: "https://webdemo.agora.io/ktv/005.xml")
//        lrcScoreView.setLrcUrl(url: "https://accktv.sd-rtn.com/202201101620/1caec1a588dbb3d9faf3edf1bb58b5e7/release/lyric/lrc/1/0609f0627e114a669008d26e312f7613.lrc")
//        lrcScoreView.setLrcUrl(url: "https://accktv.sd-rtn.com/202201111036/09b56a1e7780ba864063c13547451259/release/lyric/zip_utf8/1/06fc83878ca54245855fdf5c0f9ddb25.zip")
//        lrcScoreView.setLrcUrl(url: "https://accktv.sd-rtn.com/202112301031/ac49974af7a4a5aae49ada78e691b0d2/release/lyric/zip_utf8/1/db4d162c37d64b189167362a156b7e0d.zip")
//        lrcScoreView.setLrcUrl(url: "https://accktv.sd-rtn.com/202112211435/bb7a8d52d3c4aaf40187aa1dbed49ee7/release/lyric/zip_utf8/1/71e2988a08dc4412b8573fbc47f5ffc3.zip")
    }
    
    private var audioPlayer: AVAudioPlayer?
    private func setupPlayer() {
//        let urlString = "https://accktv.sd-rtn.com/202112241044/ecc006b6c22bc65e6822ad00b2a2477f/release/1/da/mp3/17/ChmFDlpzSkmAAk30ACELt8Ha8aA517.mp3"
//        let urlString = "https://accktv.sd-rtn.com/202112301031/1c6bd64e40b04e7b90879c97799a6b39/release/mp3/1/7ae068/ChmFHFp91NqAO7RdACsP3Jpvwbc325.mp3"
        // 下载Mp3
//        AgoraDownLoadManager.manager.downloadMP3(urlString: urlString) { path in
//            let url = URL(fileURLWithPath: path ?? "")
//            self.audioPlayer = try? AVAudioPlayer(contentsOf: url)
//            self.audioPlayer?.rate = 1.0
//            self.audioPlayer?.prepareToPlay()
//        }
        let path = Bundle.main.path(forResource: "music", ofType: ".mp3")
        let url = URL(fileURLWithPath: path ?? "")
        audioPlayer = try? AVAudioPlayer(contentsOf: url)
        audioPlayer?.rate = 1.0
        audioPlayer?.prepareToPlay()
    }
    
    
    @objc
    private func clickResetButton() {
//        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        lrcScoreView.start()
        
        timer.scheduledMillisecondsTimer(withName: "aaa", countDown: 10000000, milliseconds: 200, queue: .main) { [weak self] _, duration in
            self?.setupTimer()
        }
    }
    
    private func setupTimer() {
        let voice = Double.random(in: 100...300)
//        let voice1 = Double.random(in: 80...200)
//        let voice2 = Double.random(in: 100...400)
//        let voice3 = Double.random(in: 55...250)
//        let voice4 = Double.random(in: 0...100)
        self.lrcScoreView.setVoicePitch([voice])
    }
}

extension ViewController: AgoraLrcViewDelegate {
    func getPlayerCurrentTime() -> TimeInterval {
        //        print("duration == \(audioPlayer?.currentTime ?? 0)")
        let time = (audioPlayer?.currentTime ?? 0)
        return time
    }
    
    func getTotalTime() -> TimeInterval {
        audioPlayer?.duration ?? 0
    }
    
    func seekToTime(time: TimeInterval) {
        audioPlayer?.currentTime = time
    }
}

extension ViewController: AgoraLrcDownloadDelegate {
    func beginDownloadLrc(url: String) {
//        print("开始下载 === \(url)")
    }
    func downloadLrcFinished(url: String) {
//        print("下载完成 == \(url)")
    }
    func downloadLrcProgress(url: String, progress: Double) {
        print("下载进度 == \(progress)")
    }
}

extension ViewController: AgoraKaraokeScoreDelegate {
    func agoraKaraokeScore(score: Double, totalScore: Double) {
        scoreLabel.text = "分数: \(score) 总分: \(Int(totalScore))"
    }
}
