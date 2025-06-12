//
//  ++UIColor.swift
//  aquanote
//
//  Created by 유영훈 on 2022/12/05.
//

import UIKit

extension UIColor {
    
    struct CustomColor {
        /// 백그라운드 - white/darkgray
        static var backgroundColor: UIColor { return UIColor(named: "BackgroundColor")! }
        /// 메인컬러1 - purple
        static var purple: UIColor { return UIColor(named: "MainColor1")! }
        /// 메인컬러2 - pink
        static var pink: UIColor { return UIColor(named: "MainColor2")! }
        /// 메인컬러3(태그) - darkpurple
        static var darkpurple: UIColor { return UIColor(named: "MainColor4")! }
        /// 컴포넌트 배경
        static var lightgray: UIColor { return UIColor(named: "ComponentBackgroundColor")! }
        /// 메인 텍스트 컬러 - black/white
        static var mainTextColor: UIColor { return UIColor(named: "PrimaryColor1")! }
        /// 서브 텍스트 컬러 - lightgray
        static var subTextColor: UIColor { return UIColor(named: "SubColor")! }
        /// 서브 타이틀
        static var darkGray: UIColor { return UIColor(named: "PrimaryColor2")! }
        static var darkGray2: UIColor { return UIColor(named: "Darkgray2")! }
        /// 각주 - lightText
        static var subColor: UIColor { return .lightText }
    }
}


