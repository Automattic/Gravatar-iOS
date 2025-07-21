import CoreImage.CIFilterBuiltins
import Gravatar
import SwiftUI

@Observable
final class QRGenerator {
    @MainActor
    func generateQRCode(from string: String) async -> Image {
        let uiImage = await QRCodeRenderer.generate(from: string)
        return Image(uiImage: uiImage).resizable()
    }

    static var fallbakImage: some View {
        Image(systemName: "qrcode")
            .resizable()
            .foregroundStyle(.black)
            .padding()
            .background(Color.white)
    }
}

private enum QRCodeRenderer {
    static func generate(from string: String) async -> UIImage {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let context = CIContext()
                let filter = CIFilter.qrCodeGenerator()
                filter.message = Data(string.utf8)

                if let outputImage = filter.outputImage {
                    let scaled = outputImage.transformed(by: .init(scaleX: 20, y: 20))
                    if let cgImage = context.createCGImage(scaled, from: scaled.extent) {
                        let image = UIImage(cgImage: cgImage)
                        continuation.resume(returning: image)
                        return
                    }
                }

                let fallback = UIImage(systemName: "xmark.circle") ?? UIImage()
                continuation.resume(returning: fallback)
            }
        }
    }
}
