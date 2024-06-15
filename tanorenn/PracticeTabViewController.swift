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
import CoreHaptics

class PracticeTabViewController: UIViewController, UITextFieldDelegate {
    
    var hapticEngine: CHHapticEngine?
    
    @IBOutlet var metronomeLabel: UILabel!
    @IBOutlet var bpmTextField: UITextField! // スタートするbpm
    @IBOutlet var durationTextField: UITextField! // 練習周期
    @IBOutlet var changeTextField: UITextField! // 一回ごとに変えるbpm
    @IBOutlet weak var messageLabel: UILabel! // 残り時間表示
    
    @IBOutlet var togglePracticeButton: UIButton!
    
    @IBOutlet var progressView: UIProgressView!
    
    //error message
    @IBOutlet var errorBpmMessageLabel: UILabel!
    @IBOutlet var errorDurationMessageLabel: UILabel!
    @IBOutlet var errorChangeMessageLabel: UILabel!
    
    
    @IBOutlet var plusBpmButton: UIButton!
    @IBOutlet var minusBpmButton: UIButton!
    @IBOutlet var plusDurationButton: UIButton!
    @IBOutlet var minusDurationButton: UIButton!
    @IBOutlet var plusChangeButton: UIButton!
    @IBOutlet var minusChangeButton: UIButton!
    
    @IBOutlet var bpmTextLabel: UILabel!
    @IBOutlet var secondTextLabel: UILabel!
    @IBOutlet var changeTextLabel: UILabel!
    @IBOutlet var vibeTextLabel: UILabel!
    @IBOutlet var tempoUpLabel: UILabel!
    
    
    var isVibrationEnabled: Bool = true // 振動させるか否か
    
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
        
        createHapticEngine()
        
        setCustomFont() // フォントの適用
        
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
        bpmTextField.keyboardType = UIKeyboardType.numberPad
        durationTextField.delegate = self
        durationTextField.keyboardType = UIKeyboardType.numberPad
        changeTextField.delegate = self
        changeTextField.keyboardType = UIKeyboardType.numberPad
        
        let grayColor = UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
        togglePracticeButton.setTitle("Start",for: .normal)
        togglePracticeButton.titleLabel?.font = UIFont(name: "ZenMaruGothic-Medium", size: togglePracticeButton.titleLabel?.font.pointSize ?? 17)
        togglePracticeButton.setTitle(togglePracticeButton.currentTitle, for: .normal)
        togglePracticeButton.backgroundColor = grayColor
        togglePracticeButton.layer.cornerRadius = 40
    }
    
    func createHapticEngine() {
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine Creation Error: \(error)")
        }
    }
    
    // キーボードをしまう
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // 振動有無
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
        
        bpmTextField.isEnabled = true
        durationTextField.isEnabled = true
        changeTextField.isEnabled = true
        
        updateButtonEnabledState()
        validateInputFields()
        
        print("ボタン",togglePracticeButton.isEnabled)
        
        saveLastBpm()
        saveBpmForCurrentSession(bpm: currentBpm)
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
            messageLabel.text = "前回の記録は \(Int(bpm)) だよ！"
        }
    }


    // 最後に練習したbpmを保存
    func saveLastBpm(){
        let defaults = UserDefaults.standard
        let lastSessionData = [
            "bpm": currentBpm,
            "date": Date()
        ] as [String : Any]
        defaults.set(lastSessionData, forKey: "LastSession")
        defaults.synchronize()
    }
    
    // 1日の最高Bpmを保存したい！！！！！！
    func saveBpmForCurrentSession(bpm: Double) {
        let key = getCurrentDateKey()
        let maxBpm = UserDefaults.standard.double(forKey: key)
        if bpm > maxBpm {
            UserDefaults.standard.set(bpm, forKey: key)
        }
    }
    
    func getCurrentDateKey() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
    func stopPractice(){
        stopMetronome()
    }
    
    @objc func playSound() {
        audioPlayer?.play()
        
        if isVibrationEnabled{
            //振動実行
            playShortVibration()
            //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        }
    }
    
    
    func displayTextForSeconds(_ text: String, duration: TimeInterval) {
        messageLabel.text = text
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.messageLabel.text = ""
        }
    }
    
    func updateProgressView(){
        guard let durationText = durationTextField.text, let totalDuration = Float(durationText) else {
            return
        }
        
        // 残り時間に基づいて進捗を計算
        let remainingTime = Float(currentTime)
        let progress = remainingTime / totalDuration

        // 進捗の更新
        progressView.setProgress(progress, animated: true)
    }
    
    func resetProgressView() {
        // プログレスバーをすぐにフルに戻す
        progressView.setProgress(1.0, animated: false)
    }
    
    func updateMessageLabel(){
        displayTextForSeconds("tempo is up!", duration: 3)
    }
    
    var i = 1
    
    func startMetronomeWithTimer() {
        i+=1
        durationTimer?.invalidate()
        metronomeLabel.text = String(format: "%.0f", currentBpm)
        durationTimer = Timer.scheduledTimer(timeInterval: 60.0 / currentBpm, target: self, selector: #selector(playSound), userInfo: nil, repeats: true)
        
        if currentBpm > 199 {
            currentBpm = 200
            stopMetronome()
            messageLabel.text = "bpm200達成！お疲れ様！"
            
            
        }
        
    }
    
    // テキストフィールドの選択が変更されるたびに呼び出す
    @IBAction func textFieldDidChangeSelection(_ textField: UITextField) {
        metronomeLabel.text = bpmTextField.text
        updateButtonEnabledState()
        validateInputFields()
    }
    
    func updateButtonEnabledState() {
        updateChangeButton()
        updateBpmButton()
        updateDurationButton()
        
        guard let changeText = changeTextField.text, let change = Int(changeText),
              let bpmText = bpmTextField.text, let bpm = Int(bpmText),
              let durationText = durationTextField.text, let duration = Int(durationText) else{
            print("Invalid Bpm or Change or Duration")
            return
        }
        
        togglePracticeButton.isEnabled = (59 < bpm && bpm < 181) && (duration > 29 && duration < 301) && (change > 0 && change < 21)
        
        updateButton()
    }
    
    func updateChangeButton(){
        guard let changeText = changeTextField.text, let change = Int(changeText) else{
            print("Invalid Change")
            return
        }
        plusChangeButton.isEnabled = change < 20
        minusChangeButton.isEnabled = change > 1
    }
    
    func updateBpmButton(){
        guard let bpmText = bpmTextField.text, let bpm = Int(bpmText) else{
            print("Invalid Bpm")
            return
        }
        plusBpmButton.isEnabled = bpm < 180
        minusBpmButton.isEnabled = bpm > 60
    }
    
    func updateDurationButton(){
        guard let durationText = durationTextField.text, let duration = Int(durationText) else{
            print("Invalid Duration")
            return
        }
        plusDurationButton.isEnabled = duration < 300
        minusDurationButton.isEnabled = duration > 30
    }
    
    
    
    func updateButton(){
        if togglePracticeButton.isEnabled{
            togglePracticeButton.titleLabel?.font = UIFont(name: "ZenMaruGothic-Medium", size: 25)
            togglePracticeButton.setTitle(togglePracticeButton.currentTitle, for: .normal)
            let buttonColor = UIColor(red: 229/255, green: 145/255, blue: 239/255, alpha: 1)
            let buttonTitle = isMetronomeActive ? "Stop" : "Start"
            togglePracticeButton.setTitle(buttonTitle, for: .normal)
            togglePracticeButton.backgroundColor = buttonColor
            togglePracticeButton.layer.cornerRadius = 40
        }
        else{
            togglePracticeButton.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 214/255, alpha: 1)
        }
    }
    
    @IBAction func togglePractice(_ sender: UIButton){
        togglePracticeButton.isEnabled = true;
        if(isMetronomeActive){
            stopPractice()
        }else{
            startPractice()
        }
        updateButton()
    }
    
    @IBAction func plusBpm(_ sender: UIButton){
        let startBpmText = bpmTextField.text ?? ""
        var startBpm = Int(startBpmText) ?? 0
        
        startBpm += 1
        bpmTextField.text = String(startBpm)
        metronomeLabel.text = String(startBpm)
        
        validateInputFields()
        updateButton()
        updateButtonEnabledState()
    }
    
    @IBAction func minusBpm(_ sender: UIButton){
        var startBpmText = bpmTextField.text ?? ""
        var startBpm = Int(startBpmText) ?? 0
        
        startBpm -= 1
        bpmTextField.text = String(startBpm)
        metronomeLabel.text = String(startBpm)
        
        validateInputFields()
        updateButton()
        updateButtonEnabledState()
    }
    
    @IBAction func plusDuration(_ sender: UIButton){
        let durationText = durationTextField.text ?? ""
        var duration = Int(durationText) ?? 0
        
        duration += 1
        durationTextField.text = String(duration)
        validateInputFields()
        updateButton()
        updateButtonEnabledState()
    }
    
    @IBAction func minusDuration(_ sender: UIButton){
        let durationText = durationTextField.text ?? ""
        var duration = Int(durationText) ?? 0
        
        duration -= 1
        durationTextField.text = String(duration)
        validateInputFields()
        updateButton()
        updateButtonEnabledState()
    }
    
    @IBAction func plusChange(_ sender: UIButton){
        let changeText = changeTextField.text ?? ""
        var change = Int(changeText) ?? 0
        
        change += 1
        changeTextField.text = String(change)
        validateInputFields()
        updateButton()
        updateButtonEnabledState()
    }
    
    @IBAction func minusChange(_ sender: UIButton){
        let changeText = changeTextField.text ?? ""
        var change = Int(changeText) ?? 0
        
        change -= 1
        changeTextField.text = String(change)
        validateInputFields()
        updateButton()
        updateButtonEnabledState()
    }
    
    
    func startPractice() {
        minusBpmButton.isEnabled = false
        plusBpmButton.isEnabled = false
        minusChangeButton.isEnabled = false
        plusChangeButton.isEnabled = false
        minusDurationButton.isEnabled = false
        plusDurationButton.isEnabled = false
        
        bpmTextField.isEnabled = false
        durationTextField.isEnabled = false
        changeTextField.isEnabled = false
        
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
        self.startMetronomeWithTimer()
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {return}

            self.currentTime -= 1.0
            self.updateProgressView()
            
            if self.currentTime <= 0{
                self.resetProgressView()
                self.currentTime = durationInSeconds
                
                self.currentBpm += bpmIncrement
                
                if self.currentBpm > 199 {
                    currentBpm = 200
                    self.stopMetronome()
                    metronomeLabel.text = "200"
                    self.messageLabel.text = "bpm200達成！お疲れ様！"
                    timer.invalidate() // タイマーを停止する
                }else{
                    
                    self.startMetronomeWithTimer()
                    self.updateMessageLabel()
                }
                
            }
        }
    }
    
    func setCustomFont() {
        let fontName = "ZenMaruGothic-Medium"
        let fontName2 = "ZenMaruGothic-Light"
        
        // ラベル
        metronomeLabel.font = UIFont(name: fontName, size: metronomeLabel.font.pointSize)
        messageLabel.font = UIFont(name: fontName, size: messageLabel.font.pointSize)
        bpmTextLabel.font = UIFont(name: fontName, size: messageLabel.font.pointSize)
        secondTextLabel.font = UIFont(name: fontName, size: messageLabel.font.pointSize)
        changeTextLabel.font = UIFont(name: fontName, size: messageLabel.font.pointSize)
        vibeTextLabel.font = UIFont(name: fontName, size: vibeTextLabel.font.pointSize)
        tempoUpLabel.font = UIFont(name: fontName, size: tempoUpLabel.font.pointSize)
        errorBpmMessageLabel.font = UIFont(name: fontName2, size: 10)
        errorDurationMessageLabel.font = UIFont(name: fontName2, size: 10)
        errorChangeMessageLabel.font = UIFont(name: fontName2, size: 10)
        
        // テキストフィールド
        bpmTextField.font = UIFont(name: fontName, size: bpmTextField.font?.pointSize ?? 17)
        durationTextField.font = UIFont(name: fontName, size: durationTextField.font?.pointSize ?? 17)
        changeTextField.font = UIFont(name: fontName, size: changeTextField.font?.pointSize ?? 17)
    }
    
    func validateInputFields() {
        var errorMessages: [String?] = [nil, nil, nil]
        
        if let bpmText = bpmTextField.text, let bpm = Int(bpmText), (bpm < 60 || bpm > 180) {
            errorMessages[0] = "60から180の間で入力してください"
        }
        if let durationText = durationTextField.text, let duration = Int(durationText), (duration < 30 || duration > 300) {
            errorMessages[1] = "30から300の間で入力してください"
        }
        
        if let changeText = changeTextField.text, let change = Int(changeText), (change < 1 || change > 20) {
            errorMessages[2] = "1から20の間で入力してください"
        }
        
        if errorMessages.contains(where: { $0 != nil }) {
            errorBpmMessageLabel.text = errorMessages[0]
            errorDurationMessageLabel.text = errorMessages[1]
            errorChangeMessageLabel.text = errorMessages[2]
            togglePracticeButton.isEnabled = false
        } else {
                errorBpmMessageLabel.text = ""
                errorDurationMessageLabel.text = ""
                errorChangeMessageLabel.text = ""
            if (bpmTextField.text != "" && durationTextField.text != "" && changeTextField.text != ""){
                togglePracticeButton.isEnabled = true
            }
        }
        
    }
    
    func playShortVibration() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            print("振動失敗")
            return }
        
        var events = [CHHapticEvent]()
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.2)
        events.append(event)
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play pattern: \(error)")
        }
    }
    
    func setupLayoutConstraints() {
        metronomeLabel.translatesAutoresizingMaskIntoConstraints = false
        bpmTextField.translatesAutoresizingMaskIntoConstraints = false
        durationTextField.translatesAutoresizingMaskIntoConstraints = false
        changeTextField.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        togglePracticeButton.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        errorBpmMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorDurationMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        errorChangeMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        plusBpmButton.translatesAutoresizingMaskIntoConstraints = false
        minusBpmButton.translatesAutoresizingMaskIntoConstraints = false
        plusDurationButton.translatesAutoresizingMaskIntoConstraints = false
        minusDurationButton.translatesAutoresizingMaskIntoConstraints = false
        plusChangeButton.translatesAutoresizingMaskIntoConstraints = false
        minusChangeButton.translatesAutoresizingMaskIntoConstraints = false
        bpmTextLabel.translatesAutoresizingMaskIntoConstraints = false
        secondTextLabel.translatesAutoresizingMaskIntoConstraints = false
        changeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        vibeTextLabel.translatesAutoresizingMaskIntoConstraints = false
        tempoUpLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
                    metronomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
                    metronomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    
                    bpmTextField.topAnchor.constraint(equalTo: metronomeLabel.bottomAnchor, constant: 20),
                    bpmTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    bpmTextField.widthAnchor.constraint(equalToConstant: 100),
                    
                    durationTextField.topAnchor.constraint(equalTo: bpmTextField.bottomAnchor, constant: 20),
                    durationTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    durationTextField.widthAnchor.constraint(equalToConstant: 100),
                    
                    changeTextField.topAnchor.constraint(equalTo: durationTextField.bottomAnchor, constant: 20),
                    changeTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    changeTextField.widthAnchor.constraint(equalToConstant: 100),
                    
                    messageLabel.topAnchor.constraint(equalTo: changeTextField.bottomAnchor, constant: 20),
                    messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    
                    progressView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
                    progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                    progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                    
                    togglePracticeButton.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
                    togglePracticeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    togglePracticeButton.widthAnchor.constraint(equalToConstant: 100),
                    togglePracticeButton.heightAnchor.constraint(equalToConstant: 50),
                                
                    errorBpmMessageLabel.topAnchor.constraint(equalTo: bpmTextField.bottomAnchor, constant: 5),
                    errorBpmMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                
                    errorDurationMessageLabel.topAnchor.constraint(equalTo: durationTextField.bottomAnchor, constant: 5),
                    errorDurationMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                
                    errorChangeMessageLabel.topAnchor.constraint(equalTo: changeTextField.bottomAnchor, constant: 5),
                    errorChangeMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                
                    plusBpmButton.topAnchor.constraint(equalTo: bpmTextField.topAnchor),
                    plusBpmButton.leadingAnchor.constraint(equalTo: bpmTextField.trailingAnchor, constant: 10),
                                
                    minusBpmButton.topAnchor.constraint(equalTo: bpmTextField.topAnchor),
                    minusBpmButton.trailingAnchor.constraint(equalTo: bpmTextField.leadingAnchor, constant: -10),
                                
                    plusDurationButton.topAnchor.constraint(equalTo: durationTextField.topAnchor),
                    plusDurationButton.leadingAnchor.constraint(equalTo: durationTextField.trailingAnchor, constant: 10),
                    
                    minusDurationButton.topAnchor.constraint(equalTo: durationTextField.topAnchor),
                    minusDurationButton.trailingAnchor.constraint(equalTo: durationTextField.leadingAnchor, constant: -10),
                                
                    plusChangeButton.topAnchor.constraint(equalTo: changeTextField.topAnchor),
                    plusChangeButton.leadingAnchor.constraint(equalTo: changeTextField.trailingAnchor, constant: 10),
                                
                    minusChangeButton.topAnchor.constraint(equalTo: changeTextField.topAnchor),
                    minusChangeButton.trailingAnchor.constraint(equalTo: changeTextField.leadingAnchor, constant: -10),
                                
                    bpmTextLabel.topAnchor.constraint(equalTo: plusBpmButton.bottomAnchor, constant: 20),
                    bpmTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                
                    secondTextLabel.topAnchor.constraint(equalTo: bpmTextLabel.bottomAnchor, constant: 20),
                    secondTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                        
                    changeTextLabel.topAnchor.constraint(equalTo: secondTextLabel.bottomAnchor, constant: 20),
                    changeTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                
                    vibeTextLabel.topAnchor.constraint(equalTo: changeTextLabel.bottomAnchor, constant: 20),
                    vibeTextLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                
                    tempoUpLabel.topAnchor.constraint(equalTo: vibeTextLabel.bottomAnchor, constant: 20),
                    tempoUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}
