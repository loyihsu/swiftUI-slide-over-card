/**
 # swiftui-slide-over-card

 Created by @mshafer and @cyrilzakka.
 Modified by @loyihsu to enable more customisation for more customisation for CardPositionHandling. (2021)
 */

import SwiftUI

public struct SlideOverCard<Content>: View where Content: View {
    @EnvironmentObject var position: CardPositionHandler
    @Binding var backgroundStyle: BackgroundStyle
    var content: () -> Content
    
    public init(backgroundStyle: Binding<BackgroundStyle> = .constant(.solid), content: @escaping () -> Content) {
        self.content = content
        self._backgroundStyle = backgroundStyle
    }
    
    public var body: some View {
        ModifiedContent(content: self.content(), modifier: Card(position: _position, backgroundStyle: self.$backgroundStyle))
    }
}

struct Card: ViewModifier {
    @EnvironmentObject var position: CardPositionHandler
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @GestureState var dragState: DragState = .inactive
    @Binding var backgroundStyle: BackgroundStyle
    @State var offset: CGSize = CGSize.zero
    
    var animation: Animation {
        Animation.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0)
    }
    
    var timer: Timer? {
        return Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
            if self.position.currentPosition == .top && self.dragState.translation.height == 0 {
                self.position.currentPosition = .top
            } else {
                timer.invalidate()
            }
        }
    }
    
    func body(content: Content) -> some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, _ in state = .dragging(translation: drag.translation) }
            .onChanged {_ in
                self.offset = .zero
            }
            .onEnded(onDragEnded)
        
        return ZStack(alignment: .top) {
            ZStack(alignment: .top) {
                
                if backgroundStyle == .blur {
                    BlurView(style: colorScheme == .dark ? .dark : .extraLight)
                }
                
                if backgroundStyle == .clear {
                    Color.clear
                }
                
                if backgroundStyle == .solid {
                    colorScheme == .dark ? Color.black : Color.white
                }
                
                Handle()
                content.padding(.top, 15)
            }
            .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(x: 1, y: 1, anchor: .center)
        }
        .offset(y: max(0, self.position.offsetFromTop() + self.dragState.translation.height))
        .animation((self.dragState.isDragging ? nil : animation))
        .gesture(drag)
    }
    
    private func onDragEnded(drag: DragGesture.Value) {
        // Setting stops
        let higherStop: CardPosition
        let lowerStop: CardPosition
        
        // Nearest position for drawer to snap to.
        let nearestPosition: CardPosition
        
        // Determining the direction of the drag gesture and its distance from the top
        let dragDirection = drag.predictedEndLocation.y - drag.location.y
        let offsetFromTopOfView = position.offsetFromTop() + drag.translation.height
        
        // Determining whether drawer is above or below `.partiallyRevealed` threshold for snapping behavior.
        if offsetFromTopOfView <= position.offsetFromTop(requested: .middle) {
            higherStop = .top
            lowerStop = .middle
        } else {
            higherStop = .middle
            lowerStop = .bottom
        }
        
        // Determining whether drawer is closest to top or bottom
        if (offsetFromTopOfView - position.offsetFromTop(requested: higherStop)) < (position.offsetFromTop(requested: lowerStop) - offsetFromTopOfView) {
            nearestPosition = higherStop
        } else {
            nearestPosition = lowerStop
        }
        
        // Determining the drawer's position.
        if dragDirection > 0 {
            position.currentPosition = lowerStop
        } else if dragDirection < 0 {
            position.currentPosition = higherStop
        } else {
            position.currentPosition = nearestPosition
        }
        _ = timer
    }
}

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}
