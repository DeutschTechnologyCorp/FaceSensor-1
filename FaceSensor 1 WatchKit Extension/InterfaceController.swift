//
//  InterfaceController.swift
//  FaceSensor 1 WatchKit Extension
//
//  Created by VICTOR J. DEUTSCH on 8/31/18.
//  Copyright © 2018 VICTOR J. DEUTSCH. All rights reserved.
//
import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    //
    func session(_ session: WCSession, didReceiveMessage message:
        [String : Any]) {
        WKInterfaceDevice().play(.click)
    }
    //
}
