//
//  SpotofyManager.swift
//  metronome-app
//
//  Created by 佐伯小遥 on 2024/06/07.
//

import UIKit
import WebKit

class SpotifyManager : NSObject {
    // 設定
    private let clientID = "d46db3e5d9ec43c1982670a7b09886ed"
    private let redirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback.")!

    // AppRemote
    var appRemote: SPTAppRemote!
    
    // 初期化
    override init() {
        super.init()

        // AppRemoteの生成
        let configuration = SPTConfiguration(clientID: self.clientID, redirectURL: self.redirectURL)
        self.appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
    }
    
    // URLコンテキストの取得時に呼ばれる
    func onURLContext(_ url: URL) {
        let parameters = appRemote.authorizationParameters(from: url);
        if let accessToken = parameters?[SPTAppRemoteAccessTokenKey] {
            self.appRemote.connectionParameters.accessToken = accessToken
        } else if let errorDescription = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print("error : ", errorDescription)
        }
    }

    // 音楽の再生
    func authorizeAndPlayURI(_ playUrl: String) {
        self.appRemote.authorizeAndPlayURI(playUrl)
    }
}
