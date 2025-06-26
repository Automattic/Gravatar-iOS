extension Result {
    func value() -> Success? {
        switch self {
        case .success(let value):
            value
        default:
            nil
        }
    }
}

extension Result {
    func error() -> Error? {
        switch self {
        case .failure(let error):
            error
        default:
            nil
        }
    }
}
