//
//  CalenderTabViewController.swift
//  metronome-app
//
//  Created by 佐伯小遥 on 2024/05/23.
//

import UIKit
import EventKit

class CalenderTabViewController: UIViewController, UICalendarViewDelegate {
    var calendarView: UICalendarView!
    var bpmLabel: UILabel!
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCalendar()
        setupLabel()
        
    }
    
    func setUpCalendar(){
        calendarView = UICalendarView()
        calendarView.delegate = self
        calendarView.tintColor = UIColor(red: 229/255, green: 145/255, blue: 239/255, alpha: 1)
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendarView)
        
        NSLayoutConstraint.activate([
            self.view.topAnchor.constraint(equalTo: calendarView.topAnchor),
            self.view.leftAnchor.constraint(equalTo: calendarView.leftAnchor),
            self.view.rightAnchor.constraint(equalTo: calendarView.rightAnchor)
        ])
    }
    
    func setupLabel() {
        bpmLabel = UILabel()
        bpmLabel.text = "あああああ"
        bpmLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bpmLabel)
        bpmLabel.textAlignment = .center
        NSLayoutConstraint.activate([
            bpmLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 20),
            bpmLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            bpmLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
    // ユーザーが日付を選択したときの処理
    func touchCalendarView(_ calendarView: UICalendarView, didSelectDate dateComponents: DateComponents) {
        guard let date = Calendar.current.date(from: dateComponents) else { return }
        let key = dateFormatter.string(from: date)
        let maxBpm = UserDefaults.standard.double(forKey: key)
        bpmLabel.text = "Max BPM on \(key): \(maxBpm)"
        print("key: ", key)
        print("maxBpm :", maxBpm)
    }
}
