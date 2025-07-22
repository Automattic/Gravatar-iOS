import CoreImage.CIFilterBuiltins
import Gravatar
import SwiftUI

final class QRGenerator {
    @MainActor
    func generateQRCode(from string: String) async -> Image {
        let image = await Self.generate(from: string)
        return image.resizable()
    }

    static var fallbakImage: some View {
        Image(systemName: "qrcode")
            .resizable()
            .foregroundStyle(.black)
            .padding()
            .background(Color.white)
    }
}

private extension QRGenerator {
    static func generate(from string: String) async -> Image {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let context = CIContext()
                let filter = CIFilter.qrCodeGenerator()
                filter.message = Data(string.utf8)

                if let outputImage = filter.outputImage {
                    let scaled = outputImage.transformed(by: .init(scaleX: 20, y: 20))
                    if let cgImage = context.createCGImage(scaled, from: scaled.extent) {
                        let uiImage = UIImage(cgImage: cgImage)
                        let image = Image(uiImage: uiImage)
                        continuation.resume(returning: image)
                        return
                    }
                }

                let fallback = Image(systemName: "qrcode")
                continuation.resume(returning: fallback)
            }
        }
    }
}
