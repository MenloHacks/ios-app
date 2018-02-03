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
    
    override func viewWillAppear(animated: Bool) {
        if (self.parentViewController?.navigationItem.rightBarButtonItem == nil) {
            let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addTicket(_:)))
            self.parentViewController?.navigationItem.rightBarButtonItem = addButton;
        }

    }
    
    override func viewDidLoad(){
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(self.addTicket(_:)))
        
        self.parentViewController?.navigationItem.rightBarButtonItem = addButton;
        
        let vc1 = MEHMentorshipViewController()
        vc1.categories = [kMEHQueueCategory];
        
        vc1.fetchFromServer = { () -> BFTask in
            return MEHMentorshipStoreController.sharedMentorshipStoreController().fetchQueue()
        }
        
        vc1.title = "Queue";
        
        let vc2 = MEHMentorshipViewController()
        vc2.requiresLogin = true
        vc2.predicate = NSPredicate(format: "claimedByMe = 1")
        vc2.categories = [kMEHInProgressCategory];
        
        vc2.fetchFromServer = { () -> BFTask in
            return MEHMentorshipStoreController.sharedMentorshipStoreController().fetchClaimedQueue()
        }
        
        vc2.title = "Claimed";
        
        let vc3 = MEHMentorshipViewController()
        vc3.requiresLogin = true
        
        vc3.predicate = NSPredicate(format: "isMine=1")
        
        vc3.fetchFromServer = { () -> BFTask in
            return MEHMentorshipStoreController.sharedMentorshipStoreController().fetchUserQueue().continueWithSuccessBlock({ (task : BFTask) -> AnyObject? in
                vc3.categories = task.result as! [AnyObject]
                return task
            });
        }
        
        vc3.title = "My Tickets";
        
        
        
        
        
        let controllers = [vc1, vc2, vc3]
        
        // Initialize page menu with controller array, frame, and optional parameters
        
        let pageMenuParameters: [CAPSPageMenuOption] = [
            .MenuItemSeparatorWidth(0),
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .ViewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .BottomMenuHairlineColor(UIColor.menloHacksPurple()),
            .SelectionIndicatorColor(UIColor.menloHacksPurple()),
            .MenuMargin(20.0),
            .MenuHeight(40.0),
            .SelectedMenuItemLabelColor(UIColor.menloHacksPurple()),
            .UnselectedMenuItemLabelColor(UIColor.menloHacksGray()),
            .MenuItemFont(UIFont(name: "Avenir", size: 16.0)!),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorRoundEdges(true),
            .SelectionIndicatorHeight(2.0),
            .MenuItemSeparatorPercentageHeight(0.1)
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllers, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: pageMenuParameters)
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
        
    }
    
    func addTicket(sender : AnyObject) {
        let vc = MEHAddMentorTicketViewController()
        self.displayContentController(vc)
        
        
        
    }
}
