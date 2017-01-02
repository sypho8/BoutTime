//
//  ViewController.swift
//  BoutTime
//
//  Created by Dan on 12/25/16.
//  Copyright © 2016 sypho. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    
    let game: Game
    
    @IBOutlet weak var firstEventLabel: UILabel!
    @IBOutlet weak var secondEventLabel: UILabel!
    @IBOutlet weak var thirdEventLabel: UILabel!
    @IBOutlet weak var fourthEventLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var infoLable: UILabel!
    @IBOutlet weak var nextRoundButton: UIButton!
    
    var timer: Timer?
    var countdown = 0
    
    required init?(coder aDecoder: NSCoder) {
        do {
            let dictionary = try PlistConverter.dictionary(fromFile: "Events", ofType: "plist")
            let eventsArray = DictionaryConverter.eventsArray(fromDictionary: dictionary)
            self.game = Game(eventsArray: eventsArray)
        } catch let error {
            fatalError("\(error)")
        }
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(startNextRound), name:NSNotification.Name(rawValue: "playAgain"), object: nil)
        startRound()
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake && countdown > 0 {
            displayAnswer()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let childViewController = segue.destination as? PlayAgainController {
            childViewController.game = game
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    enum Button: String {
        case firstButton
        case secondButtonUp
        case secondButtonDown
        case thirdButtonUp
        case thirdButtonDown
        case fourthButton
    }
    
    func displayAnswer() {
        timer?.invalidate()
        do {
            let correctness = try game.checkAnswer()
            var image: UIImage?
            switch correctness {
            case true:
                image = UIImage(named: "next_round_success.png")
                game.sounds.playCorrectSound()
            case false:
                image = UIImage(named: "next_round_fail.png")
                game.sounds.playIncorrectSound()
            }
            infoLable.text = "Tap events to learn more"
            nextRoundButton.setImage(image, for: .normal)
            nextRoundButton.isHidden = false
        } catch let error{
            // FIXME: Error handling
            print(error)
        }
    }
    
    @IBAction func nextRound() {
        if game.isOver() {
            performSegue(withIdentifier: "showScore", sender: game)
        } else {
            startNextRound()
        }
    }
    
    func startNextRound() {
        countdownLabel.text = "1:00"
        nextRoundButton.isHidden = true
        infoLable.text = "Shake to complete"
        startRound()
    }

    func startRound() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        countdown = game.timerCountdown
        do {
            let events: [Event] = try game.startRound()
            firstEventLabel.text = events[0].description
            secondEventLabel.text = events[1].description
            thirdEventLabel.text = events[2].description
            fourthEventLabel.text = events[3].description
        } catch {
            // FIXME: Error handling
        }
    }
    
    func updateCountdown() {
        countdown -= 1
        if countdown == 0 {
            countdownLabel.text = "0:00"
            displayAnswer()
        } else if countdown < 10 {
            countdownLabel.text = "0:0\(countdown)"
        } else {
            countdownLabel.text = "0:\(countdown)"
        }
    }
    
    func repopulateLablesForButton(_ button: Button) {
        var tempText: String?
        switch button {
        case .firstButton, .secondButtonUp:
            tempText = firstEventLabel.text
            firstEventLabel.text = secondEventLabel.text
            secondEventLabel.text = tempText
        case .secondButtonDown, .thirdButtonUp:
            tempText = secondEventLabel.text
            secondEventLabel.text = thirdEventLabel.text
            thirdEventLabel.text = tempText
        case .thirdButtonDown, .fourthButton:
            tempText = thirdEventLabel.text
            thirdEventLabel.text = fourthEventLabel.text
            fourthEventLabel.text = tempText
        }
    }
    
    @IBAction func changeOrder(_ sender: UIButton) {
        if let title = sender.titleLabel?.text, let button = Button(rawValue: title) {
            do {
                var answerSwitch: AnswerSwitch
                switch button {
                case .firstButton, .secondButtonUp:
                    answerSwitch = .firstSecond
                case .secondButtonDown, .thirdButtonUp:
                    answerSwitch = .secondThird
                case .thirdButtonDown, .fourthButton:
                    answerSwitch = .thirdFourth
                }
                try game.switchAnswer(answerSwitch)
                repopulateLablesForButton(button)
            } catch {
                // FIXME: Error handling
            }
        } else {
            // FIXME: Error handling
        }
    }

}


