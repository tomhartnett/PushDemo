//
//  NotificationViewController.swift
//  ImageContentExtensionV3
//
//  Created by Tom Hartnett on 7/11/18.
//  Copyright © 2018 Sleekible, LLC. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        likeLabel.isHidden = true
        likeButton.layer.opacity = 0.5
    }
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        
        if likeLabel.isHidden {
            
            likeLabel.isHidden = false
            likeButton.layer.opacity = 1.0
            
        } else {
            
            likeLabel.isHidden = true
            likeButton.layer.opacity = 0.5
        }
    }
    
    @IBAction func openAppButtonTapped(_ sender: Any) {
        
        // NEW in iOS 12: perform the default action for tapping on the notification.
        // You may need to use this if you set UNNotificationExtensionUserInteractionEnabled=YES
        // in the plist as the notification will no longer dismiss and open the app by tapping on it.
        extensionContext?.performNotificationDefaultAction()
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
                                              height: (scaledRatio * image.size.height) + 37)
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

}
