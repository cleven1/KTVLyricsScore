//
//  AgoraEmitterView.swift
//  AgoraKaraokeScore
//
//  Created by zhaoyongqiang on 2021/12/17.
//

import UIKit

class AgoraEmitterView: UIView {
    private var _emitter: CAEmitterLayer?
    private var emitter: CAEmitterLayer? {
        get {
            if _emitter == nil {
                // 1.创建发射器
                let emitter = CAEmitterLayer()
                // 2.设置发射器的位置
                emitter.emitterPosition = CGPoint(x: -100, y: 0)
                // 3.开启三维效果
                emitter.preservesDepth = true
                emitter.renderMode = .oldestLast
                emitter.masksToBounds = false
                emitter.emitterMode = .points
                emitter.emitterShape = .circle
                _emitter = emitter
                return emitter
            }
            return _emitter
        }
        set {
            _emitter = newValue
        }
    }
    private lazy var timer = GCDTimer()
    private var lastStartTime: CLongLong = 0
    private var lastEndTime: CFTimeInterval = 0
    
    public var config: AgoraScoreItemConfigModel? {
        didSet {
            emitter?.emitterCells?.removeAll()
            emitter = nil
            if config?.emitterImages == nil {
                let cells = config?.emitterColors.compactMap({ item -> CAEmitterCell in
                    let cell = createEmitterCell(name: "\(item.description)")
                    let image = UIImage(color: item,
                                        size: CGSize(width: 10, height: 10))?.toCircle()
                    cell.contents = image?.cgImage
                    return cell
                })
                emitter?.emitterCells = cells
            } else {
                let cells = config?.emitterImages?.compactMap({ item -> CAEmitterCell in
                    let cell = createEmitterCell(name: "\(item.description)")
                    cell.contents = item.cgImage
                    return cell
                })
                emitter?.emitterCells = cells
            }
            layer.addSublayer(emitter!)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initTimerHandler() {
        if timer.isExistTimer(withName: "stopEmitter") { return }
        let time = CACurrentMediaTime()
        if time - lastEndTime >= 0.75 {
            emitter?.beginTime = CACurrentMediaTime()
        }
        timer.scheduledMillisecondsTimer(withName: "stopEmitter",
                                         countDown: 1000000,
                                         milliseconds: 50,
                                         queue: .main) { _, _ in
            self.stopEmittering()
        }
    }
    
    private func createEmitterCell(name: String) -> CAEmitterCell {
        // 4.创建粒子, 并且设置例子相关的属性
        let cell = CAEmitterCell()
        // 4.2.设置粒子速度
        cell.velocity = 1
        cell.velocityRange = 1
        // 4.3.设置例子的大小
        cell.scale = 0.6
        cell.scaleRange = 0.3
        // 4.4.设置粒子方向
        cell.emissionLongitude = CGFloat.pi * 3
        cell.emissionRange = CGFloat.pi / 6
        // 4.5.设置例子的存活时间
        cell.lifetime = 3
        cell.lifetimeRange = 2.5
        // 4.6.设置粒子旋转
        cell.spin = CGFloat.pi / 2
        cell.spinRange = CGFloat.pi / 4
        // 4.6.设置例子每秒弹出的个数
        let count = Float(config?.emitterColors.count ?? config?.emitterImages?.count ?? 0)
        cell.birthRate = count < 3 ? 3 :count
        cell.alphaRange = 0.75
        cell.alphaSpeed = -0.35
        // 4.7.设置粒子展示的图片
//        cell.contents = UIImage()?.cgImage
        // 初始速度
        cell.velocity = 90

        cell.name = name
        return cell
    }
    
    func setupEmitterPoint(point: CGPoint) {
        guard lastStartTime > 0 else { return }
        emitter?.emitterPosition = point
    }

    func startEmittering() {
        let current = Date().milliStamp
        emitter?.birthRate = 1
        lastStartTime = current
        initTimerHandler()
    }
    
    /// 移除CAEmitterLayer
    func stopEmittering() {
        guard lastStartTime > 0 else { return }
        let current = Date().milliStamp
        let realTime = current - lastStartTime
        if realTime > CLongLong(0.75 * 1000) {
            emitter?.birthRate = 0
            timer.destoryTimer(withName: "stopEmitter")
            lastStartTime = 0
            lastEndTime = CACurrentMediaTime()
        }
    }
}

extension Date {

  /// 获取当前 毫秒级 时间戳 - 13位
  var milliStamp: CLongLong {
    let timeInterval: TimeInterval = self.timeIntervalSince1970
    let millisecond = CLongLong(round(timeInterval*1000))
    return millisecond
  }
}

private extension UIImage {
    convenience init?(color: UIColor,
                      size: CGSize = CGSize(width: 1, height: 1))
    {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }

    // 生成圆形图片
    func toCircle() -> UIImage {
        // 取最短边长
        let shotest = min(size.width, size.height)
        // 输出尺寸
        let outputRect = CGRect(x: 0, y: 0, width: shotest, height: shotest)
        // 开始图片处理上下文（由于输出的图不会进行缩放，所以缩放因子等于屏幕的scale即可）
        UIGraphicsBeginImageContextWithOptions(outputRect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()!
        // 添加圆形裁剪区域
        context.addEllipse(in: outputRect)
        context.clip()
        // 绘制图片
        draw(in: CGRect(x: (shotest - size.width) / 2,
                        y: (shotest - size.height) / 2,
                        width: size.width,
                        height: size.height))
        // 获得处理后的图片
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return maskedImage
    }
}
