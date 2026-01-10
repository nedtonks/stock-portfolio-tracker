/*
 NOTES:
 - Changing #Preview only changes what appears in the Xcode canvas
 - Can change the name of ContentView to anything. In a sense, it is like calling a function, when you write ContentView()
 */

import SwiftUI

struct LaunchScreen: View{
    @State private var offset: CGFloat = -1000 // start off screen to the left
    
    var body: some View {
        Text("Welcome!")
            .offset(x: offset) // moves text /left>right
            .font(.largeTitle)
            .onAppear {
                //step 1: Slide in (left to center)
                withAnimation(.easeInOut(duration: 1.0)){
                    offset = 0
                }
                
                //step 2: Wait/pause
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    //step 3: slide out (center to right)
                    withAnimation(.easeInOut(duration: 1.0)){
                        offset = 1000
                    }
                }
            }
    }
}
#Preview {
    LaunchScreen()
}
