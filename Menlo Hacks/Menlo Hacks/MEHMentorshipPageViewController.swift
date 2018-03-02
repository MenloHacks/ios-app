//
//  MEHMentorshipPageViewController.swift
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//


import Foundation
import UIKit
import Parchment
import Bolts

@objc class MEHMentorshipPageViewController: UIViewController {
    
    var pageMenu : FixedPagingViewController!
    
    override func viewWillAppear(_ animated: Bool) {
        if (self.parent?.navigationItem.rightBarButtonItem == nil) {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTicket(sender:)))
            self.parent?.navigationItem.rightBarButtonItem = addButton;
        }

    }
    
    override func viewDidLoad(){
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTicket(sender:)))
        
        self.parent?.navigationItem.rightBarButtonItem = addButton;
        
        let vc1 = MEHMentorshipViewController()
        vc1.predicates = [NSPredicate(format:"rawStatus = %i", MEHMentorTicketStatusOpen.rawValue)]
        
        vc1.fetchFromServer = { () -> BFTask<AnyObject> in
            return MEHMentorshipStoreController.shared().fetchQueue()
        }
        
        vc1.title = "Queue";
        
        let vc2 = MEHMentorshipViewController()
        vc2.requiresLogin = true
        vc2.predicates = [NSPredicate(format: "claimedByMe = 1 AND rawStatus = %i", MEHMentorTicketStatusClaimed.rawValue)]
        
        vc2.fetchFromServer = { () -> BFTask<AnyObject> in
            return MEHMentorshipStoreController.shared().fetchClaimedQueue()
        }
        
        vc2.title = "Claimed";
        
        let vc3 = MEHMentorshipViewController()
        vc3.requiresLogin = true
        
        vc3.predicates = [NSPredicate(format: "isMine = 1")];
        
        vc3.fetchFromServer = { () -> BFTask<AnyObject> in
            return MEHMentorshipStoreController.shared().fetchUserQueue().continueOnSuccessWith(block: { (task : BFTask) -> AnyObject? in
                return task
            });
        }
        
        vc3.title = "My Tickets";
        
        
        let controllers = [vc1, vc2, vc3]
        
        pageMenu = FixedPagingViewController(viewControllers: controllers)
        pageMenu.textColor = UIColor.menloHacksGray()
        pageMenu.font = UIFont(name: "Avenir", size: 16.0)!
        pageMenu.selectedTextColor = UIColor.menloHacksPurple()
        pageMenu.indicatorColor = UIColor.menloHacksPurple()
        pageMenu.menuBackgroundColor = UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)
        pageMenu.menuItemSize = .sizeToFit(minWidth: 125, height: 40)
        
        
        
        AutolayoutHelper.configureView(self.view, fillWithSubView: pageMenu.view)
        
    }
    
    @objc func addTicket(sender : AnyObject) {
        let vc = MEHAddMentorTicketViewController()
        self.displayContentController(vc)
        
    }
}
