////
////  SceneDelegate.swift
////  metronome-app
////
////  Created by 佐伯小遥 on 2024/05/22.
////
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // シーンの起動時に呼ばれる
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

}
