import CoreImage.CIFilterBuiltins
import Gravatar
import UIKit

class QRGenerator: @unchecked Sendable {
    private let profile: Profile

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    init(profile: Profile) {
        self.profile = profile
    }

    var contactQRCode: UIImage {
        generateQRCode(from: "contact:\(profile.displayName)")
    }

    private func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            let bigImage = outputImage.transformed(by: CGAffineTransform(scaleX: 20, y: 20))
            if let cgImage = context.createCGImage(bigImage, from: bigImage.extent) {
                let qrImage = UIImage(cgImage: cgImage)

                return qrImage
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
