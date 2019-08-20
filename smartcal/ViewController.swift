//
//  ViewController.swift
//  smartcal
//
//  Created by Feynman on 8/15/19.
//  Copyright © 2019 Feynman. All rights reserved.
//

import UIKit
import OAuthSwift
import struct Engine.AuthState
import struct Engine.Env

private let redirectUrl = URL(string: Env.Google.redirectUrl)
private let scope = Env.Google.scope
private let state = Env.Google.state
private let oauthSwift = OAuth2Swift(consumerKey: Env.Google.clientId,
                                     consumerSecret: Env.Google.clientSecret,
                                     authorizeUrl: Env.Google.authorizeUrl,
                                     accessTokenUrl: Env.Google.accessTokenUrl,
                                     responseType: "code")

class ViewController: UIViewController {

    @IBOutlet var connectButton: UIButton!
    @IBOutlet var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        oauthSwift.allowMissingStateCheck = true
        oauthSwift.authorizeURLHandler = SafariURLHandler(viewController: self,
                                                          oauthSwift: oauthSwift)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        insertText()
        
        self.connectButton.setTitle("Connect with Google", for: .normal)
        self.connectButton.addTarget(self, action: #selector(connect(_:)), for: .primaryActionTriggered)
    }
    
    // MARK: - Button Actions
    
    @objc func connect(_ sender: UIButton) {
//        if oauthSwift.client.credential.isTokenExpired() {
//            oauthSwift.renewAccessToken(withRefreshToken: AuthState.getRefreshToken()!) { result in
//                switch result {
//                case .success(let (cred,_,_)):
//                    AuthState.setAccessToken(cred.oauthToken)
//                    AuthState.setRefreshToken(cred.oauthRefreshToken)
//                    self.statusText(.success)
//                case .failure(let err):
//                    debugPrint(err)
//                    self.statusText(.failure)
//                }
//            }
//            return
//        }
        
        oauthSwift.authorize(withCallbackURL: Env.Google.redirectUrl, scope: scope, state: state) { result in
            switch result {
            case .success(let (cred,_,_)):
                AuthState.setAccessToken(cred.oauthToken)
                AuthState.setRefreshToken(cred.oauthRefreshToken)
                self.statusText(.success)
            case .failure(let err):
                debugPrint(err)
                self.statusText(.failure)
            }
        }
    }
    
    // MARK: - TextView
    
    private func insertText() {
        let size = 20

        textView.insertText(
            """
            Access Token: \(AuthState.getAccessToken()?.prefix(size) ?? "none")
            Refresh Token: \(AuthState.getRefreshToken()?.prefix(size) ?? "none")
            \n
            """
        )
    }
    
    private enum Status {
        case success
        case failure
    }
    
    private func statusText(_ status: Status) {
        switch status {
        case .success:
            textView.insertText("Success!\n")
        case .failure:
            textView.insertText("Failure!\n")
        }
        
        insertText()
    }
}

