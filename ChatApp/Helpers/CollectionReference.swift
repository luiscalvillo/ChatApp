//
//  CollectionReference.swift
//  ChatApp
//
//  Created by Luis Calvillo on 4/5/19.
//  Copyright © 2019 Luis Calvillo. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Typing
    case Recent
    case Message
    case Group
    case Call
}


func reference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}


