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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
