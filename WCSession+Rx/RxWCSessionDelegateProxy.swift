//
//  RxWCSessionDelegateProxy.swift
//  WCSession+Rx
//
//  Created by Inomoto Shintaro on 2017/02/19.
//  Copyright © 2017年 Inomoto Shintaro. All rights reserved.
//

import WatchConnectivity
import RxSwift
import RxCocoa

@available(watchOSApplicationExtension 2.2, *)
class RxWCSessionDelegateProxy: DelegateProxy, WCSessionDelegate, DelegateProxyType {
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let session: WCSession = object as! WCSession
        return session.delegate
    }
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let session: WCSession = object as! WCSession
        session.delegate = delegate as? WCSessionDelegate
    }
    
    fileprivate var _activationStateSubject: PublishSubject<WCSessionActivationState>?
    
    internal var activationStateSubject: PublishSubject<WCSessionActivationState> {
        if let subject = _activationStateSubject {
            return subject
        }
        
        let subject = PublishSubject<WCSessionActivationState>()
        _activationStateSubject = subject
        
        return subject
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

        if let error = error {
            _activationStateSubject?.on(.error(error))
        } else {
            _activationStateSubject?.on(.next(activationState))
        }
        
        _forwardToDelegate?.session(session, activationDidCompleteWith: activationState, error: error)
    }
    
    deinit {
        _activationStateSubject?.on(.completed)
    }
    
}
