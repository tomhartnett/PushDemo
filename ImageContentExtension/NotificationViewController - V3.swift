//
//  NotificationViewController.swift
//  ImageContentExtension
//
//  Created by Tom Hartnett on 7/7/18.
//  Copyright © 2018 Sleekible, LLC. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        likeLabel.text = "♡"
        likeLabel.isHidden = false
        likeLabel.layer.opacity = 1.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(likeLabelTapped))
        likeLabel.addGestureRecognizer(tapGesture)
        likeLabel.isUserInteractionEnabled = true
        
        // Note: you must add the UNNotificationExtensionUserInteractionEnabled entry to the plist file for this to work.
    }
    
    @objc func likeLabelTapped() {
        
        if likeLabel.text == "♡" {
            likeLabel.text = "❤️"
        } else {
            likeLabel.text = "♡"
        }
    }
    
    func didReceive(_ notification: UNNotification) {
        
        guard let attachment = notification.request.content.attachments.first else { return }
        
        // Get the attachment and set the image view.
        if attachment.url.startAccessingSecurityScopedResource(),
            let data = try? Data(contentsOf: attachment.url) {
            imageView.contentMode = .scaleAspectFit
            imageView.image = UIImage(data: data)
            
            // Adjust preferred content size based on image.
            if let image = imageView.image {
                let scaledRatio = view.bounds.width / image.size.width
                preferredContentSize = CGSize(width: scaledRatio * image.size.width,
                                              height: scaledRatio * image.size.height)
            }
            
            // Note: inital size of view is determined by UNNotificationExtensionInitialContentSizeRatio
            // https://developer.apple.com/documentation/usernotificationsui/unnotificationcontentextension
            
            attachment.url.stopAccessingSecurityScopedResource()
            
            // About startAccessingSecurityScopedResource() & stopAccessingSecurityScopedResource():
            // You need to call 'start' to make resource available to your app.
            // You need to call 'stop' to relinquish that access.
            // If you do not call 'stop' your app can leak kernel resources.
            // https://developer.apple.com/documentation/foundation/nsurl/1417051-startaccessingsecurityscopedreso
            
        }
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        NSLog("Content Extension didReceive: \(response.actionIdentifier)")
        
        // Handle the "Like" button.
        if response.actionIdentifier == "likeAction" {
            
            likeLabel.isHidden = false
            
            let unlikeAction = UNNotificationAction(identifier: "unlikeAction", title: "Unlike", options: [.authenticationRequired])
            extensionContext?.notificationActions = [unlikeAction]
        }
        
        if response.actionIdentifier == "unlikeAction" {
            
            likeLabel.isHidden = true
            
            let likeAction = UNNotificationAction(identifier: "likeAction", title: "Like", options: [.authenticationRequired])
            extensionContext?.notificationActions = [likeAction]
        }
        
        // Dont dismiss extension to allow further interaction.
        completion(.doNotDismiss)
        
        // You could also dismiss the notification here.
        // Or, dismiss it and then forward the action on to AppDelegate.
//        case doNotDismiss
//
//        case dismiss
//
//        case dismissAndForwardAction
    }
}