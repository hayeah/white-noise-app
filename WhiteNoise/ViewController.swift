//
//  ViewController.swift
//  WhiteNoise
//
//  Created by Howard Yeh on 2015-07-23.
//  Copyright © 2015 Howard Yeh. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var currentSoundImage: UIImageView!
    @IBOutlet weak var bistroButton: UIButton!
    @IBOutlet weak var nightButton: UIButton!
    @IBOutlet weak var rainButton: UIButton!

    var soundPlayer: AVAudioPlayer!

    var currentSoundName: SoundName! {
        didSet {
            if(oldValue == currentSoundName) {
                return
            }

            let name = currentSoundName.rawValue

            print("sound: \(currentSoundName.rawValue)")
            currentSoundImage.image = UIImage(named: name)

            currentSoundURL = NSBundle.mainBundle().URLForResource(name, withExtension: "m4a")
        }
    }

    var currentSoundURL: NSURL? {
        didSet {
            guard currentSoundURL != nil else {
                print("no sound file found: \(currentSoundName.rawValue)")
                soundPlayer = nil
                return
            }
            do {
                try soundPlayer = AVAudioPlayer(contentsOfURL: currentSoundURL!)
            } catch _ {
                print("cannot play")
                return
            }

            soundPlayer.numberOfLoops = -1
            soundPlayer.play()

        }
    }

    enum SoundName: String {
        case Bistro = "bistro"
        case Night = "night"
        case Rain = "rain"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentSoundName = .Rain
//        currentSoundName = .Rain
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func soundButtonTapped(sender: UIButton) {
        switch sender {
        case bistroButton:
            currentSoundName = .Bistro
        case nightButton:
            currentSoundName = .Night
        case rainButton:
            currentSoundName = .Rain
        default:
            currentSoundName = .Rain
            // nothing
        }
    }


}

