//
//  NotificationData.swift
//  InAppNotification
//
//  Created by Henri Gil on 05/01/2018.
//  Copyright © 2018 Henri Gil. All rights reserved.
//

import UIKit

class NotificationData: NSObject {
    
    var id: String = ""
    var title: String = ""
    var message: String = ""
    var thumbnailUrl: String = ""
    var contentImage: String = ""
    var animationStyle: InAppNotificationAnimation = .top
    var delay: Int = 0
}

