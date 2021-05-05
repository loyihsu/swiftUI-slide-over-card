/**
 # swiftui-slide-over-card

 Created by @mshafer and @cyrilzakka.
 Modified by @loyihsu to enable more customisation for more customisation for CardPositionHandling. (2021)
 */

import SwiftUI

public enum CardPosition {
    case bottom, middle, top
}

public class CardPositionHandler: ObservableObject {
    @Published public var currentPosition: CardPosition
    private var bottom: CGFloat
    private var middle: CGFloat
    private var top: CGFloat
    
    public init (currentPosition: CardPosition = .middle, bottom: CGFloat = UIScreen.main.bounds.height - 80, middle: CGFloat = UIScreen.main.bounds.height/1.8, top: CGFloat = 80) {
        self.currentPosition = currentPosition
        self.bottom = bottom
        self.middle = middle
        self.top = top
    }
    
    func offsetFromTop(requested: CardPosition? = nil) -> CGFloat {
        switch requested == nil ? self.currentPosition : requested {
        case .top: return self.top
        case .middle: return self.middle
        default: return self.bottom
        }
    }
}


