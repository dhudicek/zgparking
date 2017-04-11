//
//  AddCarViewController.swift
//  ZGParking
//
//  Created by Damjan Hudiček on 11/04/2017.
//  Copyright © 2017 ngajski. All rights reserved.
//

import UIKit

class AddCarViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var licensePlateLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var licensePlateTextField: UITextField!
    
    var doneButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initBarButtons()
        initLabelsAndTextFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func doneButtonTapped() {
        PersistenceService.addCar(name: nameTextField.text!, licensePlate: licensePlateTextField.text!.uppercased())
        self.navigationController?.popViewController(animated: true)
    }
    
    private func initBarButtons() {
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped))
        self.doneButton?.isEnabled = false
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    
    private func initLabelsAndTextFields() {
        self.nameLabel.text = "Ime: "
        self.licensePlateLabel.text = "Registracija: "
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: self.nameTextField)
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: NSNotification.Name.UITextFieldTextDidChange, object: self.licensePlateTextField)
    }
    
    func textFieldDidChange() {
        if ((self.licensePlateTextField.text?.isEmpty)! || (self.nameTextField.text?.isEmpty)!) {
            self.doneButton?.isEnabled = false
        }
        else {
            self.doneButton?.isEnabled = true
        }
    }
}
