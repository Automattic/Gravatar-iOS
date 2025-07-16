import SwiftUI

extension View {
    func modalPresentation(manager: ModalPresentationManager) -> some View {
        self.overlay {
            ZStack {
                if let content = manager.content {
                    Color.black
                        .opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            manager.dismiss()
                        }
                        .transition(.opacity)
                    ModalView { content() }
                        .transition(ModalPresentationTransition())
                        .zIndex(100)
                        .environmentObject(manager)
                } else {
                    EmptyView()
                }
            }.animation(.smooth(duration: 0.35), value: manager.isShowingContent)
        }
    }
}

private struct ModalPresentationTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .opacity(phase.isIdentity ? 1 : 0)
            .offset(y: phase.isIdentity ? 0 : 100)
            .scaleEffect(phase.isIdentity ? 1 : 0.5)
    }
}
