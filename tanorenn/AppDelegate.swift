////
////  AppDelegate.swift
////  metronome-app
////
////  Created by 佐伯小遥 on 2024/05/22.
////
///
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // アプリ起動時に呼ばれる
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    // シーンの起動時に呼ばれる
    func application(_ application: UIApplication, configurationForConnecting
        connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // シーンの終了時に呼ばれる
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
