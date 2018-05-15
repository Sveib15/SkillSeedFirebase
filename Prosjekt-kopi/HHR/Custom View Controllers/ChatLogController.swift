//
//  ChatLogController.swift
//  HHR
//
//  Created by Anders Berntsen on 09.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    struct messages {
        var fromID: String?
        var toID: String?
        var text: String?
        var timestamp: NSNumber?
    }
    
    var ref: DatabaseReference!
    let uid = Auth.auth().currentUser?.uid

    var containerViewBottomAnchor: NSLayoutConstraint?
    var currentForeignUID: String?
    var messagesArray = [messages]()
    var filteredArray = [messages]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor? = UIColor.white
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
                
        setupInputComponents()
        setupKeyboardObservers()
        
        ref = Database.database().reference()
        observeMessages()
        
        ref.child("userInfo").child(currentForeignUID!).child("Name").observeSingleEvent(of: .value, with: { (snapshot) in
            self.navigationItem.title = snapshot.value as? String
        }, withCancel: nil)
    }
    
    func observeMessages() {
        let userMessagesRef = ref.child("user-messages").child(uid!)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = self.ref.child("Messages").child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else {
                    return
                }
                let message = messages.init(fromID: (dictionary["fromID"] as! String), toID: (dictionary["toID"] as! String), text: (dictionary["text"] as! String), timestamp: (dictionary["timestamp"] as! NSNumber))
                
                let chatPartnerID: String?
                if message.fromID == Auth.auth().currentUser?.uid {
                    chatPartnerID = message.toID!
                } else {
                    chatPartnerID = message.fromID!
                }
                if chatPartnerID == self.currentForeignUID {
                    self.messagesArray.append(message)
                    self.filteredArray = self.messagesArray
                    
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    let cellId = "cellId"
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messagesArray.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messagesArray[indexPath.item]
        cell.textView.text = message.text
        
       setUpCell(cell: cell, message: message)
        
        //Sets width of the bubbleview
        cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: message.text!).width + 32
        return cell
    }
    
    private func setUpCell(cell: ChatMessageCell, message: messages) {
        
        var imageURL: URL?
        ref.child("userInfo").child(message.fromID!).child("profileImage").observeSingleEvent(of: .value, with: { (snapshot) in
            imageURL = URL(string: snapshot.value as! String)
            
            let networkService = NetworkService(url: imageURL!)
            networkService.downloadImage { (data) in
                let image = UIImage(data: data as Data)
                DispatchQueue.main.async {
                    cell.profileImageView.image = image
                }
            }
        }, withCancel: nil)
        
        if message.fromID == Auth.auth().currentUser?.uid {
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatMessageCell.bluecolor
            cell.textView.textColor = UIColor.white
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.profileImageView.isHidden = true
        } else {
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
            cell.textView.textColor = UIColor.black
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.profileImageView.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messagesArray[indexPath.item].text {
            height = estimatedFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimatedFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupKeyboardObservers()
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! CGRect)
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        containerViewBottomAnchor?.constant = -keyboardFrame.height
        
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double)
        containerViewBottomAnchor?.constant = -(tabBarHeight!)
        
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        let tabBarHeight = self.tabBarController?.tabBar.frame.size.height
        //contstraints achor
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        
        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(tabBarHeight!))
        containerViewBottomAnchor?.isActive = true
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(UIColor.darkGray, for: .normal)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend) , for: .touchUpInside)
        containerView.addSubview(sendButton)
        //constraints
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        

        containerView.addSubview(inputTextField)
        //constraints
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        
        let seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor.lightGray
        seperatorLine.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLine)
        // cinstraints
        seperatorLine.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLine.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLine.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func handleSend() {
        let mainRef = ref.child("Messages")
        let childRef = mainRef.childByAutoId()
        let toID = currentForeignUID
        let timestamp = NSDate().timeIntervalSince1970 as NSNumber
        let values = ["text": inputTextField.text!, "toID": toID!, "fromID": uid!, "timestamp": timestamp] as [String : AnyObject]
        
        childRef.updateChildValues(values) { (error, mainRef) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessageRef = Database.database().reference().child("user-messages").child(self.uid!)
            let messageId = childRef.key
            userMessageRef.updateChildValues([messageId: 1])
            
            let recipientUserMessageRef = self.ref.child("user-messages").child(toID!)
            recipientUserMessageRef.updateChildValues([messageId: 1])
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }

}
