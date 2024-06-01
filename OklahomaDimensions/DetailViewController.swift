//
//  DetailViewController.swift
//  OklahomaDimensions
//
//  Created by MURPHY\spaschal on 8/2/15.
//  Copyright (c) 2015 Spencer Paschal. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var segControl: UISegmentedControl!
    @IBOutlet weak var exampleLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    let toInches = 2
    let toCm = 1
    let current = 0
    
    var selectedConversion = 0
    var exampleLength:Float = 0
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        selectedConversion = segControl.selectedSegmentIndex
        exampleLabel.text = "\(exampleLength)"
    
        print("\(segControl.selectedSegmentIndex)")
        // Do any additional setup after loading the view.
        
        UIView.animate(withDuration: 0.7, delay: 3.0, options: .curveEaseOut, animations: {
            self.detailLabel.alpha = 0.0
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func segControlChanged(_ sender: UISegmentedControl, forEvent event: UIEvent) {
    
        let state = segControl.selectedSegmentIndex
        self.selectedConversion = state
        
        if state == current {
            exampleLabel.text = "Current = \(exampleLength)"
        } else {
            var unitLabel:String = " in"
            var currentLabel:String = " cm"
            var tempLength:Float = Float(exampleLength)
            
            if state == toCm {
                tempLength = (Float(exampleLength) * 2.54)
                unitLabel = " cm"
                currentLabel = " in"
            } else if state == toInches {
                tempLength = (Float(exampleLength) * 0.393701)
                unitLabel = " in"
                currentLabel = " cm"
            } else {
                exampleLabel.text = "Error"
                unitLabel = ""
                currentLabel = ""
                tempLength = 0
            }
            
            exampleLabel.text = "G-F: \(exampleLength)\(currentLabel) = \(tempLength)\(unitLabel)"
        }
    }
    
    @IBAction func cancelToViewController2(_ segue:UIStoryboardSegue) {
        print("Cancelling")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "backToMain" {
            print("")
        }
        
            
        let destinationController = segue.destination as! ViewController
        destinationController.unitSelector = selectedConversion
            
            
        print("Sending to unit changer...")
            
        
        // Get the new view controller using [segue destinationViewController].
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
