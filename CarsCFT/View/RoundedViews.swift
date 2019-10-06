import Foundation
import UIKit

//Classes for rounded objects
class RoundedButton : UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 10  
    }
}

class RoundedShadowView: UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5  //Округление краев
        layer.shadowColor = AppColors.Blue.cgColor  //Задать цвет контура
        layer.shadowOpacity = 0.4 //Помутнение
        layer.shadowOffset = CGSize.zero //смещение тени
        layer.shadowRadius = 3
    }
}
class RoundedImageView: UIImageView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5 //Округление краев
    }
}
