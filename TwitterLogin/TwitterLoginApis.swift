//
//  TwitterLoginApis.swift
//  TalkLeague
//
//  Created by Manu Singh on 06/06/20.
//  Copyright © 2020 neargroup. All rights reserved.
//

import Foundation
import CommonCrypto

public protocol HTTPPostRequestSender {
    func sendPostRequest(requestData : TwitterLoginRequestData, completion : @escaping (Error?,Any?)->Void)
}

public struct TwitterLoginRequestData {
    public var url : String
    public var parameters : [String:Any]
    public var headers : [String:String]
    
    public init(url : String,parameters : [String:Any],headers : [String:String]){
        self.url = url
        self.parameters = parameters
        self.headers = headers
    }
}


class TwitterLoginApis {
    
    var network : HTTPPostRequestSender
    var config:TwitterLoginConfiguration
    
    init(network : HTTPPostRequestSender,config:TwitterLoginConfiguration){
        self.network = network
        self.config = config
    }
    
    private var tokenUrl = "https://api.twitter.com"
    private var tokenEndPoint = "oauth/request_token"
    private var accessToken = "oauth/access_token"
    
    func getRequestToken(completion : @escaping(TwitterTokenResult)->Void){
        let requestUrl = "\(tokenUrl)/\(tokenEndPoint)"
        let requestData = TwitterLoginRequestData.init(url: "\(tokenUrl)/\(tokenEndPoint)", parameters: [:], headers: getAuthorizationHeader(url: requestUrl))
        network.sendPostRequest(requestData: requestData) { (error, response) in
            
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            if let responseString = response as? String {
                let values = responseString.urlQueryStringParameters
                completion(.success(values["oauth_token"]!, values["oauth_token_secret"]!))
                return
            }
            completion(.failure(TwitterLoginError.init("Server Error")))
        }
    }
    
    func getAccessToken(authVerifier : String,authToken:String,completion:@escaping(TwitterAccessTokenResult)->Void){
        let requestUrl = "\(tokenUrl)/\(accessToken)"
        let headers = getAuthorizationHeader(url: requestUrl,authVerifier: authVerifier,authToken: authToken)
        let requestData = TwitterLoginRequestData.init(url: requestUrl, parameters: [:], headers: headers)
        network.sendPostRequest(requestData: requestData) { (error, response) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            if let responseString = response as? String {
                let values = responseString.urlQueryStringParameters
                let oAuthToken = values["oauth_token"]!
                let oAuthTokenSecret = values["oauth_token_secret"]!
                let userId = values["user_id"]!
                completion(.success(.init(oAuthToken: oAuthToken, oAuthTokenSecret: oAuthTokenSecret, userId: userId)))
                return
            }
            completion(.failure(TwitterLoginError.init("Server Error")))
            
        }
    }
    
    private func getAuthorizationHeader(url : String)->[String:String]{
        
        var params: [String: Any] = [
          "oauth_callback" : getUrlEncodedCallback(),
          "oauth_consumer_key" : self.config.twitterApiKey,
          "oauth_nonce" : generateAuthNounce(),
          "oauth_signature_method" : "HMAC-SHA1",
          "oauth_timestamp" : getTimeStamp(),
          "oauth_version" : "1.0"
        ]
        
        params["oauth_signature"] = oauthSignature(httpMethod: "POST", url: url,
                                                   params: params, consumerSecret: self.config.twitterApiSecretKey)
        
        let authHeader = authorizationHeader(params: params)
        return ["Authorization":authHeader]
    }
    
    private func getAuthorizationHeader(url : String,authVerifier:String,authToken:String)->[String:String] {
        var params: [String: Any] = [
          "oauth_callback" : getUrlEncodedCallback(),
            "oauth_consumer_key" : self.config.twitterApiKey,
          "oauth_nonce" : generateAuthNounce(),
          "oauth_signature_method" : "HMAC-SHA1",
          "oauth_timestamp" : getTimeStamp(),
          "oauth_version" : "1.0",
          "oauth_verifier":authVerifier,
          "oauth_token":authToken
        ]
        
        params["oauth_signature"] = oauthSignature(httpMethod: "POST", url: url,
                                                   params: params, consumerSecret: self.config.twitterApiSecretKey)
        
        let authHeader = authorizationHeader(params: params)
        return ["Authorization":authHeader]
    }
    
    fileprivate func authorizationHeader(params: [String: Any]) -> String {
      var parts: [String] = []
      for param in params {
        let key = param.key.urlEncoded
        let val = "\(param.value)".urlEncoded
        parts.append("\(key)=\"\(val)\"")
      }
      return "OAuth " + parts.sorted().joined(separator: ", ")
    }
    
    fileprivate func generateAuthNounce()->String{
        
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let boundary = String((0..<35).map{ _ in letters.randomElement()! })
        return boundary
        
    }
    
    fileprivate func oauthSignature(httpMethod: String = "POST", url: String,
                        params: [String: Any], consumerSecret: String,
                        oauthTokenSecret: String? = nil) -> String {
      
      let signingKey = signatureKey(consumerSecret, oauthTokenSecret)
      let signatureBase = signatureBaseString(httpMethod, url, params)
      return hmac_sha1(signingKey: signingKey, signatureBase: signatureBase)
      
    }
    
    fileprivate func signatureKey(_ consumerSecret: String,_ oauthTokenSecret: String?) -> String {
      
        guard let oauthSecret = oauthTokenSecret?.urlEncoded
              else { return consumerSecret.urlEncoded+"&" }
      
        return consumerSecret.urlEncoded+"&"+oauthSecret
      
    }
    
    fileprivate func signatureBaseString(_ httpMethod: String = "POST",_ url: String,
                             _ params: [String:Any]) -> String {
      
      let parameterString = signatureParameterString(params: params)
      return httpMethod + "&" + url.urlEncoded + "&" + parameterString.urlEncoded
      
    }
    
    fileprivate func signatureParameterString(params: [String: Any]) -> String {
      var result: [String] = []
      for param in params {
        let key = param.key.urlEncoded
        let val = "\(param.value)".urlEncoded
        result.append("\(key)=\(val)")
      }
      return result.sorted().joined(separator: "&")
    }
    
    fileprivate func getUrlEncodedCallback()->String{
        return self.config.twitterCallBackScheme//.urlEncoded
        //"twitterkit-\(TwitterApiKey)?source=twitter".urlEncoded//.addingPercentEncoding(withAllowedCharacters: .)!
    }
    
    fileprivate func getTimeStamp()->String{
        return "\(Date.init().timeIntervalSince1970)"
    }
    
    fileprivate func hmac_sha1(signingKey: String, signatureBase: String) -> String {
      // HMAC-SHA1 hashing algorithm returned as a base64 encoded string
      var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
      CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), signingKey, signingKey.count, signatureBase, signatureBase.count, &digest)
      let data = Data(digest)
      return data.base64EncodedString()
    }
}

extension String {
  var urlEncoded: String {
    var charset: CharacterSet = .urlQueryAllowed
    charset.remove(charactersIn: "\n:#/?@!$&'()*+,;=")
    return self.addingPercentEncoding(withAllowedCharacters: charset)!
  }
}

extension String {
  var urlQueryStringParameters: Dictionary<String, String> {
    // breaks apart query string into a dictionary of values
    var params = [String: String]()
    let items = self.split(separator: "&")
    for item in items {
      let combo = item.split(separator: "=")
      if combo.count == 2 {
        let key = "\(combo[0])"
        let val = "\(combo[1])"
        params[key] = val
      }
    }
    return params
  }
}

enum TwitterTokenResult{
    case success(String,String)
    case failure(Error)
}

enum TwitterAccessTokenResult {
    case success(TwitterAccessToken)
    case failure(Error)
}

struct TwitterAccessToken{
    var oAuthToken:String
    var oAuthTokenSecret : String
    var userId:String
}

