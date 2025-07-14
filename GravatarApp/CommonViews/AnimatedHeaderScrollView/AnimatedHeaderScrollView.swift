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

    @State private var scrollableHeaderHeight: CGFloat = 0
    @State private var stickyHeaderHeight: CGFloat = 0

    @State private var scrollOffset: CGFloat = 0
    @State private var safeAreaInset: EdgeInsets = .init()

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                OffsetReaderView(scrollOffset: $scrollOffset)
                VStack(alignment: .center) {
                    scrollableHeader(safeAreaInset.top)
                        .contentHeightReader($scrollableHeaderHeight)
                        .ignoresSafeArea(.container, edges: .horizontal)
                    content()
                }
            }
            .ignoresSafeArea(.container, edges: .top)
            .scrollDismissesKeyboard(.interactively)

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
            .padding(.top, safeAreaInset.top == 0 ? 16 : 0)
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

    AnimatedHeaderScrollView(animationBehavior: .automatic) { topSafeArea in
        AvatarPickerScrollableHeaderView(
            topSafeArea: topSafeArea,
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
    }
}

#if DEBUG
#Preview("Profile editor Header") {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/1?size=256")

    AnimatedHeaderScrollView(animationBehavior: .interactive) { topSafeArea in
        ProfileEditorScrollableHeaderView(
            profile: .testProfile,
            topSafeArea: topSafeArea,
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
    }
}
#endif
