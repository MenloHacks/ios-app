//
//  NotificationHandler.swift
//  Menlo Hacks
//
//  Created by Jason Scharff on 3/2/19.
//  Copyright © 2019 MenloHacks. All rights reserved.
//

import Foundation
import PusherSwift
import PushNotifications

@objc class NotificationHandler: NSObject {
    
    
    @objc static let shared = NotificationHandler()
    private let pusher: Pusher
    
    private override init() {
        let options = PusherClientOptions(host: .cluster("us3"), encrypted: true)
        self.pusher = Pusher(key: Constants.apiKey, options: options)
        super.init()
        
    }
    
    @objc func initialize() {
        pusher.connect()
        registerForPushNotifictions()
        bindToChannels()
    }
}

// MARK: - Sockets

extension NotificationHandler {
    
    private func bindToChannels() {
        
        let announcementChannel = pusher.subscribe(Constants.announcementUpdate)
        
        announcementChannel.bind(eventName: Constants.channelAction) { event in
            guard let data = event as? [AnyHashable: Any] else {
                return
            }
            MEHAnnouncementsStoreController.shared()?.didReceiveNotification(data)
        }
        
        let eventChannel = pusher.subscribe(Constants.eventUpdate)
        
        eventChannel.bind(eventName: Constants.channelAction) { event in
            guard let data = event as? [AnyHashable: Any] else {
                return
            }
            MEHScheduleStoreController.shared()?.didReceiveNotification(data)
        }
        
        let mentorChannel = pusher.subscribe(Constants.mentorUpdate)
        
        mentorChannel.bind(eventName: Constants.channelAction) { event in
            guard let data = event as? [AnyHashable: Any] else {
                return
            }
            MEHMentorshipStoreController.shared()?.didReceiveNotification([data])
        }
        mentorChannel.bind(eventName: Constants.expireAction) { event in
            guard let data = event as? [Any] else {
                return
            }
            MEHMentorshipStoreController.shared()?.didReceiveNotification(data)
        }
    }
}

// MARK: - APNS

extension NotificationHandler {
    
    private var pushNotifications: PushNotifications {
        return PushNotifications.shared
    }
    
    private func registerForPushNotifictions() {
        pushNotifications.start(instanceId: Constants.instanceId)
        pushNotifications.registerForRemoteNotifications()
        try? self.pushNotifications.addDeviceInterest(interest: Constants.notificationTopic)
    }
    
    @objc func register(deviceToken: NSData) {
        pushNotifications.registerDeviceToken(deviceToken as Data)
    }
    
}

// MARK: - Constants

extension NotificationHandler {
    
    struct Constants {
        static let notificationTopic = "com.viverev.all_devices"
        static let announcementUpdate = "com.viverev.announcement.update"
        static let mentorUpdate = "com.viverev.mentor.update"
        static let eventUpdate = "com.viverev.event.update"
        static let channelAction = "save"
        static let expireAction = "expire"
        
        static let instanceId = "e0e9825b-d7f9-4810-b92a-e1c29c9f5953"
        static let apiKey = "7af4db3ba77255e243af"
    }
}
