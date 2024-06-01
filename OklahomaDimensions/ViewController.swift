//
//  ViewController.swift
//  OklahomaDimensions
//
//  Created by Spencer Paschal on 7/5/15.
//  Copyright (c) 2015 Spencer Paschal. All rights reserved.
//

/*

A-B:   318  HORIZ
B-C:  244   VERT
C-I    590   HORIZ
F-D   430   VERT
G-F   888   HORIZ
H-F   572   HORIZ
A-G   65    VERT
C-H   312  VERT

*/

import UIKit
import WatchConnectivity

class ViewController: UIViewController, UITextFieldDelegate, WCSessionDelegate {
	
	var watchSession : WCSession?
    
    @IBOutlet weak var AtoG: UITextField!
    @IBOutlet weak var AtoB: UITextField!
    @IBOutlet weak var BtoC: UITextField!
    @IBOutlet weak var CtoI: UITextField!
    @IBOutlet weak var FtoD: UITextField!
    @IBOutlet weak var GtoF: UITextField!
    @IBOutlet weak var HtoF: UITextField!
    @IBOutlet weak var CtoH: UITextField!
    @IBOutlet weak var DtoE: UITextField!
    @IBOutlet weak var FtoE: UITextField!
    @IBOutlet weak var FtoJ: UITextField!
    @IBOutlet weak var JtoE: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var updateButton: UIButton!
    
    var lengths = Lengths()
    var defaultColor:UIColor = UIColor.clear
    var activeEditing:Bool = false
    
    var unitSelector = 50
    
    var conversionText = ""
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func didTapView(){
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        errorLabel.alpha = 0.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       // println(text)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(ViewController.didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
        //updateButton.setTitleColor(UIColor.blackColor(), forState: nil)
        defaultColor = updateButton.currentTitleColor
        errorLabel.text = ""
        
        self.AtoB.delegate = self
        self.AtoG.delegate = self
        self.BtoC.delegate = self
        self.CtoH.delegate = self
        self.CtoI.delegate = self
        self.FtoD.delegate = self
        self.GtoF.delegate = self
        self.HtoF.delegate = self
        self.DtoE.delegate = self
        self.FtoE.delegate = self
        self.FtoJ.delegate = self
        self.JtoE.delegate = self
        
        infoLabel.text = "TESTING"
        infoLabel.alpha = 0.0
		
		/*
		* If this device can support a WatchConnectivity session,
		* obtain a session and activate.
		*
		* It isn't usually recommended to put this in viewDidLoad,
		* we're only doing it here to keep the app simple
		*
		* Note: Even though we won't be receiving messages in the View Controller,
		* we still need to supply a delegate to activate the session
		*/
		if(WCSession.isSupported()){
			print("iOS Watch Connect is supported")
			watchSession = WCSession.default()
			watchSession!.delegate = self
			watchSession!.activate()
		
		}

    }
	
	func session(_ session: WCSession,
	             activationDidCompleteWith activationState: WCSessionActivationState,
	             error: Error?) {
		print("iOS session activation complete: state =  \(activationState)")
	}
	
	public func activate(){
		
		if WCSession.isSupported() {    //  it is supported
			watchSession = WCSession.default()
			watchSession?.delegate = self
			watchSession?.activate()
			print("watch activating WCSession")
		} else {
			
			print("watch does not support WCSession")
		}
		
		if(!(watchSession?.isReachable)!){
			print("not reachable")
			return
		}else{
			print("watch is reachable")
			
		}
	}
	
	func sessionDidBecomeInactive(_ session: WCSession) {
		
		print("iOS Session Did Become Inactive")
	}
	
	func sessionDidDeactivate(_ session: WCSession) {
		// Begin the activation process for the new Apple Watch.
		print("iOS Session Deactivated")
		WCSession.default().activate()
	}
	
    @IBAction func cancelToViewController(_ segue:UIStoryboardSegue) {
        self.infoLabel.text = "No Conversion"
        UIView.animate(withDuration: 0.7, delay: 2.0, options: .curveEaseOut, animations: {
            self.infoLabel.alpha = 1.0
            }, completion: { finished in
                
                UIView.animate(withDuration: 0.8, delay: 2.0, options: .curveEaseOut, animations: {
                    self.infoLabel.alpha = 0.0
                    }, completion: nil)
        })
		print("canceled to view")
    }
    
    @IBAction func returnAndUpdateUnits (_ segue:UIStoryboardSegue) {
        let sourceView = segue.source as! DetailViewController
        let selector = sourceView.selectedConversion
        
        if unitSelector == selector {
            print("they match")
        } else {
            print("don't match")
        }
        
        //infoLabel.alpha = 0
        var newInfo:String = "No Conversion"
        
        
        if unitSelector == 1 {
            newInfo = "Converted to Centimeters"
            self.infoLabel.text = newInfo
            conversionText = newInfo
            updateUnits(2.54, converting: true)
        } else if unitSelector == 2{
            newInfo = "Converted to Inches"
            self.infoLabel.text = newInfo
            conversionText = newInfo
            updateUnits(0.393701, converting: true)

        } else {
           
            self.infoLabel.text = newInfo
            conversionText = newInfo
        
            UIView.animate(withDuration: 0.7, delay: 2.0, options: .curveEaseOut, animations: {
                self.infoLabel.alpha = 1.0
                }, completion: { finished in
            
                UIView.animate(withDuration: 0.8, delay: 2.0, options: .curveEaseOut, animations: {
                    self.infoLabel.alpha = 0.0
                    }, completion: nil)
             })
        }
    }

    func updateUnits (_ multiplier: Float, converting:Bool) {
        if lengths.updateSide(Sides.gf, length: lengths.gf * multiplier) {
                updateAll()
            if false == converting {
                updateAllText()
            } else {
                clearError()
                updateTextOnly()
            }
        } else {
            self.infoLabel.text = ""
            displayError("Calculation error, restart app.")
        }
		
		print("Updated units")
		
		if let message : String = GtoF.text {
			do {
				try watchSession?.updateApplicationContext (
					["message" : message]
				)
			} catch let error as NSError {
				NSLog("Updating the context failed: " + error.localizedDescription)
			}
		}
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if !newString.isEmpty {
            
            // Find out whether the new string is numeric by using an NSScanner.
            // The scanDecimal method is invoked with NULL as value to simply scan
            // past a decimal integer representation.
            let scanner: Scanner = Scanner(string:newString)
            let isNumeric = scanner.scanDecimal(nil) && scanner.isAtEnd
            
            return isNumeric
            
        } else {
            
            // To allow for an empty text field
            return true
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func displayError (_ msg:String) {
        errorLabel.text = msg
        
        UIView.animate(withDuration: 0.4, delay: 0.5, options: .curveEaseOut, animations: {
            self.errorLabel.alpha = 1
            }, completion: { finished in
                print("fade out")
                self.clearError()
        })

    }
    
    func clearError () {
        UIView.animate(withDuration: 0.3, delay: 3.0, options: .curveEaseOut, animations: {
            self.errorLabel.alpha = 0
            }, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("AAA   DID BEGIN EDIT")
        if activeEditing == true {
            textField.resignFirstResponder()
            textField.endEditing(true)
            activeEditing = false
            displayError("Error, multiple fields changed")

        } else {
            clearError()
            activeEditing = true
            print("BEGIN")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        for view in self.view.subviews {
            if let textField = view as? UITextField {
                textField.resignFirstResponder()
                
            }
        }
    }
    
    @IBAction func EditBegin() {
        
    }
	
    @IBAction func editAtoG(_ sender: AnyObject) {
        print("Edit A to G")
        clearColors()
        AtoG.textColor = UIColor.red
        if AtoG.text!.isEmpty {
             print("empty")
             displayError("Enter a number!")
        } else {
            let myVal:String = AtoG.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.ag, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
            
        }
        activeEditing = false
		print("edited A to G")
    }
    
    @IBAction func editAtoB(_ sender: AnyObject) {
        clearColors()
        AtoB.textColor = UIColor.red
        if AtoB.text!.isEmpty {
            print("empty")
            displayError("Enter a number!")
        } else {
            
            let myVal:String = AtoB.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.ab, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
    
    @IBAction func editBtoC(_ sender: AnyObject) {
        clearColors()
        BtoC.textColor = UIColor.red
        if BtoC.text!.isEmpty {
            print("empty")
            displayError("Enter a number!")
        } else {
            
            let myVal:String = BtoC.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.bc, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
    
    @IBAction func editCtoI(_ sender: AnyObject) {
        clearColors()
        CtoI.textColor = UIColor.red
        if CtoI.text!.isEmpty {
            print("empty")
            displayError("Enter a number!")
        } else {
            
            let myVal:String = CtoI.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.ci, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
    
    @IBAction func editFtoD(_ sender: AnyObject) {
        clearColors()
        FtoD.textColor = UIColor.red
        if FtoD.text!.isEmpty {
            print("empty")
            displayError("Enter a number!")
        } else {
            let myVal:String = FtoD.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.fd, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
	
	@IBAction func editGtoF(_ sender: AnyObject) {
		clearColors()
		GtoF.textColor = UIColor.red
		if GtoF.text!.isEmpty {
			print("empty G TO F")
			displayError("Enter a number!")
		} else {
			let myVal:String = GtoF.text!
			let value = (myVal as NSString).floatValue
			
			if lengths.updateSide(Sides.gf, length: value) {
				print("G TO FFFFF")
				updateAll()
				clearError()
			} else {
				displayError("Calculation error, restart app.")
				print("G TO FFF ERRORRR")
			}
		}
		activeEditing = false
		
		if let message : String = GtoF.text {
			do {
				try watchSession?.updateApplicationContext(
					["message" : message]
				)
			} catch let error as NSError {
				NSLog("Updating the context failed: " + error.localizedDescription)
			}
		}
	}

	
    @IBAction func editHtoF(_ sender: AnyObject) {
        clearColors()
        HtoF.textColor = UIColor.red
        if HtoF.text!.isEmpty {
            print("empty")
            displayError("Enter a number!")
        } else {
            let myVal:String = HtoF.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.hf, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
    
    @IBAction func editCtoH(_ sender: AnyObject) {
        clearColors()
        CtoH.textColor = UIColor.red
        if CtoH.text!.isEmpty {
            print("empty")
            displayError("Enter a number!")
        } else {
            let myVal:String = CtoH.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.ch, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
    
    @IBAction func editDtoE(_ sender: AnyObject) {
        clearColors()
        DtoE.textColor = UIColor.red
        if DtoE.text!.isEmpty {
            print("Error")
            displayError("Enter a number!")
        } else {
            let myVal:String = DtoE.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.de, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
    
    
    @IBAction func editFtoE(_ sender: AnyObject) {
        clearColors()
        FtoE.textColor = UIColor.red
        if FtoE.text!.isEmpty {
            print("Error")
            displayError("Enter a number!")
        } else {
            let myVal:String = FtoE.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.fe, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
    
    
    @IBAction func editFtoJ(_ sender: AnyObject) {
        clearColors()
        FtoJ.textColor = UIColor.red
        if FtoJ.text!.isEmpty {
            print("Error")
            displayError("Enter a number!")
        } else {
            let myVal:String = FtoJ.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.fj, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
    
    @IBAction func editJtoE(_ sender: AnyObject) {
        
        clearColors()
        JtoE.textColor = UIColor.red
        if JtoE.text!.isEmpty {
            print("Error")
            displayError("Enter a number!")
        } else {
            let myVal:String = JtoE.text!
            let value = (myVal as NSString).floatValue
            
            if lengths.updateSide(Sides.je, length: value) {
                updateAll()
                clearError()
            } else {
                displayError("Calculation error, restart app.")
            }
        }
        activeEditing = false
    }
    
    
    func updateAllText () {
        AtoG.text = "\(lengths.ag)"
        AtoB.text = "\(lengths.ab)"
        BtoC.text = "\(lengths.bc)"
        CtoI.text = "\(lengths.ci)"
        CtoH.text = "\(lengths.ch)"
        GtoF.text = "\(lengths.gf)"
        FtoD.text = "\(lengths.fd)"
        HtoF.text = "\(lengths.hf)"
        DtoE.text = "\(lengths.de)"
        FtoJ.text = "\(lengths.fj)"
        JtoE.text = "\(lengths.je)"
        FtoE.text = "\(lengths.fe)"
        clearColors()
        
        clearError()
        infoLabel.text = "Updated"
        UIView.animate(withDuration: 0.6, delay: 0.3, options: .curveEaseIn, animations: {
            self.infoLabel.alpha = 1.0
            }, completion: { finished in
                UIView.animate(withDuration: 0.9, delay: 1.2, options: .curveEaseOut, animations: {
                    self.infoLabel.alpha = 0.0
                    }, completion: nil)
        })
        
        if let message : String = GtoF.text {
            do {
                try watchSession?.updateApplicationContext(
                    ["message" : message]
                )
            } catch let error as NSError {
                NSLog("Updating the context failed: " + error.localizedDescription)
            }
        }
    }
    
    func updateTextOnly () {
        AtoG.text = "\(lengths.ag)"
        AtoB.text = "\(lengths.ab)"
        BtoC.text = "\(lengths.bc)"
        CtoI.text = "\(lengths.ci)"
        CtoH.text = "\(lengths.ch)"
        GtoF.text = "\(lengths.gf)"
        FtoD.text = "\(lengths.fd)"
        HtoF.text = "\(lengths.hf)"
        DtoE.text = "\(lengths.de)"
        FtoJ.text = "\(lengths.fj)"
        JtoE.text = "\(lengths.je)"
        FtoE.text = "\(lengths.fe)"
        clearColors()
        
   //     clearError()
        
        clearError()
        self.infoLabel.text = conversionText
        
        UIView.animate(withDuration: 0.6, delay: 0.3, options: .curveEaseIn, animations: {
            self.infoLabel.alpha = 1.0
        }, completion: { finished in
            UIView.animate(withDuration: 0.9, delay: 1.2, options: .curveEaseOut, animations: {
                self.infoLabel.alpha = 0.0
            }, completion: nil)
        })

        if let message : String = GtoF.text {
            do {
                try watchSession?.updateApplicationContext(
                    ["message" : message]
                )
            } catch let error as NSError {
                NSLog("Updating the context failed: " + error.localizedDescription)
            }
        }
    }
    
    func clearColors () {
        AtoG.textColor = UIColor.black
        AtoB.textColor = UIColor.black
        BtoC.textColor = UIColor.black
        
        CtoI.textColor = UIColor.black
        FtoD.textColor = UIColor.black
        GtoF.textColor = UIColor.black
        
        HtoF.textColor = UIColor.black
        DtoE.textColor = UIColor.black
        CtoH.textColor = UIColor.black
        
        FtoE.textColor = UIColor.black
        FtoJ.textColor = UIColor.black
        JtoE.textColor = UIColor.black
        
        clearError()
    }
    
    func needsUpdate () {
        updateButton.setTitleColor(defaultColor, for: UIControlState())
    }
    
    func updated () {
        updateButton.setTitleColor(UIColor.gray, for: UIControlState())
    }
    
    func updateAll () {
        needsUpdate()
    }
    
    @IBAction func update(_ sender: AnyObject) {
        updateAllText()
        updated()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "backToMain" {
            
            let lengthValue = lengths.gf
            
            let navController = segue.destination as! UINavigationController
            let destinationViewController = navController.topViewController as! DetailViewController
            destinationViewController.exampleLength = lengthValue
            
            
            print("sending to unit changer...")
            
        }
    }
    
}

