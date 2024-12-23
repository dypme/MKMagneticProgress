//
// Copyright (c) 2017 malkouz
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

// MARK: - Line Cap Enum

public enum LineCap : Int{
    case round, butt, square
    
    public func style() -> CAShapeLayerLineCap {
        switch self {
        case .round:
            return CAShapeLayerLineCap.round
        case .butt:
            return CAShapeLayerLineCap.butt
        case .square:
            return CAShapeLayerLineCap.square
        }
    }
}

// MARK: - Orientation Enum

public enum Orientation: Int  {
    case left, top, right, bottom
    
}

public class MKExtraProgress {
    let start: CGFloat
    let end: CGFloat
    let color: UIColor
    
    fileprivate var layer: CAShapeLayer!
    
    public init(start: CGFloat, end: CGFloat, color: UIColor) {
        self.start = max(start, 0.0)
        self.end = min(end, 1.0)
        self.color = color
    }
}

@IBDesignable
open class MKMagneticProgress: UIView {
    
    // MARK: - Variables
    private let titleLabelWidth: CGFloat = 100
    
    private let percentLabel = UILabel(frame: .zero)
    @IBInspectable open var titleLabel = UILabel(frame: .zero)
    
    /// Stroke background color
    @IBInspectable open var clockwise: Bool = true {
        didSet {
            layoutSubviews()
        }
    }
    
    /// Stroke background color
    @IBInspectable open var backgroundShapeColor: UIColor = UIColor(white: 0.9, alpha: 0.5) {
        didSet {
            updateShapes()
        }
    }
    
    /// Progress stroke color
    @IBInspectable open var progressShapeColor: UIColor   = .blue {
        didSet {
            updateShapes()
        }
    }
    
    /// Line width
    @IBInspectable open var lineWidth: CGFloat = 8.0 {
        didSet {
            updateShapes()
        }
    }
    
    /// Space value
    @IBInspectable open var spaceDegree: CGFloat = 45.0 {
        didSet {
//            if spaceDegree < 45.0{
//                spaceDegree = 45.0
//            }
//            
//            if spaceDegree > 135.0{
//                spaceDegree = 135.0
//            }
            
            layoutSubviews()

            updateShapes()
        }
    }
    
    /// The progress shapes line width will be the `line width` minus the `inset`.
    @IBInspectable open var inset: CGFloat = 0.0 {
        didSet {
            updateShapes()
        }
    }
    
    // The progress percentage label(center label) format
    @IBInspectable open var percentLabelFormat: String = "%.f %%" {
        didSet {
            percentLabel.text = String(format: percentLabelFormat, progress * 100)
        }
    }
    
    @IBInspectable open var percentColor: UIColor = UIColor(white: 0.9, alpha: 0.5) {
        didSet {
            percentLabel.textColor = percentColor
        }
    }
    
    
    /// progress text (progress bottom label)
    @IBInspectable open var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBInspectable open var titleColor: UIColor = UIColor(white: 0.9, alpha: 0.5) {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    
    
    // progress text (progress bottom label)
    @IBInspectable  open var font: UIFont = .systemFont(ofSize: 13) {
        didSet {
            titleLabel.font = font
            percentLabel.font = font
        }
    }
    
    
    // progress Orientation
    open var orientation: Orientation = .bottom {
        didSet {
            updateShapes()
        }
    }

    /// Progress shapes line cap.
    open var lineCap: LineCap = .round {
        didSet {
            updateShapes()
        }
    }
    
    /// Returns the current progress.
    @IBInspectable open private(set) var progress: CGFloat {
        set {
            progressShape?.strokeEnd = newValue
            extraProgress.forEach { extra in
                extra.layer?.strokeEnd = min(extra.end, newValue)
            }
        }
        get {
            return progressShape.strokeEnd
        }
    }
    
    /// Duration for a complete animation from 0.0 to 1.0.
    open var completeDuration: Double = 0.7
    
    open var extraProgress: [MKExtraProgress] = [] {
        didSet {
            setupExtras()
            updateShapes()
        }
    }
    
    private var backgroundShape: CAShapeLayer!
    private var progressShape: CAShapeLayer!
    
    private var progressAnimation: CABasicAnimation!
    
    // MARK: - Init
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        
        backgroundShape = CAShapeLayer()
        backgroundShape.fillColor = nil
        backgroundShape.strokeColor = backgroundShapeColor.cgColor
        layer.addSublayer(backgroundShape)
        
        progressShape = CAShapeLayer()
        progressShape.fillColor   = nil
        progressShape.strokeStart = 0.0
        progressShape.strokeEnd   = 0.1
        layer.addSublayer(progressShape)
        
        progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        percentLabel.frame = self.bounds
        percentLabel.textAlignment = .center
//        percentLabel.textColor = self.progressShapeColor
        self.addSubview(percentLabel)
        percentLabel.text = String(format: "%.1f%%", progress * 100)
        
        
        titleLabel.frame = CGRect(x: (self.bounds.size.width-titleLabelWidth)/2, y: self.bounds.size.height-21, width: titleLabelWidth, height: 21)
        
        titleLabel.textAlignment = .center
//        titleLabel.textColor = self.progressShapeColor
        titleLabel.text = title
        titleLabel.contentScaleFactor = 0.3
        //        textLabel.adjustFontSizeToFit()
        titleLabel.numberOfLines = 2
        
        //textLabel.adjustFontSizeToFit()
        titleLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(titleLabel)
    }
    
    private func setupExtras() {
        layer.sublayers?.forEach({ layer in
            if layer.name == "extra" {
                layer.removeFromSuperlayer()
            }
        })
        extraProgress.forEach { extra in
            let newLayer = CAShapeLayer()
            newLayer.name = "extra"
            newLayer.fillColor   = nil
            newLayer.strokeStart = extra.start
            newLayer.strokeEnd   = min(extra.end, progress)
            layer.addSublayer(newLayer)
            extra.layer = newLayer
        }
    }
    
    // MARK: - Progress Animation
    
    public func setProgress(progress: CGFloat, animated: Bool = true) {
        if progress > 1.0 {
            return
        }
        
        var start = progressShape.strokeEnd
        if let presentationLayer = progressShape.presentation(){
            if let count = progressShape.animationKeys()?.count, count > 0  {
                start = presentationLayer.strokeEnd
            }
        }
        
        let duration = abs(Double(progress - start)) * completeDuration
        percentLabel.text = String(format: percentLabelFormat, progress * 100)
        progressShape.strokeEnd = progress
        extraProgress.forEach { extra in
            extra.layer?.strokeEnd = min(extra.end, progress)
        }
        
        if animated {
            progressAnimation.fromValue = start
            progressAnimation.toValue   = progress
            progressAnimation.duration  = duration
            progressShape.add(progressAnimation, forKey: progressAnimation.keyPath)
            extraProgress.forEach { extra in
                let introAnimation = CABasicAnimation(keyPath: "strokeEnd")
                introAnimation.fromValue = min(start, extra.end)
                introAnimation.toValue   = min(start, extra.end)
                introAnimation.duration  = max(max(extra.start - start, start - extra.end), 0.0) * completeDuration

                let progressAnimation = CABasicAnimation(keyPath: "strokeEnd")
                progressAnimation.beginTime = introAnimation.duration
                let from = min(max(start, extra.start), extra.end)
                let to = max(min(extra.end, progress), extra.start)
                progressAnimation.fromValue = from
                progressAnimation.toValue   = to
                progressAnimation.duration  = abs(to - from) * completeDuration
                
                let outroAnimation = CABasicAnimation(keyPath: "strokeEnd")
                outroAnimation.beginTime = introAnimation.duration + progressAnimation.duration
                outroAnimation.fromValue = to
                outroAnimation.toValue   = to
                outroAnimation.duration = duration - outroAnimation.beginTime
                
                let groupAnimation = CAAnimationGroup()
                groupAnimation.duration = duration
                groupAnimation.animations = [introAnimation, progressAnimation, outroAnimation]
                
                extra.layer.add(groupAnimation, forKey: nil)
            }
        }
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews() {
        
        super.layoutSubviews()
        
        backgroundShape.frame = bounds
        progressShape.frame   = bounds
        extraProgress.forEach({ $0.layer.frame = bounds })
        
        let rect = rectForShape()
        backgroundShape.path = pathForShape(rect: rect).cgPath
        progressShape.path   = pathForShape(rect: rect).cgPath
        extraProgress.forEach({ $0.layer.path = pathForShape(rect: rect).cgPath })
        
        self.titleLabel.frame = CGRect(x: (self.bounds.size.width - titleLabelWidth)/2, y: self.bounds.size.height-50, width: titleLabelWidth, height: 42)
        
        updateShapes()
        
        percentLabel.frame = self.bounds
    }
    
    private func updateShapes() {
        backgroundShape?.lineWidth  = lineWidth
        backgroundShape?.strokeColor = backgroundShapeColor.cgColor
        backgroundShape?.lineCap     = lineCap.style()
        
        progressShape?.strokeColor = progressShapeColor.cgColor
        progressShape?.lineWidth   = lineWidth - inset
        progressShape?.lineCap     = lineCap.style()
        extraProgress.forEach { extra in
            extra.layer.strokeColor = extra.color.cgColor
            extra.layer.lineWidth   = lineWidth - inset
            extra.layer.lineCap     = lineCap.style()
        }
        
        switch orientation {
        case .left:
            titleLabel.isHidden = true
            self.progressShape.transform = CATransform3DMakeRotation( CGFloat.pi / 2, 0, 0, 1.0)
            self.extraProgress.forEach({ $0.layer.transform = self.progressShape.transform })
            self.backgroundShape.transform = CATransform3DMakeRotation(CGFloat.pi / 2, 0, 0, 1.0)
        case .right:
            titleLabel.isHidden = true
            self.progressShape.transform = CATransform3DMakeRotation( CGFloat.pi * 1.5, 0, 0, 1.0)
            self.extraProgress.forEach({ $0.layer.transform = self.progressShape.transform })
            self.backgroundShape.transform = CATransform3DMakeRotation(CGFloat.pi * 1.5, 0, 0, 1.0)
        case .bottom:
            titleLabel.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [] , animations: { [weak self] in
                if let temp = self{
                    temp.titleLabel.frame = CGRect(x: (temp.bounds.size.width - temp.titleLabelWidth)/2, y: temp.bounds.size.height-50, width: temp.titleLabelWidth, height: 42)
                }

            }, completion: nil)
            self.progressShape.transform = CATransform3DMakeRotation( CGFloat.pi * 2, 0, 0, 1.0)
            self.extraProgress.forEach({ $0.layer.transform = self.progressShape.transform })
            self.backgroundShape.transform = CATransform3DMakeRotation(CGFloat.pi * 2, 0, 0, 1.0)
        case .top:
            titleLabel.isHidden = false
            UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.0, options: [] , animations: { [weak self] in
                if let temp = self{
                    temp.titleLabel.frame = CGRect(x: (temp.bounds.size.width - temp.titleLabelWidth)/2, y: 0, width: temp.titleLabelWidth, height: 42)
                }
                
                }, completion: nil)
            self.progressShape.transform = CATransform3DMakeRotation( CGFloat.pi, 0, 0, 1.0)
            self.extraProgress.forEach({ $0.layer.transform = self.progressShape.transform })
            self.backgroundShape.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1.0)
        }
    }
    
    // MARK: - Helper
    
    private func rectForShape() -> CGRect {
        return bounds.insetBy(dx: lineWidth / 2.0, dy: lineWidth / 2.0)
    }
    private func pathForShape(rect: CGRect) -> UIBezierPath {
        let startAngle: CGFloat!
        let endAngle: CGFloat!
        
        if clockwise {
            startAngle = CGFloat(spaceDegree * .pi / 180.0) + (0.5 * .pi)
            endAngle = CGFloat((360.0 - spaceDegree) * (.pi / 180.0)) + (0.5 * .pi)
        } else {
            startAngle = CGFloat((360.0 - spaceDegree) * (.pi / 180.0)) + (0.5 * .pi)
            endAngle = CGFloat(spaceDegree * .pi / 180.0) + (0.5 * .pi)
        }
        let path = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.size.width / 2.0, startAngle: startAngle, endAngle: endAngle
            , clockwise: clockwise)
    
        return path
    }
}

