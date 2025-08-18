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
                icon: { Image(systemName: "chart.bar.xaxis") },
                paragraphs: Localized.analyticsMessage1, Localized.analyticsMessage2,
                showButton: true,
                value: $viewModel.shareAnalytics
            )
            infoCard(
                title: Localized.crashReportTitle,
                icon: { Image(systemName: "ant.fill") },
                paragraphs: Localized.crashReportMessage,
                value: $viewModel.shareCrashReports
            )
            Spacer()
        }
        .padding(.horizontal, .Global.contentHorizontalPadding)
        .padding(.top, .Global.verticalSectionSpacing)
        .navigationSetup(isPresented: $isPresented)
        .presentSafariView(url: $inAppURL)
        .presentationBackground(.ultraThickMaterial)
    }

    private func infoCard(title: String, icon: () -> Image, paragraphs: String..., showButton: Bool = false, value: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: .Global.verticalSectionSpacing) {
            toggleView(title: title, icon: icon, value: value)
            Divider()
            ForEach(paragraphs, id: \.self) { text in
                Text(text)
            }
            .padding(.trailing, .Global.contentHorizontalPadding)
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
        .padding(.leading, CGFloat.Global.contentHorizontalPadding)
        .background(Color.DS.backgroundOverMaterial)
        .shape(RoundedRectangle(cornerRadius: 12))
    }

    private func toggleView(title: String, icon: () -> Image, value: Binding<Bool>) -> some View {
        Toggle(isOn: value) {
            HStack {
                icon().foregroundStyle(.secondary)
                Text(title).fontWeight(.semibold)
            }
        }
        .padding(.trailing, .Global.contentHorizontalPadding)
    }
}

extension View {
    fileprivate func navigationSetup(isPresented: Binding<Bool>) -> some View {
        var closeButton: some View {
            Button {
                isPresented.wrappedValue = false
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .symbolRenderingMode(.hierarchical)
            }
            .tint(.primary.opacity(0.6))
        }

        return self.navigationTitle(Localized.pageTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    closeButton
                }
            }
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
        value: "To help us improve the app’s performance and fix occasional bugs, enable automatic crash reports.",
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
