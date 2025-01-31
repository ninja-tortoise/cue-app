//
//  WelcomeView.swift
//  Exposure
//
//  Created by Toby on 7/1/2025.
//

import SwiftUI

struct WelcomeCardView: View {
    
    var welcomeData: OnboardingData
    
    @State private var isAnimating: Bool = false
    
    // MARK: - BODY
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {

                Text(welcomeData.title)
                    .foregroundColor(Color.white)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 30)
                
                Text(welcomeData.subtitle)
                    .foregroundColor(Color.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .font(.title3)
                    .padding(.horizontal, 16)
                
                Spacer()
                    
                Image(welcomeData.image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(isAnimating ? 1.0 : 0.6)
//                    .frame(width: 80)
                    .padding(.horizontal, 40)
                    .padding(.top, 6)
                    .tint(Color.white)
                    .foregroundStyle(.white)
                    .shadow(color: Color.black.opacity(0.15),
                            radius: 6,
                            y: 6)
                
                Spacer()

                Text(welcomeData.headline)
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(maxWidth: 480)
                    .padding(.bottom, 30)
                
                Spacer()
                Spacer()
                Spacer()

//                NextButtonView()
//                    .padding(.top, 30)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                isAnimating = true
            }
        }
      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
//      .background(welcomeData.gradientColors[0])
      .background(LinearGradient(gradient: Gradient(colors: welcomeData.gradientColors), startPoint: .top, endPoint: .bottom))
//      .cornerRadius(20)
//      .padding(.horizontal, 20)
    }
}

struct WelcomeCardView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeCardView(welcomeData: onboardingData[0])
    }
}

struct StartButtonView: View {

    @AppStorage("isOnboarding") var isOnboarding: Bool?
    
    
    var body: some View {
      Button(action: {
        isOnboarding = false
      }) {
        HStack(spacing: 8) {
          Text("Start")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
          Capsule().strokeBorder(Color.white, lineWidth: 1.25)
        )
      } //: BUTTON
      .accentColor(Color.white)
    }
}

struct StartButtonView_Previews: PreviewProvider {
    static var previews: some View {
        StartButtonView()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
