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

    @IBOutlet weak var currentSoundImageView: UIImageView!
    @IBOutlet weak var bistroButton: UIButton!
    @IBOutlet weak var nightButton: UIButton!
    @IBOutlet weak var rainButton: UIButton!
    @IBOutlet weak var toggleSoundButton: UIButton!

    let soundStoppedImage = UIImage(named: "sound-stopped")!
    let soundPlayingImage = UIImage(named: "sound-playing")!

    var playing: Bool! {
        didSet {
            if playing == true {
                soundPlayer?.play()
                toggleSoundButton.setImage(soundPlayingImage, forState: UIControlState.Normal)
            } else {
                soundPlayer?.stop()
                toggleSoundButton.setImage(soundStoppedImage, forState: UIControlState.Normal)
            }
        }
    }

    var currentSoundIcon: UIImage? {
        get {
            return UIImage(named: currentSoundName.rawValue)
        }
    }

    var soundPlayer: AVAudioPlayer?

    var currentSoundName: SoundName! {
        didSet {
            defer { playing = true }

            if(oldValue == currentSoundName) {
                return
            }

            let name = currentSoundName.rawValue

            print("sound: \(currentSoundName.rawValue)")

            //
            animateSoundSwitching(oldValue, newSoundName: currentSoundName)


            let currentSoundURL = NSBundle.mainBundle().URLForResource(name, withExtension: "m4a")

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

            soundPlayer?.numberOfLoops = -1
        }
    }

    func animateSoundSwitching(oldSoundName: SoundName?, newSoundName: SoundName) {
        currentSoundImageView.image = UIImage(named: newSoundName.rawValue)
    }

    enum SoundName: String {
        case Bistro = "bistro"
        case Night = "night"
        case Rain = "rain"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentSoundName = .Rain
        playing = true

        // #0065A0
        self.view.backgroundColor = UIColor(red: 0, green: 0x65/255.0, blue: 0xA0/255.0, alpha: 1)
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

    @IBAction func togglePlaying(sender: AnyObject) {
        self.playing = !playing
    }

}

