//
//  VBNews.swift
//  VoiceBox
//
//  Created by Dmitry on 30.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Foundation

struct VBNews: Decodable, CustomStringConvertible {
    let title: String
    let description: String
    let url: URL?
    let source: String?
}
