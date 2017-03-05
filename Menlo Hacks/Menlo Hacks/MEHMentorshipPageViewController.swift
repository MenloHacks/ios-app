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
    
    override func viewDidLoad(){
        
        let vc1 = MEHMentorshipViewController()
        vc1.categories = [kMEHQueueCategory];
        
        vc1.fetchFromServer = { () -> BFTask in
            return MEHMentorshipStoreController.sharedMentorshipStoreController().fetchQueue()
        }
        
        
        
//        vc1.refreshBlock = { () -> BFTask in
//            return MEHMentorshipStoreController.sharedStoreController().fetchQueue
//        }
        
        
        let vc2 = UIViewController()
        
        let controllers = [vc1, vc2]
        
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
}
