//
//  MessagesViewController.swift
//  TranslateAIIphoneHelper MessagesExtension
//
//  Created by Eric Yang (student LM) on 4/8/21.
//  Copyright © 2021 Eric Yang (student LM). All rights reserved.
//

//4.19
//other things to do
//Make sure detect language exists and works
// Make sure source language exists and works
// make sure to make the UI gets better
//try to make an imessage object rather than just using copy paste

//4.20
//restrictions
//remember that detect language needs confidence of 1, meaning that the messages need to be longer than usual (wait this might not be true nvm)

//4.21
//Cool things we might want
//For Select language, perhaps use detet language on previous messages (sent by the user) to tell the message we need to translate into
//Send OG message in new text color

//5.1: shortcut feature (like if you type 'u' instead of you)
import UIKit
import Messages
import InstantSearchVoiceOverlay


class MessagesViewController: MSMessagesAppViewController {
    
    //New Code
    
    //shared stuff info?
    static let shared = MessagesViewController()
    
    
    //some new code regarding settings
    var sendOriginalText: Bool?
    let defaults = UserDefaults.standard
    
    //    @IBOutlet weak var originalText: UITextField!
    
    @IBOutlet weak var notExist: UITextView!
    @IBOutlet weak var originalText: UITextView!
    
    //    @IBOutlet weak var originalText: UITextView!
    @IBAction func translateButton(_ sender: Any) {
       
        //detect language (finds the language) (might have an error with delay of return, not sure though)
        
        TranslationManager.shared.detectLanguage(forText: self.originalText.text ?? "does not exist") { (language) in}
        
        //provides old select language (defaults save a code for the text which can be retrieved after the app is closed.) 
        TranslationManager.shared.targetLanguageCode = defaults.string(forKey: "languageCodeKey")
        //Sends the text in text box to the translate manager, to be translated
        TranslationManager.shared.textToTranslate = originalText.text
        
        //Takes the translated string, and sets the translateText equal to that
        TranslationManager.shared.translate(completion: { (translation) in
            
            //Mofidiers of output
            
            //modifier for sending originalText1 in message
            //            guard let sendOriginalText1 =  self.sendOriginalText else{
            //                print("does not work")
            //                return
            //            }
            //
            //            if sendOriginalText1{
            //                       print("hello, i am here")
            //            }
            
            
            if let translation = translation {
                
                DispatchQueue.main.async { [unowned self] in
                    
                    //creates an imessage object and allows user to send (dont need)
                    
                    //                    let layout = MSMessageTemplateLayout()
                    //                    //maybe dont force unwrap idk
                    //                    layout.caption = "\(self.originalText.text ?? "does not exist") \n \(translation)"
                    //
                    //                    let message = MSMessage()
                    //                    message.layout = layout
                    
                    //                    self.activeConversation?.insert(message, completionHandler: nil)
                    
                    
                    
                    
                    //This section adds text to the text bar where the user can send the message
                    //depends upon the states of the two switches in settings view, and we use a switch statement (coincidence that the two share a name) in order to tell what to put in the send bar. 
    
                    let switchStatementVariable = (self.defaults.string(forKey: "originalTextDeciderState"), self.defaults.string(forKey: "translatedTextDeciderState") )
                    switch switchStatementVariable{
                        
                    case (nil, nil), (nil, "on"), ("on", nil), ("on", "on") : self.activeConversation?.insertText("\(self.originalText.text ?? "does not exist") \n \n\(translation)", completionHandler: nil)
                    case (nil, "off"), ("on", "off"): self.activeConversation?.insertText("\(self.originalText.text ?? "does not exist")", completionHandler: nil)
                    case ("off", nil),("off", "on"): self.activeConversation?.insertText("\(translation)", completionHandler: nil)
                    case ("off", "off"): self.activeConversation?.insertText("", completionHandler: nil)

                    default:
                        self.activeConversation?.insertText("default case was used lol")
                    }
                    
                    
                    
                    //Switch statement trial 1
                    //                    switch self.defaults.string(forKey: "originalTextDeciderState"){
                    //
                    //                    case nil, "on": self.activeConversation?.insertText("\(self.originalText.text ?? "does not exist") \n \n\(translation)", completionHandler: nil)
                    //
                    //                    case "off": self.activeConversation?.insertText("\(translation)", completionHandler: nil)
                    //
                    //                    default:
                    //                         self.activeConversation?.insertText("default case was used lol")
                    //                    }
                    
                    
                    //sets original text to non existant so user can type something else
                    self.originalText.text = ""
                }
                //instead of dimissing the app (which removes all important data like source), it just changes it to a comapct view if the view is already expanded.
                if self.presentationStyle == .expanded {
                    self.requestPresentationStyle(.compact)
                }
                
            }
        })
        
    }
    
    
        
    
    //allows for voice recongition
    
    let voiceOverlay = VoiceOverlayController()
    
    @IBAction func spokenTextButton(_ sender: Any) {
        
        
        //Determines whether or not the timer autostarts
//        print("hello \(defaults.string(forKey: "timerAutostartDeciderState"))")
        if defaults.string(forKey: "timerAutostartDeciderState") == "on" || defaults.string(forKey: "timerAutostartDeciderState") == nil  { //if the switch is on or null
            voiceOverlay.settings.autoStart = true
        }
        else { //if the switch is off
            voiceOverlay.settings.autoStart = false
        }
    
        
        //Allows the code to end on its own
        voiceOverlay.settings.autoStop = true
        
        //after 2 seconds if waiting, the Speech to text (STT) will close (based on the value in defaults that was used in the setting view).
        voiceOverlay.settings.autoStopTimeout = Double(defaults.string(forKey: "timerDeciderStringState") ?? "2") ?? 2
//        print("double \(defaults.string(forKey: "timerDeciderStringState"))" )
        
        voiceOverlay.start(on: self, textHandler: {text, final, _ in
            
            if final{
                print("The Final Text: \(text)")
                self.originalText.text=text
                
            }
            else{
                //                print("in progress: \(text)")
            }
            
        }, errorHandler: {error in
            
        })
    }
    //
    //    @IBAction func speechToTextButton(_ sender: Any) {
    //   voiceOverlay.start(on: self, textHandler: {text, final, _ in
    //
    //            if final{
    //                print("Final text: \(text)")
    //                    self.originalText.text=text
    //            }
    //            else{
    //                //                print("in progress: \(text)")
    //            }
    //
    //        }, errorHandler: {error in
    //
    //        })
    //    }
    
    
    
    //IT WORKS!!! (basically opens up another view to work with, for select language)
    //    @IBAction func selectLanguageButton(_ sender: Any) {
    //
    //
    //    }
    //
    
    
    @IBAction func SelectLanguageButton(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier:
            "selectLanguage") else {
                print("failed")
                return
        }
        
        present(vc, animated: true)
    }
    
    @IBAction func SettingViewController(_ sender: Any) {
        guard let vc = storyboard?.instantiateViewController(identifier:
            "SettingView") else {
                print("failed")
                return
        }
        
        present(vc, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        originalText.resignFirstResponder()
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    
    
    // Do any additional setup after loading the view.
    
    //        let message = composeMessage(caption: conversation, session: conversation.selectedMessage?.session)
    
    //    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
    //        guard let conversation = activeConversation else { fatalError("Expected a conversation") }
    ////        let str = String(decoding: conversation, as: UTF8.self)
    //        print("sups bruh")
    //
    //    }
    
    
    
    
    
    // MARK: - Conversation Handling
    
    
    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        
        // Use this method to configure the extension and restore previously stored state.
    }
    
    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        
        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }
    
    
    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }
    
    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.
        
        // Use this to clean up state related to the deleted message.
    }
    
    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
        
        // Use this method to prepare for the change in presentation style.
    }
    
    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called after the extension transitions to a new presentation style.
        
        // Use this method to finalize any behaviors associated with the change in presentation style.
    }
    
}
//
//class selectLanguageController: UIViewController{
//
//
//
//}
