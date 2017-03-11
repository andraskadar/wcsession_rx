//
//  MessageConverter.swift
//  Demo
//
//  Created by Inomoto Shintaro on 2017/03/09.
//  Copyright © 2017年 Shintaro Inomoto. All rights reserved.
//

import Foundation

class MessageConverter {
    private static let DescriptionKey = "jp.xxx.key.description"
    
    class func message(from userInfo: [String: Any]) -> String? {
        return userInfo[DescriptionKey] as? String
    }
    
    class func userInfo(from message: String) -> [String: Any] {
        return [DescriptionKey: message]
    }
}
