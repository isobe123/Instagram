//
//  PostData.swift
//  Instagram
//
//  Created by be on 2019/06/25.
//  Copyright © 2019年 isobe. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject {      //投稿データ用クラス
    var id: String?             //投稿ID
    var image: UIImage?         //UIImageに変換済み画像
    var imageString: String?    //Base64のままの画像
    var name: String?           //投稿名
    var caption: String?        //キャプション
    var date: Date?             //日付
    var likes: [String] = []    //いいねした人のID配列
    var isLiked: Bool = false   //自分がいいねしたかどうかのフラグ
    var comments: [[String:String]] = []   //コメントと入力者の表示名
    
    //DataSnapshot(Firebaseから追加・変更された投稿データ)を元にPostData(投稿データ用のクラス)を作成、初期化する
    init(snapshot: DataSnapshot, myId: String) {
        self.id = snapshot.key
    
        let valueDictionary = snapshot.value as! [String: Any]
    
        imageString = valueDictionary["image"] as? String
        image = UIImage(data: Data(base64Encoded: imageString!, options: .ignoreUnknownCharacters)!)
        
        self.name = valueDictionary["name"] as? String
        
        self.caption = valueDictionary["caption"] as? String
        
        let time = valueDictionary["time"] as? String
        self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)
        
        if let comments = valueDictionary["comments"] as? [[String:String]]{
            self.comments = comments
        }
        
        if let likes = valueDictionary["likes"] as? [String]{
            self.likes = likes
        }

        for likeId in self.likes{
            if likeId == myId{
                self.isLiked = true
                break
            }
        }
    }
}
