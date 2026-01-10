/*
 NOTES:
 - Changing StockPortfolioApp changes what appears on a real device or simulator
 
 - : App →
    - the entry point of the entire app
    - responsible for creating app windows
    - responsible for high-level flow.
 
 - Determines what the user sees + how the app funcitons
 
 -   DispatchQueue → system task scheduler
    .main → run on the main UI thread
    .asyncAfter → run after a delay
    deadline: .now() + 2 → 2-second delay
 
 */

import SwiftUI

@main
struct StockPortfolioApp: App {
    @State private var showLaunchScreen: Bool = true //private = cannot be accessed outside this file
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"

    init(){
        UserDefaults.standard.set("system", forKey: "appearanceMode")
    }
    
    private var colorScheme: ColorScheme? {
        if appearanceMode == "light" {
            return .light
        } else if appearanceMode == "dark" {
            return .dark
        } else {
            return nil  // nil = system default (for "system" mode)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if showLaunchScreen {
                LaunchScreen()
                    .preferredColorScheme(colorScheme)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) {
                            withAnimation {
                                showLaunchScreen = false
                            }
                        }
                    }
            } else {
                DashboardView()
                    .preferredColorScheme(colorScheme)
            }
        }
    }
}
