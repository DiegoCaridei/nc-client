//
//  ViewController.swift
//  netcat-client
//
//  Created by vgm on 12/17/16.
//  Copyright © 2016 vgmoose. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var console: ConsoleView!
	var welcomed = false
	        
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
    
    override func viewDidAppear(_ animated: Bool) {
		
		if !welcomed
		{
			// welcome message
			let lastDate = Date().string(with: "EEE MMM dd hh:mm:ss")
	//		console.log("Terminal by Richard Ayoub")
			console.log("Last login: \(lastDate)")
			
			// disable spell checking (messes up some commands)
			console.autocorrectionType = UITextAutocorrectionType.no;
			console.newline()
			
			welcomed = true
		}
		
		self.console.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func keyboardWillShow(notification:NSNotification){
        
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.console.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.console.contentInset = contentInset
    }
    
    func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.console.contentInset = contentInset
    }

}

extension Date {
	func string(with format: String) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = format
		return dateFormatter.string(from: self)
	}
}
