//
//  ++UIFont.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/05.
//

import UIKit

extension UIFont {
    
    enum CustomFontWeight: String {
        case light = "Light"
        case regular = "Regular"
        case medium = "Medium"
        case bold = "Bold"
    }
    
    struct CustomFont {
        /// regular 24 point
        static var title: UIFont { return UIFont(name: "NotoSansKR-Regular", size: 24)!}
        /// midium 24 point
        static var titleM: UIFont { return UIFont(name: "NotoSansKR-Medium", size: 24)!}
        /// regular 18 point
        static var subtitle: UIFont { return UIFont(name: "NotoSansKR-Regular", size: 18)!}
        /// midium 18 point
        static var subtitleM: UIFont { return UIFont(name: "NotoSansKR-Medium", size: 18)!}
        /// regular 16 point
        static var base: UIFont { return UIFont(name: "NotoSansKR-Regular", size: 16)!}
        /// midium 16 point
        static var baseM: UIFont { return UIFont(name: "NotoSansKR-Medium", size: 16)!}
        /// regular 14 point
        static var sub1: UIFont { return UIFont(name: "NotoSansKR-Regular", size: 14)!}
        /// midium 14 point
        static var sub1M: UIFont { return UIFont(name: "NotoSansKR-Medium", size: 14)!}
        /// regular 12 point
        static var sub2: UIFont { return UIFont(name: "NotoSansKR-Regular", size: 12)!}
        /// midium 12 point
        static var sub2M: UIFont { return UIFont(name: "NotoSansKR-Medium", size: 12)!}
    }
    
    static func customFont(_ weight: CustomFontWeight = .regular,_ size: Int = 16) -> UIFont {
        return UIFont(name: "NotoSansKR-\(weight.rawValue)", size: CGFloat(size))!
    }
}


