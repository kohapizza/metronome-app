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
    var suggestLabel: UILabel!
    var trackLabel: UILabel!
    
    // Spotifyマネージャ
    var spotifyManager: SpotifyManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCalendar()
        setupLabel()
        
        //printAllBpmRecords()
        
        setCustomFont()
        
        // Spotifyマネージャの生成
        self.spotifyManager = SpotifyManager()
    }
    
    
    
    func setUpCalendar(){
        calendarView = UICalendarView()
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.fontDesign = .monospaced
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
                emojiLabel.textColor = UIColor(red: 229/255, green: 145/255, blue: 239/255, alpha: 1)
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
        
        suggestLabel = UILabel()
        suggestLabel.text = ""
        suggestLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(suggestLabel)
        suggestLabel.textAlignment = .center
        
        trackLabel = UILabel()
        trackLabel.text = ""
        trackLabel.translatesAutoresizingMaskIntoConstraints = false
        trackLabel.textAlignment = .center
        view.addSubview(trackLabel)
        
        NSLayoutConstraint.activate([
            bpmLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -30),
            bpmLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            bpmLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            suggestLabel.topAnchor.constraint(equalTo: bpmLabel.bottomAnchor, constant: 25),
            suggestLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            suggestLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            trackLabel.topAnchor.constraint(equalTo: suggestLabel.bottomAnchor, constant: 5),
            trackLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            trackLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            calendarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
    
    // 日付選択したときにその日の最高bpmを表示
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents),
              let key = dateFormatter.string(from: date) as String? else {
            bpmLabel.text = "No data"
            suggestLabel.text = ""
            return
        }
        
        let maxBpm = UserDefaults.standard.double(forKey: key)
        if maxBpm > 0 {
            bpmLabel.text = "練習記録 : \(Int(maxBpm)) bpm"
            suggestLabel.text = "この曲で実践してみよう！"
            if let trackInfo = spotifyManager.getTrackForBpm(bpm: Int(maxBpm)) {
                let (trackName, artistName, spotifyURL) = trackInfo
                let attributedText = NSMutableAttributedString(string: "\(trackName) - \(artistName)")
                attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedText.length))
                trackLabel.attributedText = attributedText
                trackLabel.textColor = UIColor(red: 229/255, green: 145/255, blue: 239/255, alpha: 1)
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openSpotify))
                trackLabel.isUserInteractionEnabled = true
                trackLabel.addGestureRecognizer(tapGesture)
                trackLabel.accessibilityValue = spotifyURL
            } else {
                trackLabel.attributedText = nil
                trackLabel.text = "No track found for this BPM"
                trackLabel.textColor = .black
                trackLabel.isUserInteractionEnabled = false
            }
        } else {
            bpmLabel.text = "No Practice"
            trackLabel.text = ""
            suggestLabel.text = ""
        }
    }
    
    @objc func openSpotify(sender: UITapGestureRecognizer) {
        if let urlStr = sender.view?.accessibilityValue, let url = URL(string: urlStr) {
            UIApplication.shared.open(url)
        }
    }
    
    func setCustomFont() {
        let fontName = "ZenMaruGothic-Medium"
        let boldFontName = "ZenMaruGothic-Bold"
        
        
        bpmLabel.font = UIFont(name: fontName, size: 17)
        suggestLabel.font = UIFont(name: fontName, size: 17)
        trackLabel.font = UIFont(name: boldFontName, size: 15)
    }
}
