//
//  GameTabViewController.swift
//  metronome-app
//
//  Created by 佐伯小遥 on 2024/05/23.
//

import UIKit

class GameTabViewController: UIViewController {

    // Spotifyマネージャ
    var spotifyManager: SpotifyManager!

    // ロード時に呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Spotifyマネージャの生成
        self.spotifyManager = SpotifyManager()
    }

    // URLコンテキスト取得時に呼ばれる
    func onOpenURLContext(_ url: URL) {
        self.spotifyManager.onURLContext(url)
    }

    // ボタンクリック時に呼ばれる
    @IBAction func onClick(sender: UIButton) {
        self.spotifyManager.authorizeAndPlayURI("spotify:track:0pOh4SGNsJ298cNpnSiAYa")
    //https://open.spotify.com/intl-ja/track/0pOh4SGNsJ298cNpnSiAYa?si=0e7548daeab3494c
    }

}
