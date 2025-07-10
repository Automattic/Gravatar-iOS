import UIKit

extension UIImage {
    /// Saves image into the temp directory as a jpeg file.
    /// - Returns: The URL of the file.
    func saveToFile(withName name: String = "avatar") throws -> URL? {
        guard let imageData = jpegData(compressionQuality: 1) else { return nil }
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(name).jpg")
        try imageData.write(to: fileURL)
        return fileURL
    }
}
