//
//  HomeViewController.swift
//  metronome-app
//
//  Created by 佐伯小遥 on 2024/05/23.
//

import UIKit
import AVFoundation

class PracticeTabViewController: UIViewController {
    @IBOutlet var metronomeLabel: UILabel!
    @IBOutlet var bpmSlider: UISlider!
    
    @IBOutlet var bpmTextField: UITextField!
    @IBOutlet var durationTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer? // for metronome
    var durationTimer: Timer? // for duration
    var endTime: Date?
    
    var isMetronomeActive: Bool = false
    
    override func viewDidLoad() {
        bpmSlider.value = 100 //初期化
        setupAudioPlayer()
    }
    
    func setupAudioPlayer() {
        guard let soundURL = Bundle.main.url(forResource: "sound", withExtension: "wav") else {
            print("Sound file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
        } catch let error {
            print("Audio player error: \(error.localizedDescription)")
        }
    }
    
    @IBAction func changeBpm(_ sender: UISlider){
        // Int指定
        let sliderValue:Int = Int(bpmSlider.value)
        metronomeLabel.text = String(sliderValue)
        
        if isMetronomeActive{
            restartMetronome()
        }
    }
    
    
    func restartMetronome() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: (60.0 / Double(bpmSlider.value)*2), target: self, selector: #selector(playSound), userInfo: nil, repeats: true)
        isMetronomeActive = true
    }
    
    
    @objc func playSound(){
        audioPlayer?.play()
    }
    
    @IBAction func startMetronome(_ sender: UIButton) {
        isMetronomeActive = true
        
        let nowBpm = max(Double(metronomeLabel.text ?? "120") ?? 120.0, 1.0)
        
        timer?.invalidate() // Stop any existing timer
        timer = Timer.scheduledTimer(timeInterval: (0.5 / nowBpm*2), target: self, selector: #selector(playSound), userInfo: nil, repeats: true)
    }
    
    @IBAction func stopMetronome(_ sender: UIButton) {
        timer?.invalidate()
        isMetronomeActive = false
    }
    

    
    @IBAction func startPractice(_ sender: UIButton) {
        guard let bpmText = bpmTextField.text, let bpm = Double(bpmText),
              let durationText = durationTextField.text, let durationInSeconds = Double(durationText) else {
            print("Invalid BPM or duration")
            return
        }

        startMetronomeWithTimer(bpm: bpm, duration: durationInSeconds)
    }
    
    
    
    @objc func updateRemainingTime() {
        if let endTime = endTime {
            let remainingTime = max(endTime.timeIntervalSinceNow, 0)
            let hours = Int(remainingTime) / 3600
            let minutes = Int(remainingTime) / 60 % 60
            let seconds = Int(remainingTime) % 60
            remainingTimeLabel.text = String(format: "%02i:%02i:%02i", hours, minutes, seconds)
            
            if remainingTime <= 0 {
                durationTimer?.invalidate()
                timer?.invalidate()
                isMetronomeActive = false
                remainingTimeLabel.text = "00:00:00"
            }
        }
    }
    
    func startMetronomeWithTimer(bpm: Double, duration: Double) {
        // メトロノームを開始
        isMetronomeActive = true
        timer?.invalidate() // 既存のタイマーを無効化
        endTime = Date().addingTimeInterval(duration)
        
        timer = Timer.scheduledTimer(timeInterval: 60.0 / bpm, target: self, selector: #selector(playSound), userInfo: nil, repeats: true)
        
        durationTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRemainingTime), userInfo: nil, repeats: true)
    }
    
    
    
    func stopMetronome() {
        timer?.invalidate()
        durationTimer?.invalidate()
        isMetronomeActive = false
        print("Metronome stopped")
        remainingTimeLabel.text = "00:00:00"
    }
    
}
