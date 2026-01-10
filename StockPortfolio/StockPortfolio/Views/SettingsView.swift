//
//  SettingsView.swift
//  StockPortfolio
//
//  Created by Ned Tonks on 29/11/2025.
// * settings page *

import SwiftUI

struct SettingsView: View {
    @AppStorage("appearanceMode") private var appearanceMode: String = "system"
    @AppStorage("autoRefreshMinutes") private var autoRefreshMinutes: Int = 0
    
    var body: some View{
        NavigationStack{
            Form{
                Section("Appearance"){
                    Picker("Theme", selection: $appearanceMode){
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                        Text("System").tag("system")
                    }
                }
                
                Section("Refresh"){
                    Picker("Auto Refresh", selection: $autoRefreshMinutes){
                        Text("Off").tag(0)
                        Text("1 minute").tag(1)
                        Text("5 minutes").tag(5)
                        Text("10 minutes").tag(10)
                    }
                }
                
                Section("About"){
                    HStack{
                        Text("Developer")
                        Spacer()
                        Text("Ned Tonks")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack{
                        Text("Email")
                        Spacer()
                        Link("nedtonks@gmail.com", destination: URL(string: "malto:nedtonks@gmail.com")!)
                            .foregroundColor(.blue)
                    }
                    
                    HStack{
                        Text("GitHub")
                        Spacer()
                        Link("View Profile", destination: URL(string: "https://github.com/nedtonks")!)
                            .foregroundColor(.blue)
                    }
                    
                    HStack{
                        Text("LinkedIn")
                        Spacer()
                        Link("View Profile", destination: URL(string: "https://www.linkedin.com/in/ned-tonks-355936221/")!)
                            .foregroundColor(.blue)
                    }
                }
                
                HStack{
                    Text("Data Source")
                    Spacer()
                    Text("Finnhub")
                        .foregroundColor(.secondary)
                }
                HStack{
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
