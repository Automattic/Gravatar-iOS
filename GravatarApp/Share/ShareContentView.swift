import Gravatar
import SwiftUI

struct ShareContentView: View {
    @ObservedObject var viewModel: ShareViewModel
    @EnvironmentObject var userSession: UserSession

    @State var forceRefresh: Bool = false
    @State var toggleOn: Bool = false

    @State var scrollOffset: CGFloat = 0
    @State var safeAreaInsets: EdgeInsets = .init()

    var email: String {
        userSession.profile.contactInfo?.email ?? ""
    }

    var phone: String {
        userSession.profile.contactInfo?.cellPhone ?? ""
    }

    var contactForm: String {
        userSession.profile.contactInfo?.contactForm ?? ""
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ShareHeaderView(
                    forceRefresh: $forceRefresh,
                    profile: userSession.profile,
                    safeAreaInsets: $safeAreaInsets,
                    width: geometry.size.width,
                    maxHeight: geometry.size.height
                )
                // Sticky header on scroll bounce
                .transformEffect(.init(translationX: 0, y: -max(0, -scrollOffset)))
                .frame(width: geometry.size.width)
                VStack(spacing: 16) {
                    ShareField(title: "Public email", value: .constant(email), selected: viewModel.share.$email)
                    ShareField(title: "Public phone", value: .constant(phone), selected: viewModel.share.$phone)
                    ShareField(title: "Public contact form", value: .constant(contactForm), selected: viewModel.share.$contactForm)
                }
                .padding()
                Spacer()
            }
            .scrollOffsetReader($scrollOffset)
            .scrollBounceBehavior(.basedOnSize)
            .ignoresSafeArea(.container, edges: [.top])
            // Safe area reader
            Color.clear
                .onAppear {
                    safeAreaInsets = geometry.safeAreaInsets
                }
                .onChange(of: geometry.frame(in: .global)) { _, _ in
                    safeAreaInsets = geometry.safeAreaInsets
                }
        }

        .onAppear {
            forceRefresh = true
        }
    }
}

#Preview {
    ShareContentView(
        viewModel: .init(userSession: .init(profile: .testProfile, accessToken: ""))
    )
    .environmentObject(UserSession(profile: .testProfile, accessToken: ""))
}
