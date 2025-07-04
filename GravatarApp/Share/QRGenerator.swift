import CoreImage.CIFilterBuiltins
import UIKit
import Gravatar

struct QRGenerator: @unchecked Sendable {
    private let profile: Profile

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    init(profile: Profile) {
        self.profile = profile
    }

    var contactQRCode: UIImage {
        get async {
            await generateQRCode(from: "contact:\(profile.displayName)")
        }
    }

    private func generateQRCode(from string: String) async -> UIImage {
        await withCheckedContinuation { continuation in
            Task {
                filter.message = Data(string.utf8)

                if let outputImage = filter.outputImage {
                    let bigImage = outputImage.transformed(by: CGAffineTransform(scaleX: 20, y: 20))
                    if let cgImage = context.createCGImage(bigImage, from: bigImage.extent) {
                        let qrImage = UIImage(cgImage: cgImage)

                        continuation.resume(returning: qrImage)
                        return
                    }
                }

                let fallbackImage = UIImage(systemName: "xmark.circle") ?? UIImage()
                continuation.resume(returning: fallbackImage)
            }
        }
    }
}
