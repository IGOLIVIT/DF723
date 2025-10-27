//
//  DF723App.swift
//  DF723
//
//  Created by IGOR on 22/10/2025.
//

import SwiftUI
import Foundation

@main
struct DF723App: App {
    @StateObject private var dataManager = DataManager.shared
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    @AppStorage("isRequested") var isRequested: Bool = false
    
    var body: some Scene {
        WindowGroup {
          
            ZStack {
                
                if isFetched == false {
                    
                    ProgressView()
                    
                } else if isFetched == true {
                    
                    if isBlock == true {
                        
                        if dataManager.hasCompletedOnboarding {
                            MainTabView()
                        } else {
                            OnboardingView()
                        }
                        
                    } else if isBlock == false {
                        
                        WebSystem()
                    }
                }
            }
            .onAppear {
                
                makeServerRequest()
            }
        }
    }

    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = true
            self.isFetched = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                if let httpResponse = response as? HTTPURLResponse {
                    
                    if httpResponse.statusCode == 404 {
                        
                        self.isBlock = true
                        self.isFetched = true
                        
                    } else if httpResponse.statusCode == 200 {
                        
                        self.isBlock = false
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // В случае ошибки сети тоже блокируем
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
    

}




