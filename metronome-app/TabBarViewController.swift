//
//  TabBarViewController.swift
//  metronome-app
//
//  Created by 佐伯小遥 on 2024/05/23.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var menuViewControllers: [UIViewController] = []
        
        let homeTabViewController = HomeViewController()
        let practiceTabViewController = PracticeTabViewController()
        let calendarTabViewController = CalenderTabViewController()
        let gameTabViewController = GameTabViewController()
        
        menuViewControllers.append(homeTabViewController)
        menuViewControllers.append(practiceTabViewController)
        menuViewControllers.append(calendarTabViewController)
        menuViewControllers.append(gameTabViewController)
        
        self.setViewControllers(menuViewControllers, animated: false)
        

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
