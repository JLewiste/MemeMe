//
//  Meme.swift
//  MemeMe V1.0
//
//  Created by JohannesLewiste on 8/24/15.
//  Copyright (c) 2015 MohdFirdause. All rights reserved.
//

import UIKit

struct Meme {
    
    var topText: String!
    var bottomText: String!
    var originalImage: UIImage!
    var memeImage: UIImage!
    
    // Initializer
    init(topText: String, bottomText: String, originalImage: UIImage, memeImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.originalImage = originalImage
        self.memeImage = memeImage
    }

}
