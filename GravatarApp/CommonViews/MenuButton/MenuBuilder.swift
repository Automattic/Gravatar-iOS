@resultBuilder
struct MenuBuilder {
    static func buildExpression(_ element: MenuElement) -> [MenuElement] {
        [element]
    }

    static func buildExpression(_ elements: [MenuElement]) -> [MenuElement] {
        elements
    }

    static func buildBlock(_ elements: [MenuElement]...) -> [MenuElement] {
        elements.flatMap(\.self)
    }

    static func buildOptional(_ elements: [MenuElement]?) -> [MenuElement] {
        elements ?? []
    }

    static func buildEither(first elements: [MenuElement]) -> [MenuElement] {
        elements
    }

    static func buildEither(second elements: [MenuElement]) -> [MenuElement] {
        elements
    }

    static func buildArray(_ elements: [[MenuElement]]) -> [MenuElement] {
        elements.flatMap(\.self)
    }
}
