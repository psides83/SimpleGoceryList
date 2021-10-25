//
//  Haptics.swift
//  CustomerManager
//
//  Created by Payton Sides on 4/1/21.
//

import CoreHaptics
import SwiftUI

class Haptics: ObservableObject {
    
    @State private var engine = try? CHHapticEngine()
    
    var simpleSuccess: Void {
        let generator = UINotificationFeedbackGenerator()
        return generator.notificationOccurred(.success)
    }
    
    var simpleError: Void {
        let generator = UINotificationFeedbackGenerator()
        return generator.notificationOccurred(.error)
    }
    
    var simpleWarning: Void {
        let generator = UINotificationFeedbackGenerator()
        return generator.notificationOccurred(.warning)
    }
    
    var custom: Void {
        do {
                        try engine?.start()
        
                        let sharpness = CHHapticEventParameter(
                            parameterID: .hapticSharpness,
                            value: 0
                        )
            
                        let intensity = CHHapticEventParameter(
                            parameterID: .hapticIntensity,
                            value: 1
                        )
        
                        let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
                        let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
        
                        let parameter = CHHapticParameterCurve(
                            parameterID: .hapticIntensityControl,
                            controlPoints: [start, end],
                            relativeTime: 0
                        )
        
                        let event1 = CHHapticEvent(
                            eventType: .hapticTransient,
                            parameters: [intensity, sharpness],
                            relativeTime: 0
                        )
        
//                        let event2 = CHHapticEvent(
//                            eventType: .hapticTransient,
//                            parameters: [sharpness, intensity],
//                            relativeTime: 0.125
//                        )
        
                        let pattern = try CHHapticPattern(
                            events: [event1],
                            parameterCurves: [parameter]
                        )
        
                        let player = try engine?.makePlayer(with: pattern)
                        try player?.start(atTime: 0)
        
                    } catch {
                        // play haptics didn't work
                    }
    }
}
