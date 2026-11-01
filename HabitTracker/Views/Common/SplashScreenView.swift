import SwiftUI

public struct SplashScreenView: View {
    private let brandBackground = Color(red: 12.0 / 255.0, green: 54.0 / 255.0, blue: 68.0 / 255.0)
    
    public init() {}
    
    public var body: some View {
        ZStack {
            brandBackground
                .ignoresSafeArea()
            
            // Clean, flat icon with zero drop shadow
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 140, height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        }
    }
}
