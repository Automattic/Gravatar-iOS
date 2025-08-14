import SwiftUI
import UIKit

struct MenuButton<Label: View>: UIViewRepresentable {
    @ViewBuilder
    private let label: () -> Label
    private let sections: [MenuSection]
    private let onMenuAppear: (() -> Void)?

    init(
        @ViewBuilder label: @escaping () -> Label,
        @MenuBuilder content: @escaping () -> [MenuElement],
        onMenuAppear: (() -> Void)? = nil
    ) {
        sections = content().toMenuSections()

        self.label = label
        self.onMenuAppear = onMenuAppear
    }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        let hosting = UIHostingController(rootView: label())

        addSubview(hosting.view, to: button)

        button.menu = UIMenu(options: .displayInline, children: sections.map { $0.map() })
        button.showsMenuAsPrimaryAction = true
        button.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.onMenuAppear)))

        return button
    }

    func updateUIView(_: UIButton, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onMenuAppear: onMenuAppear)
    }

    private func addSubview(_ subView: UIView, to parentView: UIView) {
        subView.backgroundColor = .clear
        subView.translatesAutoresizingMaskIntoConstraints = false

        parentView.addSubview(subView)
        NSLayoutConstraint.activate([
            subView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
            subView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
            subView.topAnchor.constraint(equalTo: parentView.topAnchor),
            subView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
        ])
    }
}

extension MenuButton {
    class Coordinator: NSObject {
        let onMenuAppearCallback: (() -> Void)?

        init(onMenuAppear: (() -> Void)?) {
            self.onMenuAppearCallback = onMenuAppear
        }

        @objc
        func onMenuAppear() {
            onMenuAppearCallback?()
        }
    }
}

// MARK: - Private utilities

extension [MenuElement] {
    @MainActor
    fileprivate func toMenuSections() -> [MenuSection] {
        let sections = compactMap { $0 as? MenuSection }
        return sections.isEmpty ? [MenuSection(compactMap { $0 as? MenuItem })] : sections
    }
}

extension MenuSection {
    fileprivate func map() -> UIMenu {
        UIMenu(options: .displayInline, children: items.map { $0.map() })
    }
}

extension MenuItem {
    fileprivate func map() -> UIAction {
        .init(
            title: title,
            image: systemImage.flatMap(UIImage.init(systemName:)),
            attributes: attributes,
            handler: { _ in action() }
        )
    }
}
