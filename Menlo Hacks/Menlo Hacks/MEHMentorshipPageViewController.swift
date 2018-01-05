//
//  MEHMentorshipPageViewController.swift
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/5/17.
//  Copyright © 2017 MenloHacks. All rights reserved.
//

//Written in Swift 2 because PageMenu doesn't seem to like Swift 3.

import Foundation
import UIKit
import PageMenu
import Bolts

@objc class MEHMentorshipPageViewController: UIViewController {
    

    
    var pageMenu : CAPSPageMenu?
    
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
        vc1.categories = [kMEHQueueCategory];
        
        vc1.fetchFromServer = { () -> BFTask<AnyObject> in
            return MEHMentorshipStoreController.shared().fetchQueue()
        }
        
        vc1.title = "Queue";
        
        let vc2 = MEHMentorshipViewController()
        vc2.requiresLogin = true
        vc2.predicate = NSPredicate(format: "claimedByMe = 1")
        vc2.categories = [kMEHInProgressCategory];
        
        vc2.fetchFromServer = { () -> BFTask<AnyObject> in
            return MEHMentorshipStoreController.shared().fetchClaimedQueue()
        }
        
        vc2.title = "Claimed";
        
        let vc3 = MEHMentorshipViewController()
        vc3.requiresLogin = true
        
        vc3.predicate = NSPredicate(format: "isMine=1")
        
        vc3.fetchFromServer = { () -> BFTask<AnyObject> in
            return MEHMentorshipStoreController.shared().fetchUserQueue().continueOnSuccessWith(block: { (task : BFTask) -> AnyObject? in
                vc3.categories = task.result as! [AnyObject]
                return task
            });
        }
        
        vc3.title = "My Tickets";
        
        
        
        
        
        let controllers = [vc1, vc2, vc3]
        
        // Initialize page menu with controller array, frame, and optional parameters
        
        let pageMenuParameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(0),
            .scrollMenuBackgroundColor(UIColor.white),
            .viewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .bottomMenuHairlineColor(UIColor.menloHacksPurple()),
            .selectionIndicatorColor(UIColor.menloHacksPurple()),
            .menuMargin(20.0),
            .menuHeight(40.0),
            .selectedMenuItemLabelColor(UIColor.menloHacksPurple()),
            .unselectedMenuItemLabelColor(UIColor.menloHacksGray()),
            .menuItemFont(UIFont(name: "Avenir", size: 16.0)!),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorRoundEdges(true),
            .selectionIndicatorHeight(2.0),
            .menuItemSeparatorPercentageHeight(0.1)
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllers, frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: pageMenuParameters)
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
        
    }
    
    @objc func addTicket(sender : AnyObject) {
        let vc = MEHAddMentorTicketViewController()
        self.displayContentController(vc)
        
    }
}
