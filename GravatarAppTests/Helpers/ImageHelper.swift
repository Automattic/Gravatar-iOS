import UIKit

enum ImageHelper {
    static var testImage: UIImage {
        image(named: "test", type: "png")!
    }

    static var testProfileImage: UIImage {
        image(named: "test_profile", type: "jpg")!
    }

    static var testImageData: Data {
        dataFromImage(named: "test", type: "png")!
    }

    static var placeholderImage: UIImage {
        image(named: "placeholder", type: "png")!
    }

    static var exampleAvatarImage: UIImage {
        image(named: "example_avatar", type: "png")!
    }

    static func dataFromImage(named: String, type: String) -> Data? {
        guard let url = Bundle.testsBundle.url(forResource: named, withExtension: type) else {
            return nil
        }
        var data: Data? = nil
        do {
            data = try Data(contentsOf: url)
        } catch {}
        return data
    }

    static func image(named: String, type: String) -> UIImage? {
        guard let path = Bundle.testsBundle.path(forResource: named, ofType: type) else {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
}
