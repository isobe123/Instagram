//
//  HomeViewController.swift
//  Instagram
//
//  Created by be on 2019/06/23.
//  Copyright © 2019年 isobe. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    //PostDataクラスの配列
    var postArray: [PostData] = []
    //DatabaseのobserveEventの登録状態
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        //tableCellのタップを無効にする
        tableView.allowsSelection = false
        
        //PostTableViewCell.xibに作成したセルの定義を取得
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        //Outletで接続したtableViewに登録
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //テーブル行の高さをAutoLayoutで自動調整
        tableView.rowHeight = UITableView.automaticDimension
        //テーブル行の高さの概算値設定
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                //要素が追加されたらpostArrayに追加、tableViewを再表示
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    //PodstDataクラス生成、受け取ったデータを設定
                    if let uid = Auth.auth().currentUser?.uid{
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        //tableView再表示
                        self.tableView.reloadData()
                    }
                })
                //要素が変更されたらpostArrayからデータを削除・新しいデータを追加、tableView再表示
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_Print: .childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        //PostDataクラス生成、受け取ったデータを設定
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        //保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.firstIndex(of: post)!
                                break
                            }
                        }
                        //削除
                        self.postArray.remove(at: index)
                        //削除したところに更新済みデータ追加
                        self.postArray.insert(postData, at: index)
                        //tableVuew再表示
                        self.tableView.reloadData()
                    }
                })
                //DatabaseのobserveEventが上記コードにより登録されたためtrueとする
                observing = true
            }else{
                //ログアウトを検出したら
                if observing == true {
                    //テーブルをクリア
                    postArray = []
                    tableView.reloadData()
                    //オブサーバーを削除
                    let postsRef = Database.database().reference().child(Const.PostPath)
                    postsRef.removeAllObservers()
                    //DatabaseのobserveEventが上記コードにより解除されたためfalseとする
                    observing = false
                }
            }
        }
    }
    
    //セルの数＝配列の数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    //セルの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを取得してデータを設定
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        //セル内のボタンのアクションを設定
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action:#selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)
        return cell
    }

    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        //タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                //すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes{
                    if likeId == uid{
                        //削除するためインデックスを保持
                        index = postData.likes.firstIndex(of: likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            }else{
                postData.likes.append(uid)
            }
            //増えたlikesをFirebaseに保存
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
        }
    }
    
    @objc func handleCommentButton(_ sender: UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT: commentボタンがタップされました。")
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        let postData = postArray[indexPath!.row]
        
        let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "Comment") as! CommentViewController
        commentViewController.postData = postData
        self.present(commentViewController, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

