//
//  TwitterLoginFactory.swift
//  TwitterLogin
//
//  Created by Manu Singh on 06/02/21.
//

import Foundation

public class TwitterLoginFactory {
    public static func createLogin(_ networkHandler:HTTPPostRequestSender,config:TwitterLoginConfiguration,delegate:TwitterLoginDelegate?)->TwitterLogin {
        let twitterLogin = TwitterLoginApis.init(network: networkHandler, config: config)
        let storage = TwitterLoginDataStorage.init()
        let login = TwitterLogin.init(twitterApi: twitterLogin, twitterLoginStorage: storage)
        login.delegate = delegate
        return login
    }
}
