//
//  TwitterLoginWebViewHandler.swift
//  TalkLeague
//
//  Created by Manu Singh on 10/06/20.
//  Copyright © 2020 neargroup. All rights reserved.
//

import Foundation
import SafariServices

class  TwitterLoginWebViewHandler: NSObject {
    
    weak var delegate : TwitterLoginWebViewHandlerDelegate?
    
    weak var safariViewController : SFSafariViewController?
    
    func presentWebView(with url : String){
        let webViewController = SFSafariViewController(url:URL(string: url)!)
        webViewController.delegate = self
        safariViewController = webViewController
        delegate?.twitterWebview(self, showWebView: webViewController)
    }
    
    func dismissWebview(){
        if let webViewController = safariViewController {
            delegate?.twitterWebview(self, dismiss: webViewController)
        }
    }
    
}

extension TwitterLoginWebViewHandler : SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        delegate?.twitterWebviewDidCancel(self)
    }
}

protocol TwitterLoginWebViewHandlerDelegate : class {
    func twitterWebviewDidCancel(_ sender : TwitterLoginWebViewHandler)
    func twitterWebview(_ sender : TwitterLoginWebViewHandler, showWebView : UIViewController)
    func twitterWebview(_ sender : TwitterLoginWebViewHandler,dismiss: UIViewController)
}
