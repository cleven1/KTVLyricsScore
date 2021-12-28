//
//  AgoraLrcConfigModel.swift
//  AgoraKaraokeScore
//
//  Created by zhaoyongqiang on 2021/12/17.
//

import UIKit

public struct AgoraLrcConfigModel {
    /// 无歌词提示文案
    public var tipsString: String = "纯音乐，无歌词"
    /// 提示文字颜色
    public var tipsColor: UIColor = .black
    /// 提示文字大小
    public var tipsFont: UIFont = .systemFont(ofSize: 17)
    /// 分割线的颜色
    public var separatorLineColor: UIColor = .lightText
    /// 默认歌词背景色
    public var lrcNormalColor: UIColor = .gray
    /// 高亮歌词背景色
    public var lrcHighlightColor: UIColor = .orange
    /// 歌词文字大小 默认: 15
    public var lrcFontSize: UIFont = .systemFont(ofSize: 15)
    /// 歌词高亮文字大小 默认: 18
    public var lrcHighlightFontSize: UIFont = .systemFont(ofSize: 15)
}
