////
////  HomeViewController.swift
////  metronome-app
////
////  Created by 佐伯小遥 on 2024/05/23.
////
//
import UIKit
import AVFoundation
import AudioToolbox

class PracticeTabViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var metronomeLabel: UILabel!
    @IBOutlet var bpmTextField: UITextField! // スタートするbpm
    @IBOutlet var durationTextField: UITextField! // 練習周期
    @IBOutlet var changeTextField: UITextField! // 一回ごとに変えるbpm
    @IBOutlet weak var remainingTimeLabel: UILabel! // 残り時間表示
    @IBOutlet weak var messageLabel: UILabel! // 残り時間表示
    
    @IBOutlet var togglePracticeButton: UIButton!
    
    
    @IBOutlet var plusBpmButton: UIButton!
    @IBOutlet var minusBpmButton: UIButton!
    @IBOutlet var plusDurationButton: UIButton!
    @IBOutlet var minusDurationButton: UIButton!
    @IBOutlet var plusChangeButton: UIButton!
    @IBOutlet var minusChangeButton: UIButton!
    
    var isVibrationEnabled: Bool = false // 振動させるか否か
    
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
        loadLastSessionData()
        togglePracticeButton.isEnabled = false;
        minusBpmButton.isEnabled = false
        plusBpmButton.isEnabled = false
        minusChangeButton.isEnabled = false
        plusChangeButton.isEnabled = false
        minusDurationButton.isEnabled = false
        plusDurationButton.isEnabled = false
        
        updateButtonEnabledState()
        
        bpmTextField.delegate = self
        durationTextField.delegate = self
        changeTextField.delegate = self
        
        let grayColor = UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
        togglePracticeButton.backgroundColor = grayColor
        togglePracticeButton.layer.cornerRadius = 40
        
    }
    
    
    // キーボードをしまう
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func toggleVibrationSwitch(_ sender: UISwitch) {
        isVibrationEnabled = sender.isOn  // スイッチの状態に基づいて振動を設定
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
        saveLastBpm()
        print("Metronome stopped")
    }
    
    func loadLastSessionData() {
        let defaults = UserDefaults.standard
        if let lastSession = defaults.object(forKey: "LastSession") as? [String: Any],
           let bpm = lastSession["bpm"] as? Double,
           let date = lastSession["date"] as? Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .none
            
            // 日付の表示のためのフォーマット
            messageLabel.text = "Last BPM: \(bpm) on \(dateFormatter.string(from: date))"
        }
    }
    
    func saveLastBpm(){ // 最後のbpmを保存
        let defaults = UserDefaults.standard
        let lastSessionData = [
            "bpm": currentBpm,
            "date": Date()
        ] as [String : Any]
        defaults.set(lastSessionData, forKey: "LastSession")
        defaults.synchronize()
    }
    
    func stopPractice(){
        stopMetronome()
    }
    
    @objc func playSound() {
        audioPlayer?.play()
        
        if isVibrationEnabled{
            //振動実行
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
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
    
    @IBAction func textFieldDidChangeSelection(_ textField: UITextField) {
        updateButtonEnabledState() // テキストフィールドの選択が変更されるたびに呼び出す
    }
    
    func updateButtonEnabledState() {
        togglePracticeButton.isEnabled = (bpmTextField.text != "") && (durationTextField.text != "") && (changeTextField.text != "")
        minusBpmButton.isEnabled = bpmTextField.text != ""
        plusBpmButton.isEnabled = bpmTextField.text != ""
        minusChangeButton.isEnabled = changeTextField.text != ""
        plusChangeButton.isEnabled = changeTextField.text != ""
        minusDurationButton.isEnabled = durationTextField.text != ""
        plusDurationButton.isEnabled = durationTextField.text != ""
        
        updateButton()
    }
    
    
    
    func updateButton(){
        if togglePracticeButton.isEnabled{
            let buttonColor = UIColor(red: 229/255, green: 145/255, blue: 239/255, alpha: 1)
            let buttonTitle = isMetronomeActive ? "Stop" : "Start"
            togglePracticeButton.setTitle(buttonTitle, for: .normal)
            togglePracticeButton.backgroundColor = buttonColor
            togglePracticeButton.layer.cornerRadius = 40
        }
    }
    
    @IBAction func togglePractice(_ sender: UIButton){
        togglePracticeButton.isEnabled = true;
        
        print(isMetronomeActive)
        if(isMetronomeActive){
            stopPractice()
        }else{
            startPractice()
        }
        updateButton()
    }
    
    @IBAction func plusBpm(_ sender: UIButton){
        var startBpmText = bpmTextField.text ?? ""
        var startBpm = Int(startBpmText) ?? 0
        
        startBpm += 1
        bpmTextField.text = String(startBpm)
    }
    
    @IBAction func minusBpm(_ sender: UIButton){
        var startBpmText = bpmTextField.text ?? ""
        var startBpm = Int(startBpmText) ?? 0
        
        startBpm -= 1
        bpmTextField.text = String(startBpm)
    }
    
    @IBAction func plusDuration(_ sender: UIButton){
        var durationText = durationTextField.text ?? ""
        var duration = Int(durationText) ?? 0
        
        duration += 1
        durationTextField.text = String(duration)
    }
    
    @IBAction func minusDuration(_ sender: UIButton){
        var durationText = durationTextField.text ?? ""
        var duration = Int(durationText) ?? 0
        
        duration -= 1
        durationTextField.text = String(duration)
    }
    
    @IBAction func plusChange(_ sender: UIButton){
        var changeText = changeTextField.text ?? ""
        var change = Int(changeText) ?? 0
        
        change += 1
        changeTextField.text = String(change)
    }
    
    @IBAction func minusChange(_ sender: UIButton){
        var changeText = changeTextField.text ?? ""
        var change = Int(changeText) ?? 0
        
        change -= 1
        changeTextField.text = String(change)
    }
    
    
    func startPractice() {
        isMetronomeActive = true
        guard let bpmText = bpmTextField.text, let initialBpm = Double(bpmText),
              let changeText = changeTextField.text, let bpmIncrement = Double(changeText),
              let durationText = durationTextField.text, let durationInSeconds = Double(durationText) else {
            print("Invalid BPM or duration")
            return
        }
        
        self.bpmIncrement = bpmIncrement
        self.currentBpm = initialBpm
        self.currentTime = durationInSeconds
        self.updateCountdownLabel()
        startMetronomeWithTimer()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {return}
            
            
            
            print("currentBpm :", currentBpm) //OK
            print("currentTime :", currentTime) //OK
            self.currentTime -= 1.0
            self.updateCountdownLabel()
            
            
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
