//
//  AddFriendViewController.swift
//  Syncopate
//
//  Created by Emily Ou on 4/8/20.
//  Copyright © 2020 Syncopate. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    // Outlets
    @IBOutlet weak var userSearchBar: UISearchBar!
    @IBOutlet weak var addFriendTableView: UITableView!
    var friends: NSArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFriendTableView.dataSource = self
        addFriendTableView.delegate = self
        userSearchBar.delegate = self
                
        addFriendTableView.rowHeight = UITableView.automaticDimension
        addFriendTableView.estimatedRowHeight = 150
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getQueryResult()
        addFriendTableView.reloadData()
    }
    
    func getEmail(at indexPath: IndexPath) -> String {
        let friend = friends[indexPath.row] as! NSDictionary
        let email = friend["email"]
        return email as! String
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = addFriendTableView.dequeueReusableCell(withIdentifier: "AddFriendCell") as! AddFriendCell
        
        // Retrieve friends info
        let friend = friends[indexPath.row] as! NSDictionary
        
        //email = friend["email"]
        
        // Populate cells
        let baseURL = "http://18.219.112.140/images/avatars/"
        let picURL = (friend["profile_pic_url"] as? String)!
        let imageURL = URL(string: (baseURL + picURL))!
        let first_name = friend["first_name"] as? String
        let last_name = friend["last_name"] as? String
        let email = friend["email"] as! String
        let username = (email.replacingOccurrences(of: "@purdue.edu", with: ""))
        
        cell.nameLabel.text = ((first_name)!) + " " + ((last_name)!)
        cell.profileImage.af.setImage(withURL: imageURL)
        cell.usernameLabel.text = username
        
        // Make the profile pic circular
        cell.profileImage.layer.masksToBounds = false
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.height / 2
        cell.profileImage.clipsToBounds = true
        
        // add friend button is clicked 
        cell.addButtonAction = { [unowned self] in
            // Alert controller
            let options = UIAlertController(title: "Add Friend", message: "Are you sure you want to add Bob as a friend?", preferredStyle: .alert)
            let yesButton = UIAlertAction(title: "Yes", style: .default) { (action) in
                print("Here in yes")
                self.sendFriendRequest(email: email)
            }
            let noButton = UIAlertAction(title: "No", style: .default) { (action) in }
            
            options.addAction(yesButton)
            options.addAction(noButton)
            
            self.present(options, animated: true)
        }
        
        return cell
    }
    
    @IBAction func dismissKeyboard(_ sender: Any) {
        self.userSearchBar.endEditing(true)
    }
    
    // Update list as search bar text changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        getQueryResult()
        addFriendTableView.reloadData()
    }
    
    func getQueryResult() {
        // Create search user POST parameters
        let query: [String : Any] = [
            "query": userSearchBar.text!
        ]
        
        // Search query endpoint
        let url = "http://18.219.112.140:8000/api/v1/search-users/"
        
        // HTTP request
        AF.request(url, method: .post, parameters: query, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
                case .success(let value):
                    if let data = value as? [String : Any] {
                        //self.searchBar = nil
                        
                        self.friends = data["users"] as! NSArray
                        self.addFriendTableView.reloadData()
                    }
                
                case .failure(let error):
                    print(error.localizedDescription)
                }
        }
    }
    
    // get the friend email to send friend request
    func sendFriendRequest(email: String) {
        // TODO
        // Send message request
        // Get incoming message request
        // Get outgoing message request
        // Update message request
        //let friend = friends[indexPath.row] as! NSDictionary
        
        // Create send message request POST parameters
        let param: [String : Any] = [
            //"email": friend["email"] as! String
            "email": email
        ]
        
        // Send message request endpoint
        let url = "http://18.219.112.140:8000/api/v1/send-request/"
        
        // HTTP request
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON { (response) in
            switch response.result {
                case .success(let value):
                    if let data = value as? [String : Any] {
                        if(data["status"] as! String == "success") {
                            self.addFriendTableView.reloadData()
                        }
                    }
                
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}