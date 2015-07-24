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

    enum SoundName: String {
        case Bistro = "bistro"
        case Night = "night"
        case Rain = "rain"
    }

    let colorMap: [SoundName:UIColor] = [
        // # 1D0052
        .Night: UIColor(red: 0x1d/255.0, green: 0.0, blue: 0x52/255.0, alpha: 1),
        // #0065A0
        .Rain: UIColor(red: 0, green: 0x65/255.0, blue: 0xA0/255.0, alpha: 1),
        // #750000
        .Bistro: UIColor(red: 0x75/255.0, green: 0.0, blue: 0.0, alpha: 1),
    ]


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

    var soundSwitchingAnimationDone: (() -> ())?

    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if let done = soundSwitchingAnimationDone {
            defer { soundSwitchingAnimationDone = nil }
            done()
        }
    }


    func animateSoundSwitching(center: CGPoint, oldSoundName: SoundName?, newSoundName: SoundName) {
        print("tap center: \(center)")
        let coverView = UIView(frame: self.view.frame)
        coverView.backgroundColor = colorMap[newSoundName]
        self.view.sendSubviewToBack(currentSoundImageView)
        self.view.insertSubview(coverView, aboveSubview: currentSoundImageView)

        let iconImageView = UIImageView(frame: currentSoundImageView.frame)
        iconImageView.image = UIImage(named: newSoundName.rawValue)
        coverView.addSubview(iconImageView)

        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.blackColor().CGColor
        maskLayer.position = center
        maskLayer.bounds = coverView.frame

        coverView.layer.mask = maskLayer

        func d(a: CGPoint, _ b: CGPoint) -> Float {
            let dx: Float = Float(a.x - b.x)
            let dy: Float = Float(a.y - b.y)
            return sqrtf(dx*dx + dy*dy)
        }


        let topLeft = CGPointZero
        let topRight = CGPointMake(self.view.frame.width, 0)
        // find the longer distance to top-left or top-right corner, use that as final radius.
        // 1.3 is a fudge factor to make the circle exceed the frame.
        let finalRadius = max(d(topLeft,center),d(topRight,center)) * 1.3

        let corner = CABasicAnimation(keyPath: "cornerRadius")
        corner.fromValue = 0
        corner.toValue = finalRadius
        corner.duration = 0.5
        corner.delegate = self
        maskLayer.addAnimation(corner, forKey: nil)

        let blowup = CABasicAnimation(keyPath: "bounds")
        blowup.fromValue = NSValue(CGRect: CGRectZero)
        let bound = CGRectMake(CGFloat(0.0), CGFloat(0.0), CGFloat(finalRadius*2), CGFloat(finalRadius*2)) // wtf...
        maskLayer.bounds = bound
        blowup.toValue = NSValue(CGRect: bound)
        blowup.duration = 0.5
        blowup.delegate = self
        maskLayer.addAnimation(blowup, forKey: "boom")

        soundSwitchingAnimationDone = {
            self.currentSoundImageView.image = iconImageView.image
            self.view.backgroundColor = coverView.backgroundColor
            coverView.removeFromSuperview()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentSoundName = .Rain
        playing = true
        currentSoundImageView.image = UIImage(named: currentSoundName.rawValue)

        // #0065A0
        self.view.backgroundColor = UIColor(red: 0, green: 0x65/255.0, blue: 0xA0/255.0, alpha: 1)
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func soundButtonTapped(button: UIButton) {
        let oldSoundName = currentSoundName
        switch button {
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

        animateSoundSwitching(button.convertPoint(CGPointMake(button.frame.height/2, button.frame.width/2), toView: self.view),
                              oldSoundName: oldSoundName, newSoundName: currentSoundName)
    }

    @IBAction func togglePlaying(sender: AnyObject) {
        self.playing = !playing
    }

}

