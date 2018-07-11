//
//  NotificationService.swift
//  ImageServiceExtension
//
//  Created by Tom Hartnett on 7/7/18.
//  Copyright © 2018 Sleekible, LLC. All rights reserved.
//

import CoreGraphics
import MobileCoreServices
import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var currentDownloadTask: URLSessionDownloadTask?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let mutableContent = bestAttemptContent {
            
            // Retrieve the URL of the image from the payload.
            if let urlString = mutableContent.userInfo["imageUrl"] as? String, let url = URL(string: urlString) {
                
                // Attempt to download the image.
                currentDownloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { fileURL, _, error in
                    
                    if let error = error {
                    
                        // If an error occurred, log it with NSLog so that it shows up in the Console.
                        NSLog("download task failed with \(error)")
                        
                        // Check for "backup text" in payload, but if not found use hard-coded string.
                        let alternateText = mutableContent.userInfo["alternateText"] as? String ?? "Image download failed"
                        mutableContent.body = alternateText
                        
                    } else {
                    
                        // If we have a local file URL, then create an "attachment" and attach it to the notification.
                        if let fileURL = fileURL,
                            let fileType = NotificationService.fileType(fileExtension: url.pathExtension) {
                            
                            let clippingRect = CGRect.zero
                            let options = [UNNotificationAttachmentOptionsTypeHintKey: fileType,
                                           UNNotificationAttachmentOptionsThumbnailClippingRectKey: clippingRect.dictionaryRepresentation,
                                           UNNotificationAttachmentOptionsThumbnailHiddenKey: false] as [AnyHashable : Any]
                            
                            if let attachment = try? UNNotificationAttachment(identifier: "pushAttachment",
                                                                       url: fileURL,
                                                                       options: options) {
                                
                                mutableContent.attachments = [attachment]
                            }
                        }
                    }
                    
                    // Pass the updated notification along to the system with or without the downloaded image.
                    // The use will get the notification after this.
                    contentHandler(mutableContent)
                })
                
                // Begin download task.
                currentDownloadTask?.resume()
            }
        }
    }
    
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    override func serviceExtensionTimeWillExpire() {
        
        // Cancel running download task.
        if let downloadTask = currentDownloadTask {
            downloadTask.cancel()
        }
    }
    
    // Helper function to get a kUTType from a file extension.
    class func fileType(fileExtension: String) -> CFString? {
        return UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as CFString, nil)?.takeRetainedValue()
    }
}
