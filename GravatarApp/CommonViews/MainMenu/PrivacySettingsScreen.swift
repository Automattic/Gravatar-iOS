import Analytics
import SwiftUI

struct PrivacySettingsScreen: View {
    @Environment(\.analytics) var analytics

    @StateObject private var viewModel: PrivacySettingsUserSelection
    @State private var shareAnalytics: Bool = false
    @State private var inAppURL: URL?

    @Binding var isPresented: Bool

    init(isPresented: Binding<Bool>, userDefaults: UserDefaults = .standard) {
        _viewModel = StateObject(wrappedValue: PrivacySettingsUserSelection(userDefaults: userDefaults))
        _isPresented = isPresented
    }

    var body: some View {
        VStack(spacing: CGFloat.Global.verticalSectionSpacing) {
            infoCard(
                title: Localized.analyticsTitle,
                paragraphs: Localized.analyticsMessage1, Localized.analyticsMessage2,
                showButton: true,
                value: $viewModel.shareAnalytics
            )
            infoCard(
                title: Localized.crashReportTitle,
                paragraphs: Localized.crashReportMessage,
                value: $viewModel.shareCrashReports
            )
            Spacer()
        }
        .padding(.horizontal, CGFloat.Global.contentHorizontalPadding)
        .padding(.top, CGFloat.Global.verticalSectionSpacing)
        .frame(maxHeight: .infinity)
        .navigationTitle(Localized.pageTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                closeButton
            }
        }
        .presentSafariView(url: $inAppURL)
        .presentationBackground(.ultraThickMaterial)
    }

    private func infoCard(title: String, paragraphs: String..., showButton: Bool = false, value: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle(isOn: value) {
                Text(title).fontWeight(.semibold)
            }
            Divider().offset(y: -4).padding(.trailing, 60)
            ForEach(paragraphs, id: \.self) { text in
                Text(text)
            }
            if showButton {
                Button {
                    analytics.track(PrivacySettingsEvents.privacyPolicyTapped)
                    inAppURL = URL(string: "https://automattic.com/privacy/")!
                } label: {
                    Text(Localized.privacyPolicyButtonTitle)
                }
            }
        }
        .padding(.vertical, CGFloat.Global.verticalSectionSpacing)
        .padding(.horizontal, CGFloat.Global.contentHorizontalPadding)
        .frame(maxWidth: .infinity)
        .background(Color(uiColor: .systemBackground))
        .shape(RoundedRectangle(cornerRadius: 12))
    }

    private var closeButton: some View {
        Button {
            isPresented = false
        } label: {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 20))
                .symbolRenderingMode(.hierarchical)
        }
        .tint(.primary.opacity(0.6))
    }
}

private enum Localized {
    static let pageTitle = NSLocalizedString(
        "PrivacySettings.Screen.title",
        value: "Privacy Settings",
        comment: "Title for the Privacy Settings screen"
    )
    static let analyticsTitle = NSLocalizedString(
        "PrivacySettings.Analytics.title",
        value: "Share Analytics Data",
        comment: "Title for the analytics section of Privacy Settings"
    )
    static let analyticsMessage1 = NSLocalizedString(
        "PrivacySettings.Analytics.paragraph_1",
        value: "Share information with our analytics tool about how you interact with this app and our services.",
        comment: "First paragraph descrption for the analytics section of Privacy Settings"
    )
    static let analyticsMessage2 = NSLocalizedString(
        "PrivacySettings.Analytics.paragraph_2",
        value: "This information helps us improve our products, and offer you a better experience.",
        comment: "Second paragraph descrption for the analytics section of Privacy Settings"
    )
    static let crashReportTitle = NSLocalizedString(
        "PrivacySettings.CrashReport.title",
        value: "Share Crash Reports",
        comment: "Title for the crash report section of Privacy Settings"
    )
    static let crashReportMessage = NSLocalizedString(
        "PrivacySettings.CrashReport.description",
        value: "Share information with our analytics tool about how you interact with this app and our services.",
        comment: "Descrption for the crash report section of Privacy Settings"
    )
    static let privacyPolicyButtonTitle = NSLocalizedString(
        "PrivacySettings.PrivacyPolicy.Button.title",
        value: "Privacy Policy",
        comment: "Link text for the 'Privacy Policy' button in the Privacy Settings"
    )
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                ScrollView {
                    PrivacySettingsScreen(isPresented: .constant(true))
                }
            }
        }
}
