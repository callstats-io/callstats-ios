//
//  ViewController.swift
//  demo
//
//  Created by Amornchai Kanokpullwad on 5/13/18.
//  Copyright © 2018 callstats. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var roomNameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func joinButtonPressed(_ sender: Any) {
        if (roomNameTextField.text ?? "").isEmpty {
            let alert = UIAlertController(
                title: nil,
                message: "Please choose room",
                preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        performSegue(withIdentifier: "CallSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let callVC = segue.destination as! CallViewController
        callVC.room = roomNameTextField.text ?? ""
    }
}

