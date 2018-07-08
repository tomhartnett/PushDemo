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
            
            attachment.url.stopAccessingSecurityScopedResource()
        }
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
        NSLog("Content Extension didReceive: \(response.actionIdentifier)")
        
        // Handle various actions.
        if response.actionIdentifier == "likeAction" {
            likeLabel.isHidden = false
        }
        
        // Dont dismiss extension to allow further interaction.
        completion(.doNotDismiss)
    }
}
