//
//  InterfaceController.swift
//  Demo WatchKit Extension
//
//  Created by Inomoto Shintaro on 2017/03/08.
//  Copyright © 2017年 Shintaro Inomoto. All rights reserved.
//

import WatchKit
import Foundation
import RxSwift
import WatchConnectivity
class InterfaceController: WKInterfaceController {
    
    @IBOutlet var parentDeviceLabel: WKInterfaceLabel!
    @IBOutlet private var connectivityLabel: WKInterfaceLabel!
    @IBOutlet private var sayHelloButton: WKInterfaceButton!
    
    private var disposer: Disposable?
    private var disposer2: Disposable?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.parentDeviceLabel.setText(nil)
        
        disposer = WCSession.default
            .rx.activationState
            .do(onNext: {
                
                self.sayHelloButton.setHidden(!($0 == .activated))
                
            }, onError: nil, onCompleted: nil, onSubscribe: nil, onDispose: nil)
            .subscribe(onNext: {
                
                switch($0){
                case .activated:
                    self.connectivityLabel.setText("Active.")
                case .inactive:
                    self.connectivityLabel.setText("Inactive.")
                case .notActivated:
                    self.connectivityLabel.setText("Not activated.")
                }
                
            }, onError: {
                
                self.connectivityLabel.setText("Error !! \($0.localizedDescription)")
                
            }, onCompleted: {
                
            }) {
                
                self.connectivityLabel.setText("Canceled.")
                
        }

        disposer2 = WCSession.default
            .rx.didReceiveMessage
            .subscribe(onNext: {
                
                guard let message = MessageConverter.message(from: $0) else {
                    return
                }
                
                self.parentDeviceLabel.setText(message + " @" + Date().description)
                
            }, onError: {
                
                self.parentDeviceLabel.setText("Error !! \($0.localizedDescription)")
                
            }, onCompleted: {
            
            }) {
                self.parentDeviceLabel.setText("Canceled.")
        }
        
    }
    
    @IBAction func sayHelloButtonDidTouchUp() {
        
        WCSession.default
            .sendMessage(MessageConverter.userInfo(from: "Hello !!"),
                         replyHandler: { _ in },
                         errorHandler: { _ in })
        
    }
    
    override func willActivate() {
        super.willActivate()
        WCSession.default.activate()
    }
    
    deinit {
        disposer?.dispose()
        disposer2?.dispose()
    }

}
