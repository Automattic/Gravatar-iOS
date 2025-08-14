@MainActor
struct MenuSection {
    let items: [MenuItem]

    init(@MenuBuilder _ content: () -> [MenuElement]) {
        self.items = content().compactMap { $0 as? MenuItem }
    }

    init(_ items: [MenuItem]) {
        self.items = items
    }
}
