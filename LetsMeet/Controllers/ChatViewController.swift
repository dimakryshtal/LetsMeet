//
//  ChatViewController.swift
//  LetsMeet
//
//  Created by Dima Kryshtal on 19.03.2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import PhotosUI

//MARK: - ChatViewController
class ChatViewController: MessagesViewController {
    
    var chatData: ChatObject = ChatObject(id: "", memberIDs: [])
    var recipientName: String = ""
    let refreshControl = UIRefreshControl()
    let currentUser = MKSender(senderId: User.getCurrentUserID()!, displayName: User.getCurrentUser()!.username)
    
    private var mkmessages: [MKMessage] = []
//    var loadedMessages: [Dictionary<String, Any>] = []
    
    var isTyping = false
    
    
    //MARK: - Listeners
    var messagesListener: ListenerRegistration?
    var typinglistener: ListenerRegistration?
    
    init(chatData: ChatObject, recipientName: String) {
        self.chatData = chatData
        self.recipientName = recipientName
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = recipientName
        
        downloadInitialMessages()
        
        configureMessageInputBar()
        configureMessageCollectionView()
        createTypingListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.removeListeners()
    }

}

//MARK: - Configurations

extension ChatViewController {
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        let button = InputBarButtonItem()
        button.image = UIImage(systemName: "tray.and.arrow.up")
        
        button.setSize(CGSize(width: 30, height: 30), animated: true)
        
        button.onTouchUpInside { item in
            self.present(self.attachAlertController(), animated: true)
        }
        
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    private func configureMessageCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = true
        
        messagesCollectionView.refreshControl = refreshControl
    }
}

//MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    var currentSender: MessageKit.SenderType {
        return currentUser
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        let message = mkmessages[indexPath.section]
        if !isFromCurrentSender(message: message) && message.status == "Sent" {
            FirestoreManager.shared.setMessageStatusToRead(for: chatData.id,
                                                           messageId: message.messageId)
        }
        return message
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return mkmessages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let font = UIFont.boldSystemFont(ofSize: 10)
        let color = UIColor.systemPink
        if indexPath.section == 0 {
            let text = "Pull to load more"
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }else if indexPath.section % 3 == 0 {
            let text = MessageKitDateFormatter.shared.string(from: message.sentDate)
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard isFromCurrentSender(message: message) else { return nil }
        
        let message = mkmessages[indexPath.section]
        
        
        let font = UIFont.boldSystemFont(ofSize: 10)
        let color = UIColor.darkGray
        
        return NSAttributedString(string: message.status, attributes: [.font: font, .foregroundColor: color])
    }
    
    
}
//MARK: - InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != "" {
            typingStarted()
        }
    }
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                sendMessage(text: text, image: nil)
                reloadData()
            }
        }
        messageInputBar.inputTextView.text = ""
    }
}

//MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 18
        }
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 17 : 0
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.set(avatar: Avatar(initials: mkmessages[indexPath.section].senderInitials))
    }
    
}

//MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key : Any] {
        switch detector {
        case .hashtag, .mention:
            return [.foregroundColor: UIColor.blue]
        default:
            return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? MessageDefaults.bubbleColorOutgoing : MessageDefaults.bubbleColorIncoming
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        return .bubbleTail(tail, .curved)
    }
}

//MARK: - MessageCellDelegate
extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Tapped on image message")
    }
}

//MARK: - UIScrollViewDelegate

extension ChatViewController {
    override func scrollViewDidEndDecelerating(_: UIScrollView) {
        if refreshControl.isRefreshing {
            downloadMessages { finished in
                if finished {
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
}

//MARK: - UIAlertController
extension ChatViewController {
    private func attachAlertController() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { action in
            self.showImagePicker()
        }
   
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { action in
            self.showPHPicker(1)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction([takePhotoAction, galleryAction, cancel])
        
        return alert
    }
}

//MARK: - Helpers
extension ChatViewController {
    private func sendMessage(text: String?, image: UIImage?) {
        Task {
            var newMessage = Message.createOutgointMessage(chatRoomId: self.chatData.id,
                                                           text: text,
                                                           image: image)
            
            if let image {
                
                let imageName = UUID().uuidString
                let location = "chatMedia/\(self.chatData.id)/\(imageName).jpeg"
                let error = await FirebaseStorageManager.shared.uploadPictureToFirebase(location: location,
                                                                      userID: User.getCurrentUserID()!,
                                                                      image: image)
                
    
                guard error == nil else { return }
                
                
                newMessage.mediaURL = location
                print(image.size.height, image.size.width)
                newMessage.photoHeight = Int(image.size.height)
                newMessage.photoWidth = Int(image.size.width)
                
                
                
            }
            FirestoreManager.shared.createNewMessage(message: newMessage)
            FirestoreManager.shared.updateChatData(chatToUpdate: chatData, fieldToUpdate: ["lastMessage": text ?? "Picture message",
                                                                                           "lastMessageDate": Date()])
        }
        
    }
    private func downloadInitialMessages() {
        downloadMessages { received in
            if received {
                self.messagesListener = FirestoreManager.shared.listenForMessages(for: self.chatData.id, since: self.mkmessages.last?.sentDate ?? Date(), callbackWhenReceived: { message in
                    self.mkmessages.append(IncomingMessage(messagesCollectionView: self).createMessage(message: message))
                    self.reloadData()
                }, callbackWhenModified: { message in
                    let i = self.mkmessages.firstIndex{ $0.messageId == message.id }
                    self.mkmessages[i!].status = message.status
                    self.reloadData()
                })
            }
        }
    }
    
    private func downloadMessages(completion: ((Bool) -> Void)? = nil) {
        
        FirestoreManager.shared.downloadMessages(for: chatData.id,
                                                 lastDocument: mkmessages.isEmpty ? nil : mkmessages.first?.messageId,
                                                 limit: mkmessages.isEmpty ? 15 : 10) { messages in
            guard let messages else {
                completion?(false)
                return
            }
            self.mkmessages = messages.map{ IncomingMessage(messagesCollectionView: self).createMessage(message: $0)}.reversed() + self.mkmessages
            self.reloadData()
            completion?(true)
        }

    }
    private func reloadData() {
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem()
    }
    
    private func removeListeners() {
        if messagesListener != nil {
            messagesListener!.remove()
        }
        if typinglistener != nil {
            typinglistener!.remove()
        }
    }
}

//MARK: - ImagePicker

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func showImagePicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        
        let imageItem = ImageItem(name: UUID().uuidString, image: image)
        let userID = User.getCurrentUserID()!
        
//        FirebaseStorageManager.shared.uploadPictureToFirebase(location: "images/\(userID)/\(imageItem.name).jpeg",
//                                                              userID: userID,
//                                                              image: imageItem)
    }
}

//MARK: - PHPicker

extension ChatViewController: PHPickerViewControllerDelegate {
    
    func showPHPicker (_ numberOfItems: Int) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = numberOfItems
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard !results.isEmpty else { return }
        let assetId = results.first?.assetIdentifier
        guard let phAsset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId!], options: nil).firstObject else { return }
        
        PHImageManager.default().requestImageDataAndOrientation(for: phAsset, options: nil) { data, _, _, _ in
            guard let data, let image = UIImage(data: data) else {
                print("Could not parse Data to UIImage")
                return
            }
            
            guard var user = User.getCurrentUser() else { return }
            
            self.sendMessage(text: nil, image: image)
            
//            let imageItem = ImageItem(name: UUID().uuidString, image: image)
//            FirebaseStorageManager.shared.uploadPictureToFirebase(location: "chatMedia/\(self.chatData.id)/\(imageItem.name).jpeg",
//                                                                  userID: user.objectId,
//                                                                  image: imageItem)
        }
    }
}

//MARK: - Typing indicator

extension ChatViewController {
    private func createTypingListener() {
        typinglistener = FirestoreManager.shared.createTypingListener(chatId: chatData.id,
                                                                      userId: chatData.memberIDs.first{$0 != User.getCurrentUserID()!}!,
                                                                      callBack: { isTyping in
            self.setTypingIndicatorViewHidden(!isTyping, animated: true) { success in
                if success, self.isLastSectionVisible() {
                    self.messagesCollectionView.scrollToLastItem()
                }
            }
        })
    }
    
    private func isLastSectionVisible() -> Bool {
        guard !mkmessages.isEmpty else {
            return false
        }
        let lastIndexPath = IndexPath(item: 0, section: mkmessages.count - 1)
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    private func typingStarted() {
        isTyping = true
        
        FirestoreManager.shared.updateTypingListener(chatId: chatData.id, userId: User.getCurrentUserID()!, isTyping: isTyping)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.typingStopped()
        }
    }
    
    private func typingStopped() {
        isTyping = false
        
        FirestoreManager.shared.updateTypingListener(chatId: chatData.id, userId: User.getCurrentUserID()!, isTyping: isTyping)
    }
}


