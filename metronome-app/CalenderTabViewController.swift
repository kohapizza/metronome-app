//
//  CalenderTabViewController.swift
//  metronome-app
//
//  Created by 佐伯小遥 on 2024/05/23.
//

import UIKit

class CalenderTabViewController: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    var calendarView: UICalendarView!
    var bpmLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCalendar()
        setupLabel()
        
        printAllBpmRecords()
    }
    
    func printAllBpmRecords() {
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys.filter { $0.starts(with: "2024") } // 例として2024年のデータだけをフィルタリング

        print("All BPM Records:")
        for key in keys {
            if let bpm = defaults.double(forKey: key) as Double? {
                print("\(key): \(bpm)")
            }
        }
    }
    
    
    
    func setUpCalendar(){
        calendarView = UICalendarView()
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        
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
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
            let key = dateFormatter.string(from: date)
            let bpm = UserDefaults.standard.double(forKey: key)
            
            if bpm > 0 {
                return .customView {
                    let emojiLabel = UILabel()
                    emojiLabel.text = "♪"
                    emojiLabel.textAlignment = .center
                    return emojiLabel
                }
            }
        return nil
    }
    
    var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    
    func setupLabel() {
        bpmLabel = UILabel()
        bpmLabel.text = ""
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
    
    // 日付選択したときにその日の最高bpmを表示
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents),
              let key = dateFormatter.string(from: date) as String? else {
            bpmLabel.text = "No data"
            return
        }
        
        let maxBpm = UserDefaults.standard.double(forKey: key)
        bpmLabel.text = maxBpm > 0 ? "Max BPM : \(Int(maxBpm))" : "No Practice"
    }
}
