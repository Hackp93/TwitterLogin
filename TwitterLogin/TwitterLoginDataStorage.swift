//
//  TwitterLoginDataStorage.swift
//  TalkLeague
//
//  Created by Manu Singh on 08/06/20.
//  Copyright © 2020 neargroup. All rights reserved.
//

import Foundation

class TwitterLoginDataStorage {
    
    var userDefault = UserDefaults.standard
    
    var twitterLoginDataDefaultKey = "twitterLoginDataDefaultKey"
    
    func saveTwitterLoginData(_ loginData : TwitterLoginDataConvertible){
        let twitterLoginDictionary = ["oauth_token":loginData.oauthToken,"oauth_token_secret":loginData.oauthTokenSecret,"userId":loginData.userId]
        userDefault.set(twitterLoginDictionary, forKey: twitterLoginDataDefaultKey)
    }
    
    func getTwitterLoginData()->TwitterLoginDataConvertible? {
        if let loginData = userDefault.value(forKey: twitterLoginDataDefaultKey) as? [String:String] {
            let oauthToken = loginData["oauth_token"]!
            let oauthTokenSecret = loginData["oauth_token_secret"]!
            let userId = loginData["userId"]!
            return TwitterLoginDefaultData.init(userId: userId, oauthToken: oauthToken, oauthTokenSecret: oauthTokenSecret)
        }
        return nil
    }
}

protocol TwitterLoginDataConvertible {
    var userId : String { get }
    var oauthToken : String { get }
    var oauthTokenSecret : String { get }
}

fileprivate struct TwitterLoginDefaultData : TwitterLoginDataConvertible {
    var userId: String
    var oauthToken: String
    var oauthTokenSecret: String
}


