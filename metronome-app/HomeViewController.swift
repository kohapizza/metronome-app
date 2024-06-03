//
//  HomeViewController.swift
//  metronome-app
//
//  Created by 佐伯小遥 on 2024/05/23.
//

import UIKit
import AVFoundation

class HomeViewController: UIViewController {
    @IBOutlet var metronomeLabel: UILabel!
    @IBOutlet var bpmSlider: UISlider!
    
    @IBOutlet var musicButton: UIButton!
    
    var audioPlayer: AVAudioPlayer?
    var timer: Timer?
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
        //print(bpmSlider.value) OK
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: (60.0 / Double(bpmSlider.value)), target: self, selector: #selector(playSound), userInfo: nil, repeats: true)
        isMetronomeActive = true
        print("Now BPM :", bpmSlider.value) // OK
    }
    
    @objc func playSound(){
        audioPlayer?.play()
    }
    
    func startMetronome() {
        isMetronomeActive = true
        
        let nowBpm = max(Double(metronomeLabel.text ?? "120") ?? 120.0, 1.0)
        print("Now BPM :", nowBpm) // OK
        
        timer?.invalidate() // Stop any existing timer
        timer = Timer.scheduledTimer(timeInterval: (60.0 / nowBpm), target: self, selector: #selector(playSound), userInfo: nil, repeats: true)
    }
    
    func stopMetronome() {
        timer?.invalidate()
        isMetronomeActive = false
    }
    
    @IBAction func upBpm(_ sender: UIButton){
        bpmSlider.value += 1
        metronomeLabel.text = String(Int(bpmSlider.value))
        
        if isMetronomeActive{
            restartMetronome()
        }
    }
    
    @IBAction func downBpm(_ sender: UIButton){
        bpmSlider.value -= 1
        metronomeLabel.text = String(Int(bpmSlider.value))
        
        if isMetronomeActive{
            restartMetronome()
        }
    }
    
    @IBAction func toggleMetronome(_ sender: UIButton) {
        updateButton()
        if isMetronomeActive {
            stopMetronome()
        } else {
            startMetronome()
        }
    }
    
    func updateButton(){
        let buttonImage = isMetronomeActive ? UIImage(systemName: "play.fill") : UIImage(systemName: "pause.fill")
        musicButton.setImage(buttonImage, for: .normal)
    }

}
