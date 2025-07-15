import SwiftUI

struct AnimatedHeaderScrollView<ContentView: View, ScrollableHeader: View, StickyHeader: View, MenuItems: View>: View {
    enum AnimationBehavior {
        case automatic
        case interactive
    }

    let animationBehavior: AnimationBehavior
    let scrollableHeader: (CGFloat) -> ScrollableHeader
    let stickyHeader: (CGFloat, EdgeInsets) -> StickyHeader
    let content: () -> ContentView
    let buttonMenuItems: () -> MenuItems
    let onRefresh: () async -> Void

    private let refreshOffsetThreshold: CGFloat = 80
    private let defaultTopPadding: CGFloat = .DS.Padding.double

    @State private var scrollableHeaderHeight: CGFloat = 0
    @State private var stickyHeaderHeight: CGFloat = 0

    @State private var scrollOffset: CGFloat = 0
    @State private var safeAreaInset: EdgeInsets = .init()
    @State private var isRefreshing: Bool = false
    // Force to release the scroll bounce before another refresh can be triggered
    @State private var canRefreshAgain: Bool = true

    private func loadingViewEffectValue(nominal: CGFloat, progressRatio: CGFloat) -> CGFloat {
        isRefreshing ? nominal : (canRefreshAgain && scrollOffset > 0 ? scrollOffset / progressRatio : 0)
    }

    private var scrollableHeaderTopPadding: CGFloat {
        (safeAreaInset.top == 0 ? defaultTopPadding : safeAreaInset.top) + (isRefreshing ? 44 : 0)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                OffsetReaderView(scrollOffset: $scrollOffset)
                VStack(alignment: .center) {
                    scrollableHeader(scrollableHeaderTopPadding)
                        .contentHeightReader($scrollableHeaderHeight)
                        .ignoresSafeArea(.container, edges: .horizontal)
                    content()
                }
            }
            .animation(.snappy, value: isRefreshing)
            .ignoresSafeArea(.container, edges: .top)
            .safeAreaInset(edge: .top) {
                RefreshControl(
                    animated: isRefreshing,
                    opacity: loadingViewEffectValue(nominal: 1, progressRatio: refreshOffsetThreshold)
                )
                .environment(\.colorScheme, .light)
                .scaleEffect(loadingViewEffectValue(nominal: 0.7, progressRatio: 80))
                .rotationEffect(.radians(loadingViewEffectValue(nominal: 0, progressRatio: 20)))
                .animation(.interpolatingSpring, value: isRefreshing)
                .padding(.top, safeAreaInset.top == 0 ? defaultTopPadding : 0)
            }
            .scrollDismissesKeyboard(.immediately)

            stickyHeader(stickyHeaderOpacity, safeAreaInset)
                .contentHeightReader($stickyHeaderHeight)
                .ignoresSafeArea(.container)
                .if(animationBehavior == .automatic) { view in
                    view.animation(.snappy(duration: 0.3), value: stickyHeaderOpacity)
                }

            HStack {
                Spacer()
                Menu {
                    buttonMenuItems()
                } label: {
                    EllipsisButton(action: {})
                }
            }
            .padding(.top, safeAreaInset.top == 0 ? defaultTopPadding : 0)
            .padding(.trailing, safeAreaInset.trailing == 0 ? 16 : 0)
        }
        .background(GeometryReader { geo in
            Color.clear
                .onChange(of: geo.safeAreaInsets) { _, value in
                    safeAreaInset = value
                }
                .onAppear {
                    safeAreaInset = geo.safeAreaInsets
                }
        })
        .onChange(of: scrollOffset) { _, newValue in
            if canRefreshAgain == false, newValue <= 0 {
                canRefreshAgain = true
            }
            guard isRefreshing == false, canRefreshAgain == true else { return }
            isRefreshing = newValue > refreshOffsetThreshold
        }
        .onChange(of: isRefreshing) { oldValue, newValue in
            if oldValue == false && newValue && canRefreshAgain {
                canRefreshAgain = false
                Task {
                    await doRefresh()
                }
            }
        }
    }

    func doRefresh() async {
        await onRefresh()
        isRefreshing = false
    }

    private var stickyHeaderOpacity: Double {
        let animationLength: CGFloat = 30
        let start = -(scrollableHeaderHeight - stickyHeaderHeight)

        if animationBehavior == .automatic {
            // 8 is a magic number found on testing. Not sure where is this being missed from.
            // My guess is the `OffsetReaderView` at the top of the scroll view.
            // Geometry reader uses a bit of vertical space to do its magic
            return scrollOffset >= (start - 8) ? 0 : 1
        }

        let end = start - animationLength

        if scrollOffset >= start {
            return 0
        } else if scrollOffset <= end {
            return 1
        } else {
            return (start - scrollOffset) / animationLength
        }
    }
}

#Preview("Avatar Picker Header") {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")

    AnimatedHeaderScrollView(animationBehavior: .automatic) { topPadding in
        AvatarPickerScrollableHeaderView(
            topPadding: topPadding,
            imageURL: imageURL,
            forceRefresh: .constant(false)
        )
    } stickyHeader: { opacity, safeAreaInsets in
        AvatarPickerStickyHeaderView(
            opacity: opacity,
            safeAreaInsets: safeAreaInsets,
            imageURL: imageURL,
            forceRefresh: .constant(false)
        )
    } content: {
        ForEach(0 ..< 20) { i in
            Text("Row \(i)")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
        }
    } buttonMenuItems: {
        Button(
            "Logout",
            systemImage: "iphone.and.arrow.forward.outward",
            role: .destructive
        ) {}
    } onRefresh: {
        try? await Task.sleep(for: .seconds(2))
    }
}

#if DEBUG
#Preview("Profile editor Header") {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")

    AnimatedHeaderScrollView(animationBehavior: .interactive) { topPadding in
        ProfileEditorScrollableHeaderView(
            profile: .testProfile,
            topPadding: topPadding,
            imageURL: imageURL,
            forceRefresh: .constant(false)
        )
    } stickyHeader: { opacity, safeAreaInsets in
        ProfileEditorStickyHeaderView(
            profile: .testProfile,
            opacity: opacity,
            safeAreaInsets: safeAreaInsets,
            imageURL: imageURL,
            forceRefresh: .constant(false)
        )
    } content: {
        ForEach(0 ..< 20) { i in
            Text("Row \(i)")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
        }
    } buttonMenuItems: {
        Button(
            "Logout",
            systemImage: "iphone.and.arrow.forward.outward",
            role: .destructive
        ) {}
    } onRefresh: {
        try? await Task.sleep(for: .seconds(2))
    }
}
#endif
