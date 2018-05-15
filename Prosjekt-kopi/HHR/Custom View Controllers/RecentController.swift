//
//  RecentController.swift
//  HHR
//
//  Created by Anders Berntsen on 09.05.2018.
//  Copyright © 2018 Helping Hand. All rights reserved.
//

import UIKit
import Firebase

class RecentController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var ref: DatabaseReference!
    var messagesArray = [messages]()
    var messagesDictionary = [String: messages]()
    var messagesArrayFiltered = [messages]()
    var users = [userList]()

    struct messages {
        var fromID: String?
        var toID: String?
        var text: String?
        var timestamp: NSNumber?
    }
    
    struct userList {
        var name: String?
    }

    //Pull to refresh
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadArray), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.darkGray
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 100
        ref = Database.database().reference()
        self.hideKeyboardWhenTappedAround()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.search
        self.tableView.addSubview(self.refreshControl)
        
        observeUserMessages()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeUserMessages()

    }
    
    func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let mainRef = ref.child("user-messages").child(uid)
        mainRef.observe(.childAdded, with: { (snapshot) in
            
            let messageID = snapshot.key
            let messagesRef = self.ref.child("Messages").child(messageID)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                let dictionary = snapshot.value as? [String: AnyObject]
                let message = messages.init(fromID: (dictionary!["fromID"] as! String), toID: (dictionary!["toID"] as! String), text: (dictionary!["text"] as! String), timestamp: (dictionary!["timestamp"] as! NSNumber))
                
                let chatPartnerID: String?
                if message.fromID == Auth.auth().currentUser?.uid {
                    chatPartnerID = message.toID!
                } else {
                    chatPartnerID = message.fromID!
                }
                
                if let chatPartnerID = chatPartnerID {
                    self.messagesDictionary[chatPartnerID] = message
                    
                    self.messagesArray = Array(self.messagesDictionary.values)
                    self.messagesArray.sort(by: { (message1, message2) -> Bool in
                        return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
                    })
                    self.messagesArrayFiltered = self.messagesArray
                }
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArrayFiltered.count
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messagesArrayFiltered[indexPath.row]
        
        let chatPartnerID: String?
        if message.fromID == Auth.auth().currentUser?.uid {
            chatPartnerID = message.toID!
        } else {
            chatPartnerID = message.fromID!
        }
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogController.currentForeignUID = chatPartnerID
            self.navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        let message = messagesArrayFiltered[indexPath.row]
        
        var imageURL: URL?
        
        let chatPartnerID: String?
        if message.fromID == Auth.auth().currentUser?.uid {
            chatPartnerID = message.toID!
        } else {
            chatPartnerID = message.fromID!
        }
        
        if let id = chatPartnerID {
            ref.child("userInfo").child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? [String: AnyObject]
                
                self.users.append(userList.init(name: dictionary!["Name"] as? String))
                imageURL = URL(string: (dictionary!["profileImage"] as? String)!)
                
                cell.nameLabel.text = self.users[indexPath.row].name
                
                let networkService = NetworkService(url: imageURL!)
                networkService.downloadImage { (data) in
                    let image = UIImage(data: data as Data)
                    DispatchQueue.main.async {
                        cell.profileImage.image = image
                    }
                }
            }, withCancel: nil)
        }
        
        
        if let seconds = message.timestamp?.doubleValue {
            let timestampDate = NSDate(timeIntervalSince1970: seconds)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "hh:mm:ss a"
            cell.dateTime.text = dateFormatter.string(from: timestampDate as Date)
        }
        
        cell.recentChatLabel.text = message.text
        
        //sets the profile images to be round
        cell.profileImage.layer.borderWidth = 1
        cell.profileImage.layer.masksToBounds = false
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height/2
        cell.profileImage.clipsToBounds = true
        cell.profileImage.layer.borderColor = UIColor.black.cgColor
        return cell
    }
    
    @objc func reloadArray() {
        observeUserMessages()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
}
