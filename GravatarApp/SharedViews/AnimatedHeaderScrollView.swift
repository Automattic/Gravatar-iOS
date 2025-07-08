import SwiftUI
import GravatarUI

struct AnimatedHeaderScrollView<ContentView, ScrollableHeader, StickyHeader, MenuItems>: View
where ContentView: View, ScrollableHeader: View, StickyHeader: View, MenuItems: View {
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
                GeometryReader { geo in
                    Color.clear
                        .onChange(of: geo.frame(in: .global).minY) { _, value in
                            scrollOffset = value
                        }
                }
                .frame(height: 0)
                VStack(alignment: .center) {
                    scrollableHeader(safeAreaInset.top)
                        .background(
                            GeometryReader { geo in
                                Color.clear.onChange(of: geo.size) { _, value in
                                    self.scrollableHeaderHeight = value.height
                                }.onAppear {
                                    self.scrollableHeaderHeight = geo.size.height
                                }
                            }
                        )
                        .ignoresSafeArea(.container, edges: .horizontal)
                    content()
                }
                .scrollTargetLayout()

            }
            .ignoresSafeArea(.container, edges: .top)
            .onPreferenceChange(ScrollOffsetKey.self) { value in
                scrollOffset = value
            }

            stickyHeader(stickyHeaderAlpha, safeAreaInset)
                .background(
                    GeometryReader { geo in
                        Color.clear.onChange(of: geo.size) { _, value in
                            self.stickyHeaderHeight = value.height
                        }.onAppear {
                            self.stickyHeaderHeight = geo.size.height
                        }
                    }
                )
                .allowsHitTesting(false)
                .if(animationBehavior == .automatic, transform: { view in
                    view.animation(.snappy, value: stickyHeaderAlpha)
                })

            HStack() {
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

    private var stickyHeaderAlpha: Double {
        let animationLength: CGFloat = 30
        let start = -(scrollableHeaderHeight - stickyHeaderHeight)

        if animationBehavior == .automatic {
            // 8 is a magic number found on testing. I'm not sure where I'm missing this.
            // My guess is the `GeometryReader` at the top of the scroll view.
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
    let imageURL = URL(string: "https://1.gravatar.com/avatar/150494b4e538b347b031c4fd3b5c40027d0f7a6d870404020415aa794e7ed254?size=256")

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
        ForEach(0..<11) { i in
            Text("Row \(i)")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            TextField("Sample TextField", text: .constant(""))
        }
    } buttonMenuItems: {
        Button(
            "Logout",
            systemImage: "iphone.and.arrow.forward.outward",
            role: .destructive
        ) {}
    }
}

#Preview("Profile editor Header") {
    let imageURL = URL(string: "https://1.gravatar.com/avatar/150494b4e538b347b031c4fd3b5c40027d0f7a6d870404020415aa794e7ed254?size=256")

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
        ForEach(0..<11) { i in
            Text("Row \(i)")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            TextField("Sample TextField", text: .constant(""))
        }
    } buttonMenuItems: {
        Button(
            "Logout",
            systemImage: "iphone.and.arrow.forward.outward",
            role: .destructive
        ) {}
    }
}

private struct HeaderAvatarView<Placeholder>: View where Placeholder: View {
    let imageURL: URL?
    let showLoading: Bool
    @Binding var forceRefresh: Bool

    let placeholderView: () -> Placeholder

    var body: some View {
        AvatarView(
            url: imageURL,
            placeholderView: {
                placeholderView()
            },
            oneTimeForceRefresh: $forceRefresh,
            loadingView: {
                showLoading ?
                AnyView(ProgressView().progressViewStyle(.circular))
                :
                AnyView(EmptyView())
            },
            transaction: Transaction(animation: .smooth)
        )
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct AvatarPickerScrollableHeaderView: View {
    let topSafeArea: CGFloat
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    var headerHeight: CGFloat {
        130 + topSafeArea
    }

    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let isBouncing = minY > 0

            HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                EmptyView()
            }
            .scaledToFill()
            .frame(width: geo.size.width ,height: isBouncing ? headerHeight + minY : headerHeight)
            .clipped()
            .blur(radius: 26, opaque: true)
            .offset(y: isBouncing ? -minY : 0)
            .overlay(content: {
                Color.black.opacity(0.2)
                    .frame(height: isBouncing ? headerHeight + minY : headerHeight)
                    .offset(y: isBouncing ? -minY : 0)
            })
            .overlay {
                VStack {
                    Spacer()
                    ZStack(alignment: .bottom) {
                        HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                            EmptyView()
                        }
                        .frame(width: 105, height: 105)
                        .shape(Circle(), borderColor: .black.opacity(0.2), borderWidth: 2)
                        .shadow(radius: 2, x: 0, y: 3)
                        .padding()
                        HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                            EmptyView()
                        }
                        .frame(width: 49, height: 49)
                        .shape(RoundedRectangle(cornerRadius: 7), borderColor: .black.opacity(0.2), borderWidth: 2)
                        .offset(x: 60)
                        .shadow(radius: 2, x: 0, y: 3)
                        .padding()
                    }
                }
                .frame(height: isBouncing ? headerHeight + minY : headerHeight)
                .offset(y: isBouncing ? -minY : 0)
            }
        }
        .environment(\.colorScheme, .dark)
        .frame(height: headerHeight)
    }
}

struct AvatarPickerStickyHeaderView: View {
    let opacity: CGFloat
    let safeAreaInsets: EdgeInsets
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    var headerHeight: CGFloat {
        return safeAreaInsets.top == 0 ? 75 : 58 + safeAreaInsets.top
    }

    var body: some View {
        HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
            EmptyView()
        }
        .scaledToFill()
        .frame(height: headerHeight)
        .clipped()
        .opacity(opacity)
        .blur(radius: 26, opaque: true)
        .overlay(content: {
            Color.black.opacity(0.2 * opacity)
        })
        .overlay {
            VStack() {
                Spacer()
                HStack(alignment: .center) {
                    HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                        EmptyView()
                    }
                    .frame(width: 44, height: 44)
                    .shape(Circle(), borderColor: .black.opacity(0.2), borderWidth: 2)
                    .shadow(radius: 2, x: 0, y: 3)

                    HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                        EmptyView()
                    }
                    .frame(width: 33, height: 33)
                    .shape(RoundedRectangle(cornerRadius: 7), borderColor: .black.opacity(0.2), borderWidth: 2)
                    .shadow(radius: 2, x: 0, y: 3)

                    Spacer()
                }
            }
            .padding(.horizontal, safeAreaInsets.leading + 16)
            .padding(.bottom, 16)
            .opacity(opacity)
        }
        .ignoresSafeArea()
        .environment(\.colorScheme, .dark)
    }
}

struct ProfileEditorScrollableHeaderView: View {
    let profile: Profile

    let topSafeArea: CGFloat
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    @State private var contentHeight: CGFloat = 0

    var viewHeight: CGFloat {
        return contentHeight + topSafeArea
    }

    var profession: String? {
        [profile.jobTitle, profile.company].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    var body: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .global).minY
            let isBouncing = minY > 0

            HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                EmptyView()
            }
            .scaledToFill()
            .frame(width: geo.size.width ,height: isBouncing ? viewHeight + minY : viewHeight)
            .clipped()
            .blur(radius: 26, opaque: true)
            .offset(y: isBouncing ? -minY : 0)
            .overlay(content: {
                Color.black.opacity(0.2)
                    .frame(height: isBouncing ? viewHeight + minY : viewHeight)
                    .offset(y: isBouncing ? -minY : 0)
            })
            .overlay {
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                            EmptyView()
                        }
                        .frame(width: 105, height: 105)
                        .shape(Circle(), borderColor: .black.opacity(0.2), borderWidth: 2)
                        .shadow(radius: 2, x: 0, y: 3)
                        VStack(spacing: 0) {
                            Text(profile.displayName).font(.title3).fontWeight(.semibold)
                            if let profession {
                                Text(profession).font(.subheadline).foregroundStyle(.secondary)
                            }
                            if !profile.location.isEmpty {
                                Text(profile.location).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        Button {

                        } label: {
                            Label {
                                Text(profile.profileUrl.replacingOccurrences(of: "https://", with: ""))
                                    .font(.subheadline)
                            } icon: {
                                Image(systemName: "safari")
                                    .font(.subheadline)
                            }
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color.black)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom)
                    .contentHeightReader($contentHeight)
                }
                .frame(height: isBouncing ? viewHeight + minY : viewHeight)
                .offset(y: isBouncing ? -minY : 0)

            }
        }
        .environment(\.colorScheme, .dark)
        .frame(height: viewHeight)
    }
}

struct ProfileEditorStickyHeaderView: View {
    let profile: Profile

    let opacity: CGFloat
    let safeAreaInsets: EdgeInsets
    let imageURL: URL?
    @Binding var forceRefresh: Bool

    var headerHeight: CGFloat {
        return safeAreaInsets.top == 0 ? 16 + contentHeight : contentHeight + safeAreaInsets.top
    }

    @State var contentHeight: CGFloat = 0

    var profession: String? {
        [profile.jobTitle, profile.company].filter { !$0.isEmpty }.joined(separator: ", ")
    }

    var body: some View {
        HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
            EmptyView()
        }
        .scaledToFill()
        .frame(height: headerHeight)
        .clipped()
        .opacity(opacity)
        .blur(radius: 26, opaque: true)
        .overlay(content: {
            Color.black.opacity(0.2 * opacity)
        })
        .overlay {
            VStack() {
                Spacer()
                HStack(alignment: .top) {
                    HeaderAvatarView(imageURL: imageURL, showLoading: false, forceRefresh: $forceRefresh) {
                        EmptyView()
                    }
                    .frame(width: 44, height: 44)
                    .shape(Circle(), borderColor: .black.opacity(0.2), borderWidth: 2)
                    .shadow(radius: 2, x: 0, y: 3)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(profile.displayName).font(.title3).fontWeight(.semibold)
                        if let profession {
                            Text(profession).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
                .padding(.top)
                .contentHeightReader($contentHeight)
            }

            .padding(.horizontal, safeAreaInsets.leading + 16)
            .padding(.bottom, 16)
            .opacity(opacity)
        }
        .ignoresSafeArea()
        .environment(\.colorScheme, .dark)
    }
}


extension View {
    func contentHeightReader(_ height: Binding<CGFloat>) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear.onChange(of: geo.size) { _, value in
                    height.wrappedValue = value.height
                }.onAppear {
                    height.wrappedValue = geo.size.height
                }
            }
        )
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
