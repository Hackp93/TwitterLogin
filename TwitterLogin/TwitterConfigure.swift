//
//  TwitterConfigure.swift
//  TalkLeague
//
//  Created by Sumendra Sheela Thakur on 01/06/20.
//  Copyright © 2020 neargroup. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    public static let twitterCallback = Notification.Name(rawValue: "Twitter.CallbackNotification.Name")
}

public class TwitterCallBackHandler {
    
    public init(){}
    
    public func handleTwitterCallback(callbackScheme scheme: String, url: URL?)->Bool {
        self.handleTwitterCallback(notificationName: .twitterCallback, callbackScheme: scheme, url: url)
    }
    
    func handleTwitterCallback(notificationName: Notification.Name,
                       callbackScheme scheme: String, url: URL?)->Bool {
        guard let url = url,
              let urlScheme = url.scheme,
              let callbackUrl = URL(string: "\(scheme)://"),
              let callbackScheme = callbackUrl.scheme
        else { return false }
        guard urlScheme.caseInsensitiveCompare(callbackScheme) == .orderedSame else { return false }
        // If the schemes match, we will include the URL in a the object of the notification and Post
        let notification = Notification(name: notificationName,object: url, userInfo: nil)
        NotificationCenter.default.post(notification)
        return true
    }
}
