//
//  ContentView.swift
//  BiometricAuthentication
//
//  Created by Diego Ballesteros on 28/11/23.
//

import SwiftUI
import LocalAuthentication

struct ContentView: View {
    
    //Allows to detect if the app is on background, active or inative
    @Environment(\.scenePhase) var scenePhase
    
    //Allows to read if the view is locked
    @State private var unlock = false
    
    var body: some View {
        NavigationStack {
            if unlock == false {
                VStack {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50, maxHeight: 50)
                        .opacity(0.6)
                        .accessibilityHidden(true)
                    
                    Text("Use Face ID to Unlock This View")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    Button("Unlock View") {
                        //We call the authentication method
                        authenticate()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            else {
                
                VStack {
                    Image(systemName: "lock.open.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: 50, maxHeight: 50)
                        .opacity(0.6)
                        .accessibilityHidden(true)
                    
                    Text("Unlocked")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    Button {
                        unlock = false
                    } label: {
                        Text("Lock View")
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
        }
        
        //We detect if the app goes active, inactive or background in order to block the view
        .onChange(of: scenePhase, { oldValue, newValue in
            if newValue == .inactive {
                unlock = false
            } else if newValue == .active {
                print("Active")
            } else if newValue == .background {
                unlock = false
            }
        })
    }
    
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        // Check whether it's possible to use authentications
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            
            // Handle events
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Your Face ID is required to view this album") { success, authenticationError in
                if success {
                    
                    //Face ID authentication is running on background, not with MainActor, because it's done by the system and not by the app, so we need to let the App now that the changing of the unlocked var should be runned in the MainActor
                    Task {
                        await MainActor.run {
                            unlock = true
                        }
                    }
                }
            }
        }
        else {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Your passcode is required to view this album") { success, authenticationError in
                if success {
                    Task {
                        await MainActor.run {
                            unlock = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
