//
//  ConsoleView.swift
//  netcat-client
//
//  Created by vgm on 12/17/16.
//  Copyright © 2016 vgmoose. All rights reserved.
//

import Foundation
import UIKit


class ConsoleView: UITextView, StreamDelegate {

    // the current command that will be sent
    var command: String = ""
	
	let prompt = "\(NSUserName())$ "
	var pwd = NSHomeDirectory()
	
    override func insertText(_ text: String) {
        adjustCursor()

		//TODO: if it has one or more \n's in it, call insertText multiple times
		
        // insert text into this buffer
        super.insertText(text)
		
        // if it's a newline, send it
        if (text == "\n") {
			
			self.processCmd(command)
			self.newline()
        }
		else // add this text to the command
		{
			// append incoming text to the current command
			command += text
		}
        
    }
	
	func processCmd(_ cmd_raw_raw: String)
	{
		var cmd_raw = cmd_raw_raw.trimmingCharacters(in: .whitespacesAndNewlines)
		
		let cmds = cmd_raw.components(separatedBy: " ")
		var cmd = cmds[0].lowercased()
		let args = cmd_raw.substring(from: cmd.endIndex).trimmingCharacters(in: .whitespacesAndNewlines)
		
		print("Received command: \(cmd), with args: \(args)")
		
		if cmd == "clear"
		{
			self.text = ""
		}
		else if cmd == "echo"
		{
			log(args)
		}
		else if cmd == "pwd"
		{
			log(self.pwd)
		}
		else if cmd == "vi" || cmd == "vim" || cmd == "nano" || cmd == "emacs" || cmd == "edit" || cmd == "gedit" || cmd == "open" || cmd == "gvim" || cmd == "pico" || cmd == "kate" || cmd == "ed"
		{
			// launch file editor on the target
			var filename = args.components(separatedBy: " ")[0]
			
			let controller: ViewController = UIApplication.shared.keyWindow?.rootViewController as! ViewController
			
			let vc: EditorViewController = (controller.storyboard?.instantiateViewController(withIdentifier: "Editor"))! as! EditorViewController
			vc.path = self.pwd
			vc.filename = filename
			
			// if no filename was given, prompt for it
			if filename == ""
			{
				log("Prompting for file name")
				var filenameField: UITextField?
				
				var alert = UIAlertController(title: "New File", message: "Enter the desired file name.", preferredStyle: UIAlertControllerStyle.alert)
				
				func filenamePrompt(textField: UITextField!){
					// add the text field and make the result global
					textField.placeholder = "filename.txt"
					filenameField = textField
				}
				
				alert.addTextField(configurationHandler: filenamePrompt)
				
				alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
				alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: {
					(alertAction:UIAlertAction!) in
					filename = filenameField!.text!
					
					vc.filename = filename
					controller.present(vc, animated: true, completion: nil)
				}))
				
				let controller: ViewController = UIApplication.shared.keyWindow?.rootViewController as! ViewController
				controller.present(alert, animated: true)
			}
			else
			{
				controller.present(vc, animated: true, completion: nil)
				log("Opened text editor window")
			}

		}
		else if cmd == "mkdir"
		{
			let target = self.pwd + "/" + args.components(separatedBy: " ")[0]
			
			do {
				try FileManager.default.createDirectory(atPath: target, withIntermediateDirectories: true, attributes: nil)
			} catch {
				log("mkdir: Permission denied")
			}
		}
		else if cmd == "touch"
		{
			let target = self.pwd + "/" + args.components(separatedBy: " ")[0]

			do {
				try "".write(toFile: target, atomically: false, encoding: String.Encoding.utf8)
			} catch {
				log("touch: Permission denied")
			}
		}
		else if cmd == "cat"
		{
			let target = self.pwd + "/" + args.components(separatedBy: " ")[0]

			do {
				let readingText = try NSString(contentsOfFile: target, encoding: String.Encoding.utf8.rawValue)
				log(readingText as String, terminator: "")
			} catch {
				log("cat: Permission denied")
			}
		}
		else if cmd == "rm" || cmd == "rmdir"
		{
			var cur_args = args.components(separatedBy: " ")
			
			var firstArg = cur_args[0]
			var x = 0
			
			if firstArg == "-r" {
				// if the -r flag is specified, offset the file that will be deleted
				// TODO: handle multiple files
				x = 1
				
				// also, if there's not going to be a second argument, just exit
				if cur_args.count == 1 {
					self.log("rm: no directory specified")
					return
				}
			}
			
			if firstArg == "" {
				self.log("rm: no file/directory specified")
				return
			}
			
			let target = try self.pwd + "/" + cur_args[x]
			
			// check if it's a folder for safety
			var isDir : ObjCBool = false
			FileManager.default.fileExists(atPath: target, isDirectory: &isDir)
			
			do {
				if isDir.boolValue {
					// for rmdir, make sure directory is empty
					if cmd == "rmdir" {
						let contents = try FileManager.default.contentsOfDirectory(atPath: target)
						if contents.count != 0 {
							self.log("rmdir: Directory not empty")
							return
						}
					}
					// else, ensure there's a -r flag
					else if firstArg != "-r" {
						self.log("rm: Refusing to delete without \"-r\"")
						return
					}
				}
			
				try FileManager.default.removeItem(atPath: target)
			} catch {
				log("rm: Permission denied")
			}
		}
		else if cmd == "cd"
		{
			var newPath = self.pwd
			var target = args.components(separatedBy: " ")[0]
			
			if args == "" {
				newPath = NSHomeDirectory()
			}
			else if args[args.startIndex] == "/" {
				// absolute path
				newPath = target
			}
			else {
				// relative path
				newPath += "/" + target
			}
			
			
			var isDir : ObjCBool = false
			FileManager.default.fileExists(atPath: newPath, isDirectory: &isDir)
			
			if isDir.boolValue {
				// valid path, update pwd
				self.pwd = newPath
			}
			else {
				log("cd: Not a directory")
			}
			
		}
		else if cmd == "ls"
		{
			var target = self.pwd + "/" + args.components(separatedBy: " ")[0]
			
			do{
				let items = try FileManager.default.contentsOfDirectory(atPath: target)
				
				var resp = ""
				for item in items {
					resp += "\(item)\n"
				}
				log(resp, terminator: "")
				
			} catch {
				log("ls: Permission denied")
			}
		}
		else if cmd == "cp"
		{
			if cmds.count < 3 {
				log("Target and destination required")
				return
			}
			var targ1 = cmds[1]
			var file1 = self.pwd
			if targ1[targ1.startIndex] == "/" {
				// absolute path
				file1 = targ1
			}
			else {
				// relative path
				file1 += "/" + targ1
			}
			
			var targ2 = cmds[2]
			var file2 = self.pwd
			if targ2[targ2.startIndex] == "/" {
				// absolute path
				file2 = targ2
			}
			else {
				// relative path
				file2 += "/" + targ2
			}
			
			do {
				print("\(file1) \(file2)")
				try FileManager.default.copyItem(atPath: file1, toPath: file2)
			} catch {
				log("cp: Permission denied")
			}
		}
		else if cmd == "run" || cmd == "." || cmd == "exec"
		{
			if cmds.count < 2 {
				log("nothing supplied to run")
				return
			}
			
			log(executeShell(command: cmds[1], arguments: [])!)
		}
		else if cmd.hasPrefix("./")
		{
			cmd.remove(at: cmd.startIndex)
			cmd.remove(at: cmd.startIndex)

			log(executeShell(command: cmd, arguments: [])!)
		}
		else if cmd == ""
		{
			// do nothing
		}
		else
		{
			// try to execute it anyway
			log("-iosh: \(cmd): command not found")
		}
	}
	
    func log(_ text: String, terminator:String = "\n") {
        // run on the main thread
        OperationQueue.main.addOperation {
            self.adjustCursor()
            
            // insert the log message
            super.insertText("\(text)\(terminator)")
        }
    }
    
    override func deleteBackward() {
        adjustCursor()
		
		// short circuit if at the end of the current line
		if command == "" { return }
        
        // delete back a character (may not always be the right character
        // if input has been received since then, but that's ok)
        super.deleteBackward()
        
        // delete one character from the current command
        // http://stackoverflow.com/a/24122445
        if (command.characters.count > 0) {
            command.remove(at: command.index(before: command.endIndex))
        }
    }
	
	func newline() {
		self.log(self.prompt, terminator: "")
		
		// clear command for next time
		command = ""
	}
	
    func adjustCursor() {
        // move cursor to the end of the text field
        self.selectedRange = NSMakeRange(self.text.characters.count, 0);
    }
    
    override func paste(_ any: Any?) {
        adjustCursor()

        // do paste
        super.paste(any)
        
        // update current command (newlines won't trigger a send)
        command += UIPasteboard.general.string!
    }
	
	open override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
		// prevent cut-ing (messes up terminal layout)
		if action == #selector(UIResponderStandardEditActions.cut(_:)) {
			return nil
		}
		return super.target(forAction: action, withSender: sender)
	}
	
	private func executeShell(command: String, arguments: [String] = []) -> String? {
		
		var command_r = command
		
		if !command_r.contains("/") {
			command_r = self.pwd + "/" + command_r
		}
		
		// ensure the path exists before continuing
		
		
		let task = NSTask()!
		task.setLaunchPath(command_r)
		task.setArguments(arguments)
		
		let pipe = Pipe()
		let pid = forkpty()
		task.setStandardOutput(pipe)
		task.setStandardError(pipe)
		
		let tryLaunch = NSObject.tryLaunch
		let error = tryLaunch(task) as String!
		
		if error != "" {
			return error
		}
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output: String? = String(data: data, encoding: String.Encoding.utf8)
		
		return output?.trimmingCharacters(in: .whitespacesAndNewlines)
	}

}
