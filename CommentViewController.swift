//
//  CommentViewController.swift
//  Instagram
//
//  Created by be on 2019/06/28.
//  Copyright © 2019年 isobe. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD

class CommentViewController: UIViewController {
    
    var postData: PostData!
    
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func postComment(_ sender: Any) {
        //[コメント者名：コメント]をpostDataのcomments[]に追加
        let comment = ["name":Auth.auth().currentUser!.displayName!,"comment":textView.text!]
        postData.comments.append(comment)
        //Firebaseの保存場所を指定、追加したcommentをFirebaseに保存
        let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
        let comments = ["comments":postData.comments]
        postRef.updateChildValues(comments)
        
        SVProgressHUD.showSuccess(withStatus: "投稿しました。")
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.layer.borderColor = UIColor.orange.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
    }
}
