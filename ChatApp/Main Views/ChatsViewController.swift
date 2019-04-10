//
//  ChatsViewController.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/8/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ChatsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filterChats: [NSDictionary] = []
    
    var recentListener: ListenerRegistration!
    
    override func viewWillAppear(_ animated: Bool) {
        loadRecentChats()
        
        // remove unused cells
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        setTableViewHeader()
    
    }
    

  
    // MARK: IBActions
    
    @IBAction func createNewChatButtonPressed(_ sender: Any) {
        
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
    //MARK: TableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return recentChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentChatsTableViewCell
        
        let recent = recentChats[indexPath.row]
        
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: LoadRecentChats
    
    func loadRecentChats() {
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapshot, error) in
            guard let snapshot = snapshot else { return }
            
            self.recentChats = []
            
            if !snapshot.isEmpty {
                
                //  sorting recent messagings
                let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                for recent in sorted {
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                    }
                }
                
                self.tableView.reloadData()
                
            }
        })
    }
    
    
    // MARK: Custom TableViewHeader
    
    func setTableViewHeader() {
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 45))
        
        let buttonView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 35))
        
        let groupButton = UIButton(frame: CGRect(x: tableView.frame.width - 110, y: 10, width: 100, height: 20))
        
        groupButton.addTarget(self, action: #selector(self.groupButtonPressed), for: .touchUpInside)
        
        groupButton.setTitle("New Group", for: .normal)
        
        let buttonColor = #colorLiteral(red: 0.02368391864, green: 0.4407466054, blue: 0.7316558957, alpha: 1)
        
        groupButton.setTitleColor(buttonColor, for: .normal)
        let lineView = UIView(frame: CGRect(x: 0, y: headerView.frame.height - 1, width: tableView.frame.width, height: 1))
        
        lineView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        
        buttonView.addSubview(groupButton)
        headerView.addSubview(buttonView)
        headerView.addSubview(lineView)
        
        tableView.tableHeaderView = headerView
        
    }
    
    @objc func groupButtonPressed() {
        print("button pressed")
    }
}
