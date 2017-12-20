//
//  EditorViewController.swift
//  netcat-client
//
//  Created by vgm on 12/20/17.
//  Copyright © 2017 vgmoose. All rights reserved.
//

import Foundation
import UIKit

class EditorViewController : UIViewController
{
	@IBOutlet weak var textView: UITextView!
	
	var path = ""
	var filename = ""
	var filenameField: UITextField?
	
	override func viewDidLoad() {
		super.viewDidLoad()

		validateAndLoad()
		
		// set up scrollview for scrolling when keyboard pops up
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
		
		fileToolbar.removeFromSuperview()
		
		self.textView.textColor = UIColor.black
		self.textView.backgroundColor = UIColor.white
		
		self.textView.inputAccessoryView = fileToolbar
		self.textView.becomeFirstResponder()

	}
	
	func validateAndLoad()
	{
		titleBar.title = self.filename
		
		// validate the file that we're opening is a real file, and that we can read from it
		let target = self.path + "/" + self.filename
		
		do {
			let readingText = try NSString(contentsOfFile: target, encoding: String.Encoding.utf8.rawValue)
			
			textView.text = readingText as String
		} catch {
			// could not read file
			textView.text = ""
		}
		
	}
	
	@IBOutlet weak var fileToolbar: UIToolbar!
	
	@IBOutlet weak var titleBar: UINavigationItem!

	@IBAction func mySave(_ sender: Any)
	{
		innerSave()
	}
	
	func innerSave() -> Bool
	{
		let target = self.path + "/" + self.filename
		
		do {
			try textView.text!.write(toFile: target, atomically: false, encoding: String.Encoding.utf8)
			return true
			
		} catch {
			// could not write to file
			let controller: ViewController = UIApplication.shared.keyWindow?.rootViewController as! ViewController
			
			var alert = UIAlertController(title: "Permission Denied", message: "There was a permission error saving your file. You can enter a different filename now, and it will be saved to your home folder.", preferredStyle: UIAlertControllerStyle.alert)
			
			func filenamePrompt(textField: UITextField!){
				// add the text field and make the result global
				textField.placeholder = "filename.txt"
				textField.text = filename
				filenameField = textField
			}
			
			alert.addTextField(configurationHandler: filenamePrompt)
			
			alert.addAction(UIAlertAction(title: "Back", style: .default, handler: nil))
			alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {
				(alertAction:UIAlertAction!) in
				// update filename
				self.filename = self.filenameField!.text!
				self.titleBar.title = self.filename
				
				// update path to home directory
				self.path = NSHomeDirectory()
				
				// try save again
				self.innerSave()
			}))
			
			self.present(alert, animated: true)
			
			return false
		}
	}
	
	@IBAction func mySaveAndQuit(_ sender: Any)
	{
		let saved = innerSave()
		
		if saved {
			actuallyDismiss()
		}
	}
	
	func actuallyDismiss() {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func myQuit(_ sender: Any) {
		var alert = UIAlertController(title: "Unsaved Changes", message: "Are you sure you want to quit? Any changes will not be saved.", preferredStyle: UIAlertControllerStyle.alert)
		
		alert.addAction(UIAlertAction(title: "Keep Editing", style: .default, handler: nil))
		alert.addAction(UIAlertAction(title: "Quit", style: .default, handler: { (alertAction:UIAlertAction!) in self.actuallyDismiss() }))
		
		self.present(alert, animated: true)
	}
	
	func keyboardWillShow(notification:NSNotification){
		
		var userInfo = notification.userInfo!
		var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
		keyboardFrame = self.view.convert(keyboardFrame, from: nil)
		
		var contentInset:UIEdgeInsets = self.textView.contentInset
		contentInset.bottom = keyboardFrame.size.height
		self.textView.contentInset = contentInset
	}
	
	func keyboardWillHide(notification:NSNotification){
		
		let contentInset:UIEdgeInsets = UIEdgeInsets.zero
		self.textView.contentInset = contentInset
	}
	
}
