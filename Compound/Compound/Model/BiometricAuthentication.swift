//
//  BiometricAuthentication.swift
//  
//
//  Created by robert on 12/12/2018.
//

import Foundation
import LocalAuthentication

class BiometricAuthentication {

    class func performBiometricAuthentication() {
        var error:NSError? = nil
        let context = LAContext()
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            switch context.biometryType {
            case .none: break
            case .touchID: context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock the app" ) { (success, nil) in
                if success {
                    print("Successful Touch ID authorization!")
                } else {print("Unsuccessful Touch ID authorization!"); self.performBiometricAuthentication()}
                }
            case .faceID: context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock the app" ) { (success, nil) in
                if success {
                    print("Successful Face ID authorization!")
                } else {print("Unsuccessful Face ID authorization!")}
                }
            }
        } else {
            print("Unable to evaluate the given policy")
        }
    }

}
