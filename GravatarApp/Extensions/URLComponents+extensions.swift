import Foundation

extension URLComponents {
    /// Replaces the query item if it exists, otherwise adds a new one.
    func replacingQueryItem(name: String, value: String?) -> URLComponents {
        var copy = self
        let newItem = URLQueryItem(name: name, value: value)

        if var queryItems = self.queryItems,
           let sizeItemIndex = queryItems.firstIndex(where: { $0.name == name })
        {
            // Replace the query item
            queryItems[sizeItemIndex] = newItem
            copy.queryItems = queryItems
        } else {
            // Add the query item if it doesn't exist
            copy.queryItems = (self.queryItems ?? []) + [newItem]
        }

        return copy
    }
}
