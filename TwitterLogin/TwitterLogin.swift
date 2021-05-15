//
//  TwitterLogin.swift
//  TalkLeague
//
//  Created by Manu Singh on 05/06/20.
//  Copyright © 2020 neargroup. All rights reserved.
//

import Foundation
import UIKit

public class TwitterLogin {

    public weak var delegate : TwitterLoginDelegate?

    var twitterApi : TwitterLoginApis
    var twitterLoginStorage : TwitterLoginDataStorage
    var twitterLoginUIHandler = TwitterLoginWebViewHandler()
        
    init(twitterApi : TwitterLoginApis,twitterLoginStorage:TwitterLoginDataStorage) {
        self.twitterApi = twitterApi
        self.twitterLoginStorage = twitterLoginStorage
        twitterLoginUIHandler.delegate = self
        addTwitterCallbackNotification()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func login(){
        twitterApi.getRequestToken { (result) in
            switch result {
            case .success(let auth, let authSecret):
                self.showAuthenticationWebView(authValues: (auth,authSecret))
            case .failure(let error):
                self.delegate?.twitterLoginFailed(sender: self, with: error)
            }
        }
    }
    
    private func addTwitterCallbackNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(onReceiveTwitterCallback), name: .twitterCallback, object: nil)
    }
    
    @objc private func onReceiveTwitterCallback(_ notification : Notification){
        guard let callBackUrl = notification.object as? URL else { return }
        twitterLoginUIHandler.dismissWebview()
        let queryStringComponents = callBackUrl.getUrlComponents()
        guard let oAuthToken = queryStringComponents["oauth_token"] else {
            self.delegate?.twitterLoginCancelled(sender: self)
            return
        }
        let oAuthVerifier = queryStringComponents["oauth_verifier"]!
        twitterApi.getAccessToken(authVerifier: oAuthVerifier,authToken: oAuthToken) { result in
            switch result {
            case .success(let tokens):
                self.twitterLoginStorage.saveTwitterLoginData(tokens)
                self.delegate?.twitterLoginCompleted(sender: self, with: TwitterLoginUser.init(userId: tokens.userId, oauthToken: tokens.oauthToken, oauthTokenSecret: tokens.oauthTokenSecret))
                
            case .failure(let error):
                self.delegate?.twitterLoginFailed(sender: self, with: error)
            }
        }
    }
    
    private func showAuthenticationWebView(authValues:(String,String)){
        twitterLoginUIHandler.presentWebView(with: "https://api.twitter.com/oauth/authorize?oauth_token=\(authValues.0)")
    }
}

extension TwitterLogin : TwitterLoginWebViewHandlerDelegate {
    func twitterWebviewDidCancel(_ sender: TwitterLoginWebViewHandler) {
        delegate?.twitterLoginCancelled(sender: self)
    }
    
    func twitterWebview(_ sender: TwitterLoginWebViewHandler, showWebView: UIViewController) {
        delegate?.twitterLoginPresent(sender: self, controller: showWebView)
    }
    
    func twitterWebview(_ sender : TwitterLoginWebViewHandler,dismiss: UIViewController){
        delegate?.twitterLoginDismiss(sender: self, controller: dismiss)
    }
}

public protocol TwitterLoginDelegate : class {
    func twitterLoginCompleted(sender : TwitterLogin, with userDetails : TwitterLoginUser )
    func twitterLoginFailed(sender : TwitterLogin, with error : Error)
    func twitterLoginPresent(sender : TwitterLogin, controller : UIViewController)
    func twitterLoginDismiss(sender : TwitterLogin, controller : UIViewController)
    func twitterLoginCancelled(sender : TwitterLogin)
}

public class TwitterLoginUser {
    public var userId:String
    public var oauthToken : String
    public var oauthTokenSecret : String
    init(userId:String,oauthToken : String,oauthTokenSecret:String){
        self.userId = userId
        self.oauthToken = oauthToken
        self.oauthTokenSecret = oauthTokenSecret
    }
}

extension String {
    
    public func getUrlComponents()->[String:String]{
        let url = URL(string:self)!
        return url.getUrlComponents()
    }
    
    func getDeeplinkSource()->String?{
        let components = getUrlComponents()
        return components["source"]
    }
    func getInviteCodeId()->String?{
           let components = getUrlComponents()
           return components["invitecode"]
    }
}

extension URL {
    public func getUrlComponents()->[String:String]{
        var dict = [String:String]()
        let components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        if let queryItems = components.queryItems {
            for item in queryItems {
                dict[item.name] = item.value!
            }
        }
        return dict
    }
}

extension TwitterAccessToken : TwitterLoginDataConvertible {
    var oauthToken: String {
        return self.oAuthToken
    }
    var oauthTokenSecret: String {
        return self.oAuthTokenSecret
    }
}
