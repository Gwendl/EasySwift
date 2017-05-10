//
//  ViewUseful.swift
//  app
//
//  Created by Adrien morel on 07/03/2017.
//  Copyright © 2017 ZiggTime. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

class EasyButton: UIButton {
    
    public var onClick: (() -> ())? {
        didSet {
            self.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        }
    }
    public var onTurnOn: Useful.Callback?
    public var onTurnOff: Useful.Callback?
    public var on = false {
        didSet {
            
            let oldImage = self.imageView?.image
            let newImage = self.on ? self.imageOn : self.imageOff
            
            let crossFade = CABasicAnimation(keyPath: "contents")
            crossFade.duration = 0.3
            crossFade.fromValue = oldImage?.cgImage
            crossFade.toValue = newImage?.cgImage
            crossFade.isRemovedOnCompletion = false
            crossFade.fillMode = kCAFillModeForwards
            imageView?.layer.add(crossFade, forKey: "animateContents")
            setImage(newImage, for: .normal)
        }
    }
    public var imageOn: UIImage?
    public var imageOff: UIImage?
    
    public func becomeToggleImageButton(on onImg: UIImage, off offImg: UIImage, onTurnOn: @escaping Useful.Callback, onTurnOff: @escaping Useful.Callback) {
        imageOn = onImg
        imageOff = offImg
        self.onTurnOn = onTurnOn
        self.onTurnOff = onTurnOff
        self.addTarget(self, action: #selector(onToggle(_:)), for: .touchUpInside)
    }
    
    @objc private func onToggle(_ sender: EasyButton) {
        setButtonStatus(!on)
    }
    
    @objc private func click(_ sender: EasyButton) {
        onClick?()
    }
    
    public func setButtonStatus(_ on: Bool) {
        self.on = on
        
        if on {
            onTurnOn?()
        } else {
            onTurnOff?()
        }
    }
}

class ViewUseful {
    
    public static func setStatusBarColor(_ color: UIColor) {
        UIApplication.shared.statusBarView?.backgroundColor = color
    }
    
    public static func instanceFromNib(_ fileName: String) -> UIView {
        return UINib(nibName: fileName, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
}

extension UIView {
    
    public func move(x: CGFloat, y: CGFloat) {
        
        let newFrame = CGRect(x: x, y: y, width: frame.width, height: frame.height)
        self.frame = newFrame
    }
    
    public func rounded() {
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
    
    public func fadeIn() {
        
        alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.alpha = 1
        }
    }
    
    public func fadeOut() {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.alpha = 0
        }, completion: { (finished: Bool) in
            self.removeFromSuperview()
        })
    }
    
    public func setScaledDown() {
        self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        self.isHidden = true
    }
    
    public func setScaledUp() {
        self.transform = CGAffineTransform(scaleX: 1, y: 1)
        self.isHidden = false
    }
    
    public func scaleUp() {
        self.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    public func scaleDown() {
        UIView.animate(withDuration: 0.2, animations: {
            self.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }, completion: { _ in
            self.isHidden = true
        })
    }
    
    public func getSuperviewOfType<T>() -> T? {
        
        var spv = superview
        while spv != nil && spv as? T == nil {
            spv = spv?.superview
        }
        return spv as? T
    }
    
    public func onClick(_ closure: @escaping () -> ()) {
        self.tag = closuresHolder.count
        let holder = ClosureHolder(closure)
        closuresHolder.append(holder)
        
        let tapGesture = UITapGestureRecognizer(target: holder, action: #selector(ClosureHolder.click(_:)))
        addGestureRecognizer(tapGesture)
    }
}

var closuresHolder = [ClosureHolder]()

class ClosureHolder {
    let closure: (() -> ())
    
    init(_ closure: @escaping () -> ()) {
        self.closure = closure
    }
    
    @objc func click(_ sender: UIView) {
        closure()
    }
}
