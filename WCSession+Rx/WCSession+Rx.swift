//
//  WCSession+Rx.swift
//  WCSession+Rx
//
//  Created by Inomoto Shintaro on 2017/02/19.
//  Copyright © 2017年 Inomoto Shintaro. All rights reserved.
//

import WatchConnectivity
import RxSwift
import RxCocoa

extension Reactive where Base: WCSession {
    public var delegate: DelegateProxy<WCSession, WCSessionDelegate> {
        if #available(watchOSApplicationExtension 2.2, *), #available(iOS 9.3, *) {
            return RxWCSessionDelegateProxy.proxy(for: base)
        } else {
            fatalError("use watchOS 2.2 upper.")
        }
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.2, *)
    public var activationState: Observable<WCSessionActivationState> {
        return RxWCSessionDelegateProxy.proxy(for: base).activationStateSubject
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.2, *)
    public func sendMessage(_ message: [String: Any]) -> Single<[String: Any]> {
        return Single.create { (observer) -> Disposable in
            self.base.sendMessage(message,
                                  replyHandler: { observer(.success($0)) },
                                  errorHandler: { observer(.error($0)) })
            return Disposables.create()
        }
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.2, *)
    public func sendMessageData(_ data: Data) -> Single<Data> {
        return Single.create { (observer) -> Disposable in
            self.base.sendMessageData(data,
                                      replyHandler: { observer(.success($0)) },
                                      errorHandler: { observer(.error($0)) })
            return Disposables.create()
        }
    }
    
    /*
     @available(watchOS 2.2, *)
     public var didComplete: Observable<WCSessionActivationState> { ... }
     */
    
    /** ------------------------- Interactive Messaging ------------------------- */
    @available(iOS 9.3, *)
    @available(watchOS 2.0, *)
    public var didChangeReachability: Observable<Bool> {
        return delegate.methodInvoked(#selector(WCSessionDelegate.sessionReachabilityDidChange(_:))).map{ a in
            return try self.castOrThrow(WCSession.self, a[0]).isReachable
        }
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.0, *)
    public var didReceiveMessage: Observable<[String: Any]> {
        return delegate.methodInvoked(#selector(WCSessionDelegate.session(_:didReceiveMessage:))).map{ a in
            return try self.castOrThrow([String: Any].self, a[1])
        }
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.0, *)
    public var didReceiveMessageWithReplyHandler: Observable<(message: [String: Any], replyHandler: ([String: Any]) -> Void)> {
        typealias __ChallengeHandler =  @convention(block) ([String : Any]) -> Void
        return delegate.methodInvoked(#selector(WCSessionDelegate.session(_:didReceiveMessage:replyHandler:))).map { arg in
            let message = try self.castOrThrow([String: Any].self, arg[1])
            /// Now you `Can't` transform closure easily because they are excuted
            /// in the stack if try it you will get the famous error
            /// `Could not cast value of type '__NSStackBlock__' (0x12327d1a8) to`
            /// this is because closures are transformed into a system type which is `__NSStackBlock__`
            /// the above mentioned type is not exposed to `developer`. So everytime
            /// you execute a closure the compiler transforms it into this Object.
            /// So you go through the following steps to get a human readable type
            /// of the closure signature:
            /// 1. closureObject is type of AnyObject to that holds the raw value from
            /// the array.
            var closureObject: AnyObject? = nil
            /// 2. make the array mutable in order to access the `withUnsafeMutableBufferPointer`
            /// fuctionalities
            var mutableArg = arg
            /// 3. Grab the closure at index 3 of the array, but we have to use the C-style
            /// approach to access the raw memory underpinning the array and store it in closureObject
            /// Now the object stored in the `closureObject` is `Unmanaged` and `some unspecified type`
            /// the intelligent swift compiler doesn't know what sort of type it contains. It is Raw.
            mutableArg.withUnsafeMutableBufferPointer { ptr in
                closureObject = ptr[2] as AnyObject
            }
            /// 4. instantiate an opaque pointer to referenc the value of the `unspecified type`
            let __challengeBlockPtr = UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(closureObject as AnyObject).toOpaque())
            /// 5. Here the magic happen we forcefully tell the compiler that anything
            /// found at this memory address that is refrenced should be a type of
            /// `__ChallengeHandler`!
            let handler = unsafeBitCast(__challengeBlockPtr, to: __ChallengeHandler.self)
            return (message, handler)
        }
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.0, *)
    public var didReceiveMessageData: Observable<Data> {
        return delegate.methodInvoked(#selector(WCSessionDelegate.session(_:didReceiveMessageData:))).map{ a in
            return try self.castOrThrow(Data.self, a[1])
        }
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.0, *)
    public var didReceiveMessageDataWithReplyHandler: Observable<(messageData: Data, replyHandler: (Data) -> Void)> {
        typealias __ChallengeHandler =  @convention(block) (Data) -> Void
        return delegate.methodInvoked(#selector(WCSessionDelegate.session(_:didReceiveMessageData:replyHandler:))).map { arg in
            let message = try self.castOrThrow(Data.self, arg[1])
            /// Now you `Can't` transform closure easily because they are excuted
            /// in the stack if try it you will get the famous error
            /// `Could not cast value of type '__NSStackBlock__' (0x12327d1a8) to`
            /// this is because closures are transformed into a system type which is `__NSStackBlock__`
            /// the above mentioned type is not exposed to `developer`. So everytime
            /// you execute a closure the compiler transforms it into this Object.
            /// So you go through the following steps to get a human readable type
            /// of the closure signature:
            /// 1. closureObject is type of AnyObject to that holds the raw value from
            /// the array.
            var closureObject: AnyObject? = nil
            /// 2. make the array mutable in order to access the `withUnsafeMutableBufferPointer`
            /// fuctionalities
            var mutableArg = arg
            /// 3. Grab the closure at index 3 of the array, but we have to use the C-style
            /// approach to access the raw memory underpinning the array and store it in closureObject
            /// Now the object stored in the `closureObject` is `Unmanaged` and `some unspecified type`
            /// the intelligent swift compiler doesn't know what sort of type it contains. It is Raw.
            mutableArg.withUnsafeMutableBufferPointer { ptr in
                closureObject = ptr[2] as AnyObject
            }
            /// 4. instantiate an opaque pointer to referenc the value of the `unspecified type`
            let __challengeBlockPtr = UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(closureObject as AnyObject).toOpaque())
            /// 5. Here the magic happen we forcefully tell the compiler that anything
            /// found at this memory address that is refrenced should be a type of
            /// `__ChallengeHandler`!
            let handler = unsafeBitCast(__challengeBlockPtr, to: __ChallengeHandler.self)
            return (message, handler)
        }
    }
    
    /** -------------------------- Background Transfers ------------------------- */
    
    @available(iOS 9.3, *)
    @available(watchOS 2.0, *)
    public var didReceiveApplicationContext: Observable<[String: Any]> {
        return delegate.methodInvoked(#selector(WCSessionDelegate.session(_:didReceiveApplicationContext:))).map{ a in
            return try self.castOrThrow([String: Any].self, a[1])
        }
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.0, *)
    public var didFinishUserInfoTransfer: Observable<WCSessionUserInfoTransfer> {
        
        let selector = #selector(
            WCSessionDelegate.session(_:didFinish:error:)
                as ((WCSessionDelegate) -> (WCSession, WCSessionUserInfoTransfer, Error?) -> Void)?
        )
        
        return delegate.methodInvoked(selector).map{ a in
            
            if let error = a[2] as? Error {
                throw error
            }
            
            return try self.castOrThrow(WCSessionUserInfoTransfer.self, a[1])
        }
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.0, *)
    public var didReceiveUserInfo: Observable<[String: Any]> {
        return delegate.methodInvoked(#selector(WCSessionDelegate.session(_:didReceiveUserInfo:))).map{ a in
            return try self.castOrThrow([String: Any].self, a[1])
        }
    }
    
    @available(iOS 9.3, *)
    @available(watchOS 2.0, *)
    public var didFinishFileTransfer: Observable<WCSessionFileTransfer> {
        
        let selector = #selector(
            WCSessionDelegate.session(_:didFinish:error:)
                as ((WCSessionDelegate) -> (WCSession, WCSessionFileTransfer, Error?) -> Void)?
        )
        
        return delegate.methodInvoked(selector).map { a in
            
            if let error = a[2] as? Error {
                throw error
            }
            
            return try self.castOrThrow(WCSessionFileTransfer.self, a[1])
        }
    }
    
    public var didReceiveFile: Observable<WCSessionFile> {
        return delegate.methodInvoked(#selector(WCSessionDelegate.session(_:didReceive:))).map{ a in
            return try self.castOrThrow(WCSessionFile.self, a[1])
        }
    }
    
    fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
        guard let returnValue = object as? T else {
            throw RxCocoaError.castingError(object: object, targetType: resultType)
        }
        
        return returnValue
    }
    
}
