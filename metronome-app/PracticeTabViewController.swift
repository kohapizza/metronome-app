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
    @IBOutlet var bpmSlider: UISlider!

    var audioPlayer: AVAudioPlayer?
    var timer: Timer? // for metronome
    var durationTimer: Timer? // for duration
    var currentBpm: Double = 120.0
    var bpmIncrement: Double = 0.0
    var durationInSeconds: Double = 60.0
    
    var isMetronomeActive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioPlayer()
        bpmSlider.value = Float(currentBpm)
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

    @IBAction func startPractice(_ sender: UIButton) {
        guard let bpmText = bpmTextField.text, let initialBpm = Double(bpmText),
              let changeText = chengeTextField.text, let bpmIncrement = Double(changeText),
              let durationText = durationTextField.text, let durationInSeconds = Double(durationText) else {
            print("Invalid BPM or duration")
            return
        }

        self.currentBpm = initialBpm
        self.bpmIncrement = bpmIncrement
        self.durationInSeconds = durationInSeconds
        startMetronomeWithTimer()
    }

    func startMetronomeWithTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 60.0 / currentBpm, target: self, selector: #selector(playSound), userInfo: nil, repeats: true)
        
        durationTimer?.invalidate()
        durationTimer = Timer.scheduledTimer(withTimeInterval: durationInSeconds, repeats: false) { [weak self] _ in
            self?.updateBpmAndRestartMetronome()
        }
    }

    @objc func playSound() {
        audioPlayer?.play()
    }

    func updateBpmAndRestartMetronome() {
        currentBpm += bpmIncrement
        metronomeLabel.text = String(format: "%.0f", currentBpm)
        startMetronomeWithTimer()
    }

    @IBAction func stopPractice(_ sender: UIButton){
        stopMetronome()
    }

    func stopMetronome() {
        timer?.invalidate()
        durationTimer?.invalidate()
        isMetronomeActive = false
        remainingTimeLabel.text = "00:00"
        print("Metronome stopped")
    }
}
