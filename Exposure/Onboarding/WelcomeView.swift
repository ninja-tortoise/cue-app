//
//  WelcomeView.swift
//  Exposure
//
//  Created by Toby on 7/1/2025.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    var welcomeData: [OnboardingData] = onboardingData
    @State private var selection = 0
    
    var body: some View {
        ZStack {
            TabView(selection: $selection) {
                ForEach(welcomeData.indices, id: \.self) { idx in
                    ZStack {
                        WelcomeCardView(welcomeData: welcomeData[idx])
                            .tag(idx)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .automatic))
            .background(LinearGradient(gradient: Gradient(colors: [Color(hex: "beb9e7"), Color(hex: "daa092")]), startPoint: .top, endPoint: .bottom))
            //      .padding(.vertical, 20)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // Navigate to the next page with animation
                        withAnimation {
                            if selection < welcomeData.count-1 {
                                selection += 1
                            } else if selection == welcomeData.count-1 {
                                isOnboarding = false
                            }
                        }
                    }) {
                        HStack {
                            Text(selection == welcomeData.count-1 ? "Start" : "Next")
                                .foregroundStyle(selection == welcomeData.count-1 ? .black.opacity(0.8) : .white)
                                .bold(selection == welcomeData.count-1)
                            
                            Image(systemName: "arrow.right.circle")
                                .imageScale(.large)
                                .foregroundStyle(selection == welcomeData.count-1 ? .black.opacity(0.8) : .white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .strokeBorder(.white, lineWidth: 1.25)
                                .fill(selection == welcomeData.count-1 ? .white : .clear)
                        )
                    }
                    .accentColor(Color.white)
                    .padding(.bottom, 5)
                    .padding(.trailing, 34)
                }
            }
        }
        
    }
        

}

struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
