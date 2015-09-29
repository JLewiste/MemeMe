//
//  ViewController.swift
//  MemeMe V1.0
//
//  Created by JohannesLewiste on 8/23/15.
//  Copyright (c) 2015 MohdFirdause. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate
    , UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var displayImage: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // Hide status bar
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableButtons(false)
        
        // Set meme text's attributes
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -4
        ]
     
        // Set text field's attributes
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        // Align text to the center
        topTextField.textAlignment = NSTextAlignment.Center
        bottomTextField.textAlignment = NSTextAlignment.Center
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // Enable camera if it is available
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }

    // Select image from camera
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
        enableButtons(true)
    }
   
    // Select image from album
    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
        enableButtons(true)
    }
    
    //Pick an image and display it via UIImageView
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            displayImage.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    //Hide the keyboard when return key is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //Clear the text field when editing
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    
    // Push the view up when editing text field that is blocked by keyboard initially
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.editing {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    // Resize the view back to normal when keyboard is hidden
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.editing {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    // Get keyboard height so that the keyboard will push the view upwards
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    // Subscribe keyboard notifications
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // Unsubscribe keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    // Generate meme image
    func generateMemedImage() -> UIImage {

        // Hide toolbar and navbar
        hideToolBar(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        hideToolBar(false)
        return memedImage
    }

    // Save the edited meme image
    func save() {
        var meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, originalImage: displayImage.image!, memeImage: generateMemedImage())
    }
    
    // Share the edited meme image
    @IBAction func shareImage(sender: UIBarButtonItem) {
        let modifiedMeme = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [modifiedMeme], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {
            (s: String!, ok: Bool, items: [AnyObject]!, err:NSError!) -> Void in
            if ok {
                self.save()
            }
        }
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // Reset the meme editor
    @IBAction func cancelImage(sender: AnyObject) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        displayImage.image = nil
        enableButtons(false)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // Enable or disable share and cancel button
    func enableButtons(enabled: Bool) {
        shareButton.enabled = enabled
        cancelButton.enabled = enabled
    }
    
    // Hide or unhide top and bottom tool bar
    func hideToolBar(hidden: Bool) {
        topToolBar.hidden = hidden
        bottomToolBar.hidden = hidden
    }
}

