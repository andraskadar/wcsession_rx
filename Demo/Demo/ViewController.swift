//
//  ViewController.swift
//  Demo
//
//  Created by Inomoto Shintaro on 2017/03/08.
//  Copyright © 2017年 Shintaro Inomoto. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var goodByeButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        WCSession.default().delegate = self
        WCSession.default().activate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        goodByeButton.isHidden = !(activationState == .activated)
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        guard let message = MessageConverter.message(from: message) else {
            return
        }
        
        messageLabel.text = message + " @" + Date().description
        
        replyHandler([:])
    }

    @IBAction func goodByeButtonDidTouchUp(_ sender: UIButton) {
        WCSession.default()
            .sendMessage(MessageConverter.userInfo(from: "Good Bye !!"), replyHandler: nil, errorHandler: nil)
    }
}

