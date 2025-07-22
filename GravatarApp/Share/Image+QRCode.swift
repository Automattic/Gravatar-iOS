import SwiftUI

extension Image {
    static var fallbakQRCodeImage: some View {
        Image(systemName: "qrcode")
            .resizable()
            .foregroundStyle(.black)
            .padding()
            .background(Color.white)
    }
}
