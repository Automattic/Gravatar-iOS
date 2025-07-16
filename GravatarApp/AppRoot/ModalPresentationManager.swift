import SwiftUI

final class ModalPresentationManager: ObservableObject {
    @Published var content: (() -> AnyView)? = nil
    @Published var isShowingContent: Bool = false

    func present<Content: View>(@ViewBuilder content: @escaping () -> Content) {
        self.content = { AnyView(content()) }
        isShowingContent = true
    }

    func dismiss() {
        content = nil
        isShowingContent = false
    }
}

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

struct ModalPresentationTransition: Transition {
    func body(content: Content, phase: TransitionPhase) -> some View {
        content
            .opacity(phase.isIdentity ? 1 : 0)
            .offset(y: phase.isIdentity ? 0 : 100)
            .scaleEffect(phase.isIdentity ? 1 : 0.5)
    }
}

struct ModalView<Content: View>: View {
    @ViewBuilder let content: () -> Content

    @State var contentHeight: CGFloat = 0

    var body: some View {
        ScrollView {
            content()
                .contentHeightReader($contentHeight)
        }
        .scrollBounceBehavior(.basedOnSize)
        .background(.regularMaterial)
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 12, x: 0, y: 8)
        .frame(maxWidth: 500, maxHeight: contentHeight)
    }
}
