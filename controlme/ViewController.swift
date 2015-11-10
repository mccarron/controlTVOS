//
//  ViewController.swift
//  controlme
//
//  Created by Patrick McCarron on 11/9/15.
//  Copyright © 2015 Patrick McCarron. All rights reserved.
//

import UIKit
import SpriteKit
import GameController

class ViewController: GCEventViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        /*
        When transitioning to the `HomeEndScene` set
        `controllerUserInteractionEnabled` to `true` to allow the
        user to exit the app with the menu button.
        
        Otherwise, setting `controllerUserInteractionEnabled` to false
        will not direct game controller events through the UIEvent & UIResponder chain.
        
        @see GCEventViewController
        */
        controllerUserInteractionEnabled = false
        view.backgroundColor = UIColor.redColor()
        becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserverForName(GCControllerDidConnectNotification, object: nil, queue: nil) { notification in
            self.processControllers()
        }
    }
    
    func processControllers() {
        let controllers = GCController.controllers()
        print("\n\nfound \(controllers.count) controllers:")
        
        var count = 0
        for controller in controllers {
            controller.playerIndex = GCControllerPlayerIndex(rawValue: count)!
            controller.controllerPausedHandler = { controller in
                self.controllerUserInteractionEnabled = !self.controllerUserInteractionEnabled
                if (self.controllerUserInteractionEnabled) {
                    print("Switching to UIKit Controls")
                } else {
                    print("Switching to Gamepad Controls")
                }
            }
            
            print("\(count+1). ", terminator:"")
            if controller.extendedGamepad != nil {
                
                controller.extendedGamepad?.valueChangedHandler = { gamepad, element in
                    if let button = element as? GCControllerButtonInput {
                        print("Extended Gamepad: button \(button) pressed")
                    } else if let axis = element as? GCControllerAxisInput {
                        print("Extended Gamepad: axis changed: \(axis)")
                    } else if let dpad = element as? GCControllerDirectionPad {
                        print("Extended Gamepad: dpad changed: \(dpad)")
                    }
                }
                
                controller.extendedGamepad?.buttonA.valueChangedHandler = { button, value, pressed in
                    if pressed && value == 1.0 {
                        print("Extended Gamepad: A pressed \(value)")
                        var count = controller.playerIndex.rawValue + 1
                        if (count >= 4) { count = 0 }
                        controller.playerIndex = GCControllerPlayerIndex(rawValue:count)!
                    }
                }
                
                print("Extended Gamepad ", terminator:"")
            } else if controller.gamepad != nil {
                print("Standard Gamepad ", terminator:"")
                
                controller.gamepad?.valueChangedHandler = { gamepad, element in
                    if gamepad.buttonY.pressed {
                        print("Standard Gamepad: Y")
                    }
                }
                
            } else if controller.microGamepad != nil {
                
                controller.microGamepad?.allowsRotation = true
                controller.microGamepad?.reportsAbsoluteDpadValues = true
                
                controller.microGamepad?.valueChangedHandler = { gamepad, element in
                    if let button = element as? GCControllerButtonInput {
                        print("REMOTE: button \(button) pressed")
                    } else if let dpad = element as? GCControllerDirectionPad {
                        print("REMOTE: dpad changed: \(dpad)")
                    }
                }

                print("Micro Gamepad ", terminator:"")
            }
            if controller.motion != nil {
                print("& Motion Gamepad ", terminator:"")
                
//                controller.motion?.valueChangedHandler = { motion in
//                    print("MOTION: Gravity: \(motion.gravity) Acceleration: \(motion.userAcceleration) attitude: \(motion.attitude) rotationRate: \(motion.rotationRate)")
//                }
            }
            print("")
            count++
        }
    }

    func updateBackgroundColor() {
        if (self.controllerUserInteractionEnabled) {
            self.view.backgroundColor = UIColor.greenColor()
        } else {
            self.view.backgroundColor = UIColor.redColor()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func pressesBegan(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        
        self.view.backgroundColor = UIColor.blueColor()
        
        for item in presses {
            if item.type == .Select {
                  print("Select pressed")
            }
        }
    }
    
    override func pressesEnded(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        updateBackgroundColor()
    }
    
    override func pressesChanged(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        // ignored
    }
    
    override func pressesCancelled(presses: Set<UIPress>, withEvent event: UIPressesEvent?) {
        updateBackgroundColor()
    }
    

}

