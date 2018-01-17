//
//  Notification.swift
//  InAppNotification
//
//  Created by Henri Gil on 05/01/2018.
//  Copyright © 2018 Henri Gil. All rights reserved.
//

import UIKit

protocol NotificationViewDelegate: class {
    func notificationDismissed()
    func notificationTapped(notification: NotificationData)
}

class NotificationView: UIView {
    
    
    var notification = NotificationData() {
        didSet{
            
            if notification.contentImage.count > 0 {
                setImageContent(named: notification.contentImage)
            }
            
            if notification.thumbnailUrl.count > 0 {
                setImageThumbnail(named: notification.thumbnailUrl)
            }
            
            titleLabel.text = notification.title.uppercased()
            messageLabel.text = notification.message
            
            if notification.delay > 0 && timer == nil{
                timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(dismissNotification), userInfo: nil, repeats: false)
            }
        }
    }
    
    
    var colorAlpha: CGFloat = 0.9
    let notificationContent: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints=false
        v.backgroundColor = UIColor(white: 1, alpha: 0.9)
        v.clipsToBounds = true
        v.layer.cornerRadius = 10
        return v
    }()
    
    let thumbnail: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled=false
        img.contentMode = .scaleAspectFit
        img.backgroundColor = .clear
        img.translatesAutoresizingMaskIntoConstraints=false
        img.layer.cornerRadius = 6
        return img
    }()
    
    let titleLabel: UILabel = {
        let lab = UILabel()
        lab.isUserInteractionEnabled=false
        lab.translatesAutoresizingMaskIntoConstraints=false
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = .black
        lab.backgroundColor = .clear
        lab.numberOfLines = 0
        return lab
    }()
    
    let messageLabel: UILabel = {
        let lab = UILabel()
        lab.isUserInteractionEnabled=false
        lab.translatesAutoresizingMaskIntoConstraints=false
        lab.font = UIFont.systemFont(ofSize: 15)
        lab.textColor = .black
        lab.numberOfLines = 0
        lab.backgroundColor = .clear
        return lab
    }()
    
    let swipBarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0, alpha: 0.7)
        v.layer.cornerRadius = 5
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let swipBarContenairView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints=false
        v.isHidden=true
        return v
    }()
    
    let contentImage: UIImageView = {
        let img = UIImageView()
        img.isUserInteractionEnabled=false
        img.translatesAutoresizingMaskIntoConstraints=false
        img.backgroundColor = .clear
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        return img
    }()
    
    var timer: Timer?
    var swipBarTopConstraint: NSLayoutConstraint?
    var contentImageHeightConstraint: NSLayoutConstraint?
    var notificationContentTopConstraint: NSLayoutConstraint?
    
    weak var delegate: NotificationViewDelegate?
    
    let panGesture = UIPanGestureRecognizer()
    let tapGesture = UITapGestureRecognizer()
    let swipUpDismiss = UISwipeGestureRecognizer()
    
    var beginDragPointY: CGFloat = 0
    var openNotificationHeight: CGFloat = 0
    var isDismissing = false
    var isImageContent: Bool = false
    var isOpenCanceled: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
        setupLayout()
    }
    
    func initialize(){
        
        panGesture.addTarget(self, action: #selector(panGestureHandler))
        panGesture.cancelsTouchesInView=true;
        swipBarContenairView.addGestureRecognizer(panGesture)
        
        tapGesture.addTarget(self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = true
        notificationContent.addGestureRecognizer(tapGesture)
        
        swipUpDismiss.addTarget(self, action: #selector(swipGestureHandler))
        swipUpDismiss.direction = .up
        
        self.addGestureRecognizer(swipUpDismiss)
        
        addSubview(notificationContent)
        notificationContent.addSubview(thumbnail)
        notificationContent.addSubview(titleLabel)
        notificationContent.addSubview(messageLabel)
        notificationContent.addSubview(swipBarContenairView)
        swipBarContenairView.addSubview(swipBarView)
        notificationContent.addSubview(contentImage)
    }
    
    func setupLayout(){
        
        swipBarTopConstraint = swipBarContenairView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: -20)
        contentImageHeightConstraint = contentImage.heightAnchor.constraint(equalToConstant: 100)
        notificationContentTopConstraint = notificationContent.topAnchor.constraint(equalTo: self.topAnchor, constant: 5)
        NSLayoutConstraint.activate([
            
            notificationContentTopConstraint!,
            notificationContent.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            notificationContent.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            
            thumbnail.topAnchor.constraint(equalTo: notificationContent.topAnchor, constant: 8),
            thumbnail.leftAnchor.constraint(equalTo: notificationContent.leftAnchor, constant: 8),
            thumbnail.widthAnchor.constraint(equalToConstant: 25),
            thumbnail.heightAnchor.constraint(equalToConstant: 25),
            
            titleLabel.centerYAnchor.constraint(equalTo: thumbnail.centerYAnchor),
            titleLabel.leftAnchor.constraint(equalTo: thumbnail.rightAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: notificationContent.rightAnchor, constant: -8),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leftAnchor.constraint(equalTo: notificationContent.leftAnchor, constant: 7),
            messageLabel.rightAnchor.constraint(equalTo: titleLabel.rightAnchor),
            messageLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),
            
            swipBarTopConstraint!,
            swipBarContenairView.centerXAnchor.constraint(equalTo: notificationContent.centerXAnchor),
            swipBarContenairView.heightAnchor.constraint(equalToConstant: 40),
            swipBarContenairView.widthAnchor.constraint(equalTo: notificationContent.widthAnchor),
            
            swipBarView.centerXAnchor.constraint(equalTo: swipBarContenairView.centerXAnchor),
            swipBarView.bottomAnchor.constraint(equalTo: swipBarContenairView.bottomAnchor, constant: -4),
            swipBarView.widthAnchor.constraint(equalToConstant: 130),
            swipBarView.heightAnchor.constraint(equalToConstant: 10),
            
            contentImage.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20 ),
            contentImage.centerXAnchor.constraint(equalTo: notificationContent.centerXAnchor),
            contentImage.widthAnchor.constraint(equalTo: notificationContent.widthAnchor, multiplier: 0.9),
            contentImageHeightConstraint!,
            
            notificationContent.bottomAnchor.constraint(equalTo: swipBarContenairView.bottomAnchor, constant: 0),
            ])
        
    }
    
    @objc func dismissNotification(){
        
        guard isDismissing == false else {return}
        isDismissing = true
        
        notificationContentTopConstraint?.constant = -notificationContent.frame.size.height - 80
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.curveEaseOut, animations: {
            
            self.notificationContent.alpha = 0
            self.layoutIfNeeded()
            
        }) { (animated) in
            self.delegate?.notificationDismissed()
        }
    }
    
    
    func setImageContent(named: String){
        isImageContent = true
        contentImage.isHidden = false
        swipBarContenairView.isHidden=false
        
        if isUrl(urlString: named){
            guard let url = URL(string: named) else {return}
            contentImage.downloadedFrom(url: url)
        } else {
            contentImage.image = UIImage(named: named)
        }
    }
    
    func setImageThumbnail(named: String){
        
        if isUrl(urlString: named){
            guard let url = URL(string: named) else {return}
            thumbnail.downloadedFrom(url: url)
        } else {
            thumbnail.image = UIImage(named: named)
        }
    }
    
    
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if notificationContent.frame.contains(point) == true {
            print("tap real")
            return true
        }
        
        return false
    }
    
    func isUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
    
    func clearMemory(){
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        clearMemory()
        print("free memeory")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//GESTURES
extension NotificationView {
    @objc func panGestureHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        self.layoutIfNeeded()
        swipBarView.isHidden=true
        timer?.invalidate()
        
        if isImageContent && openNotificationHeight == 0 {
            
            let totalHeightRequired = messageLabel.frame.size.height + messageLabel.frame.origin.y + 40 + (self.frame.size.width*0.9)
            if totalHeightRequired > self.frame.size.height {
                
                let photoH = self.frame.size.height - (messageLabel.frame.size.height + messageLabel.frame.origin.y + 80 + 40)
                contentImageHeightConstraint?.constant = photoH
                openNotificationHeight = self.frame.size.height - (messageLabel.frame.size.height + messageLabel.frame.origin.y + 80 + 20 )
                
            } else {
                contentImageHeightConstraint?.constant = self.frame.size.width*0.9
                openNotificationHeight = (self.frame.size.width*0.9) + 20
            }
            
        }
        
        guard let drag = gestureRecognizer.view else {return}
        
        let translation = gestureRecognizer.translation(in: self)
        
        
        if gestureRecognizer.state == .began {
            
            guard drag.frame.origin.y > 0 else {return}
            beginDragPointY = translation.y
            
        } else if ( gestureRecognizer.state == .changed ){
            
            guard drag.frame.origin.y > 0 else {return}
            guard let constant = swipBarTopConstraint?.constant else {return}
            
            if constant + CGFloat(translation.y + beginDragPointY) < -20 {
                isOpenCanceled = true
                panGesture.isEnabled=false
                dismissNotification()
                return
            }else if openNotificationHeight < constant + CGFloat(translation.y + beginDragPointY)  {
                notificationContentTopConstraint?.constant += 0.5
            } else {
                swipBarTopConstraint?.constant += CGFloat(translation.y + beginDragPointY);
            }
            
            colorAlpha += 0.001
            notificationContent.layer.backgroundColor = UIColor(white: 1, alpha: colorAlpha).cgColor
            beginDragPointY = translation.y;
            self.layoutIfNeeded()
        }
            
        else if gestureRecognizer.state == .ended || gestureRecognizer.state == .failed || gestureRecognizer.state == .cancelled {
            
            if !isOpenCanceled {
                panGesture.isEnabled = false
                swipBarView.isHidden=true
                notificationContentTopConstraint?.constant = 5
                
                swipBarTopConstraint?.constant = openNotificationHeight;
                UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.layoutIfNeeded()
                    self.notificationContent.layer.backgroundColor = UIColor(white: 1, alpha: 1).cgColor
                }, completion: nil)
            }
        }
        
        
        gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
    }
    
    @objc func tapGestureHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        clearMemory()
        delegate?.notificationTapped(notification: notification)
        dismissNotification()
    }
    
    @objc func swipGestureHandler(_ gestureRecognizer: UISwipeGestureRecognizer){
        clearMemory()
        dismissNotification()
    }
}



