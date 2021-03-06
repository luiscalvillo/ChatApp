//
//  Download.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/17/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation


let storage = Storage.storage()


// image

func uploadImage(image: UIImage, chatRoomId: String, view: UIView, completion: @escaping (_ imageLink: String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    
    progressHUD.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".jpg"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    
    // convert image into jpeg
    let imageData = image.jpegData(compressionQuality: 0.7)
    
    var task : StorageUploadTask!
    
    task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
        
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            print("Error uploading image \(error?.localizedDescription)")
            
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            guard let downloadUrl = url else {
                completion(nil)
                return
            }
            
            completion(downloadUrl.absoluteString)
        })
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
    }
    
}

func downloadImage(imageUrl: String, completion: @escaping(_ image: UIImage?) -> Void) {
    
    let imageURL = NSURL(string: imageUrl)
    
    print(imageUrl)
    let imageFileName = (imageUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    print(imageFileName)
    
    if fileExistsAtPath(path: imageFileName) {
        // exists
        if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
            completion(contentsOfFile)
        } else {
            print("Couldnt generate image")
            completion(nil)
        }
        
    } else {
        
        // doesnt exist
        
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            let data = NSData(contentsOf: imageURL! as URL)
            
            if data != nil {
                var docURL = getDocumentsURL()
                
                docURL = docURL.appendingPathComponent(imageFileName, isDirectory: false)
                
                // saving locally
                data!.write(to: docURL, atomically: true)
                
                
                let imageToReturn = UIImage(data: data! as Data)
                
                DispatchQueue.main.sync {
                    completion(imageToReturn!)
                }
            } else {
                DispatchQueue.main.async {
                    print("No image in database")
                    completion(nil)
                }
            }
        }
        
    }
    
    
}


// video

func uploadVideo(video: NSData, chatRoomId: String, view: UIView, completion: @escaping(_ videoLink: String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    
    progressHUD.mode = .determinateHorizontalBar
    let dateString = dateFormatter().string(from: Date())
    
    let videoFileName = "VideoMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".mov"
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(videoFileName)
    
    var task : StorageUploadTask!
    
    task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            print("error couldnt upload video \(error!.localizedDescription)")
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            
            guard let downloadUrl = url else {
                completion(nil)
                
                return
            }
            
            completion(downloadUrl.absoluteString)
        })
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)

    }
}


func downloadVideo(videoUrl: String, completion: @escaping(_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
    
    let videoURL = NSURL(string: videoUrl)
    
    let videoFileName = (videoUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    
    if fileExistsAtPath(path: videoFileName) {
        // exists
       completion(true, videoFileName)
        
    } else {
        
        // doesnt exist
        
        let downloadQueue = DispatchQueue(label: "videoDownloadQueue")
        
        downloadQueue.async {
            let data = NSData(contentsOf: videoURL! as URL)
            
            if data != nil {
                var docURL = getDocumentsURL()
                
                docURL = docURL.appendingPathComponent(videoFileName, isDirectory: false)
                
                // saving locally
                data!.write(to: docURL, atomically: true)
                
                
                
                DispatchQueue.main.sync {
                    completion(true, videoFileName)
                }
            } else {
                DispatchQueue.main.async {
                    print("No video in database")
                }
            }
        }
        
    }
    
    
}


// Audio messages

func uploadAudio(audioPath: String, chatRoomId: String, view: UIView, completion: @escaping(_ audioLink: String?) -> Void) {
    
    let progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
    
    progressHUD.mode = .determinateHorizontalBar
    let dateString = dateFormatter().string(from: Date())
    
    let audioFileName = "AudioMessages/" + FUser.currentId() + "/" + chatRoomId + "/" + dateString + ".mov"
    
    let audio = NSData(contentsOfFile: audioPath)
    
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(audioFileName)
    
    var task : StorageUploadTask!
    
    task = storageRef.putData(audio! as Data, metadata: nil, completion: { (metadata, error) in
        task.removeAllObservers()
        progressHUD.hide(animated: true)
        
        if error != nil {
            print("error couldnt upload audio \(error!.localizedDescription)")
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            
            guard let downloadUrl = url else {
                completion(nil)
                
                return
            }
            
            completion(downloadUrl.absoluteString)
        })
    })
    
    task.observe(StorageTaskStatus.progress) { (snapshot) in
        progressHUD.progress = Float((snapshot.progress?.completedUnitCount)!) / Float((snapshot.progress?.totalUnitCount)!)
        
    }
}



func downloadAudio(audioUrl: String, completion: @escaping(_ image: String) -> Void) {
    
    let audioURL = NSURL(string: audioUrl)
    
    let audioFileName = (audioUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    
    if fileExistsAtPath(path: audioFileName) {
        // exists
      
        completion(audioFileName)
        
    } else {
        
        // doesnt exist
        
        let downloadQueue = DispatchQueue(label: "audioDownloadQueue")
        
        downloadQueue.async {
            let data = NSData(contentsOf: audioURL! as URL)
            
            if data != nil {
                var docURL = getDocumentsURL()
                
                docURL = docURL.appendingPathComponent(audioFileName, isDirectory: false)
                
                // saving locally
                data!.write(to: docURL, atomically: true)
                
                
                let imageToReturn = UIImage(data: data! as Data)
                
                DispatchQueue.main.sync {
                    completion(audioFileName)
                }
            } else {
                DispatchQueue.main.async {
                    print("No audio in database")
                }
            }
        }
        
    }
    
    
}





// Helpers


func videoThumbnail(video: NSURL) -> UIImage {
    
    let asset = AVURLAsset(url: video as URL, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTime(seconds: 0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }
    catch let error as NSError {
        print(error.localizedDescription)
    }
    
    let thumbnail = UIImage(cgImage: image!)
    
    return thumbnail
}


func fileInDocumentsDirectory(fileName: String) -> String {
    
    let fileURL = getDocumentsURL().appendingPathComponent(fileName)
    
    return fileURL.path
}

func getDocumentsURL() -> URL {
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    
    return documentURL!
}

// check to see if picture exists on device
func fileExistsAtPath(path: String) -> Bool {
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(fileName: path)
    
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: filePath) {
        doesExist = true
    } else {
        doesExist = false
    }
    
    return doesExist
    
}
