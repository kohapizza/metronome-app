////
////  HomeViewController.swift
////  metronome-app
////
////  Created by 佐伯小遥 on 2024/05/23.
////
//
import UIKit
import AVFoundation

class PracticeTabViewController: UIViewController {
    @IBOutlet var metronomeLabel: UILabel!
    @IBOutlet var bpmTextField: UITextField! // スタートするbpm
    @IBOutlet var durationTextField: UITextField! // 練習周期
    @IBOutlet var chengeTextField: UITextField! // 一回ごとに変えるbpm
    @IBOutlet weak var remainingTimeLabel: UILabel! // 残り時間表示
    @IBOutlet weak var messageLabel: UILabel! // 残り時間表示
    
    var audioPlayer: AVAudioPlayer?
    
    var countdownTimer: Timer? // for metronome
    var durationTimer: Timer? // for duration
    
    var currentBpm: Double = 120.0
    var bpmIncrement: Double = 0.0
    var durationInSeconds: Double = 60.0
    
    var currentTime: TimeInterval = 0.0
    
    var isMetronomeActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    
    func stopMetronome() {
        countdownTimer?.invalidate()
        durationTimer?.invalidate()
        isMetronomeActive = false
        remainingTimeLabel.text = "00:00"
        print("Metronome stopped")
    }
    
    @IBAction func stopPractice(_ sender: UIButton){
        stopMetronome()
    }
    
    @objc func playSound() {
        audioPlayer?.play()
    }
    
    func displayTextForSeconds(_ text: String, duration: TimeInterval) {
            messageLabel.text = text
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.messageLabel.text = ""
            }
    }
    
    func updateCountdownLabel() {
        remainingTimeLabel.text = "Time remaining: \(Int(currentTime)) seconds"
    }
    
    func updateMessageLabel(){
        displayTextForSeconds("tempo is up!", duration: 3)
    }
    

    func startMetronomeWithTimer() {
        durationTimer?.invalidate()
        metronomeLabel.text = String(format: "%.0f", currentBpm)
        durationTimer = Timer.scheduledTimer(timeInterval: 60.0 / currentBpm, target: self, selector: #selector(playSound), userInfo: nil, repeats: true)
        
    }
    
    @IBAction func startPractice(_ sender: UIButton) {
        guard let bpmText = bpmTextField.text, let initialBpm = Double(bpmText),
              let changeText = chengeTextField.text, let bpmIncrement = Double(changeText),
              let durationText = durationTextField.text, let durationInSeconds = Double(durationText) else {
            print("Invalid BPM or duration")
            return
        }
        
        self.bpmIncrement = bpmIncrement
        self.currentBpm = initialBpm
        self.currentTime = durationInSeconds
        
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {return}
            
            
            self.updateCountdownLabel()
            print("currentBpm :", currentBpm) //OK
            print("currentTime :", currentTime) //OK
            self.currentTime -= 1.0
            
            
            if self.currentTime <= 0{
                self.updateCountdownLabel()
                self.currentTime = durationInSeconds
                
                self.updateMessageLabel()
                self.updateCountdownLabel()
                self.startMetronomeWithTimer()
                self.currentBpm += bpmIncrement
                
            }
        }
    }
}
