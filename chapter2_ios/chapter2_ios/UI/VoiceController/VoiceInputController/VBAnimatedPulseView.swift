
import Foundation
import UIKit

@IBDesignable
class VBAnimatedPulseView: UIView {
    
    @IBInspectable var startColor: UIColor = UIColor.blue.withAlphaComponent(0.5)
    @IBInspectable var endColor: UIColor = UIColor.clear
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        gradientLayer.cornerRadius = bounds.width / 2.0
        gradientLayer.frame = bounds
        gradientLayer.masksToBounds = true
    }
    
    private lazy var gradientLayer: CAGradientLayer = {
        
        let sublayer = CAGradientLayer()
        sublayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        sublayer.endPoint = CGPoint(x: 1, y: 1)
        sublayer.type = .radial
        sublayer.colors = [ startColor.cgColor, endColor.cgColor]
        sublayer.locations = [ 0.5, 1.0]
        layer.addSublayer(sublayer)
        
        return sublayer
    }()
    
    //MARK: - deinit

    deinit{
        gradientLayer.removeFromSuperlayer()
    }
}
