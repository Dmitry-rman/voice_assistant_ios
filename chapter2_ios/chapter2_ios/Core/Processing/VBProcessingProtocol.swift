//
//  VBProcessingProtocol.swift
//  voicebox
//
//  Created by Dmitry on 17.03.2021.
//

import Foundation

typealias processingMessageHandler = (_ responseData:[String : Any]?,_ errorMesage: String?) -> ()
protocol VBProcessingProtocol {
    func processMessage(message: String, userName: String?, completion: (processingMessageHandler?))->Bool
    func getResponse(with type: ResponseTypeEnum, payload: Any) -> ([String : Any])
}

extension VBProcessingProtocol{
    func getResponse(with type: ResponseTypeEnum, payload: Any) -> ([String : Any]){
        return ["type" : ResponseTypeEnum.message.rawValue, "data" : payload]
    }
}
