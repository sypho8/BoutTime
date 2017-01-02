//
//  PlayAgainViewController.swift
//  BoutTime
//
//  Created by Dan on 12/30/16.
//  Copyright © 2016 sypho. All rights reserved.
//

import UIKit

class PlayAgainController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    var game: Game?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let game = game {
            scoreLabel.text = "\(game.totalScore)/\(game.roundsPerGame)"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func playAgain() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "playAgain"), object: nil)
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
