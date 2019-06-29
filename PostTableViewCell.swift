//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by be on 2019/06/26.
//  Copyright © 2019年 isobe. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var captionLable: UILabel!
    
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setPostData(_ postData: PostData){
        self.postImageView.image = postData.image
        
        self.captionLable.text = "\(postData.name!) : \(postData.caption!)"
        
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLable.text = dateString
        
        var allComment = ""
        for comment in postData.comments {
            let name = comment["name"]
            let message = comment["comment"]
            allComment = "\(name!):\(message!)" + "\n"
        }
        self.commentLable.text = allComment
        
        
        if postData.isLiked{
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        }else{
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
}
