//
//  TwitterConfiguration.swift
//  TwitterLogin
//
//  Created by Manu Singh on 06/02/21.
//

import Foundation

public struct TwitterLoginConfiguration {
    public var twitterApiKey : String
    public var twitterApiSecretKey : String
    public var twitterCallBackScheme : String
    
    public init(twitterApiKey : String,twitterApiSecretKey : String,twitterCallBackScheme:String){
        self.twitterApiKey = twitterApiKey
        self.twitterApiSecretKey = twitterApiSecretKey
        self.twitterCallBackScheme = twitterCallBackScheme
    }
    
}
