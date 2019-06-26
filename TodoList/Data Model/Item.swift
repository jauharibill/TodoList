//
//  Item.swift
//  TodoList
//
//  Created by Idris on 26/06/19.
//  Copyright © 2019 IdrisLabs. All rights reserved.
//

import Foundation

class Item:Encodable,Decodable {
    var title:String = ""
    var done:Bool = false
    
}
