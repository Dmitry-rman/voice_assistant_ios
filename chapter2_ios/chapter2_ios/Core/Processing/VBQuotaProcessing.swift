//
//  VBQuotaProcessing.swift
//  voicebox
//
//  Created by Dmitry on 18.03.2021.
//

import Foundation

class VBQuotaProcessing{
    
    private func processQuoteRequest(completion: (processingMessageHandler?)){
        
        _ = APIClient.sharedInstance.performAPIRequest(route: APIRouter.getQuote, completion: { [weak self] (result, errorMessage, jsonData) in
                       if result == .success {
                           var text = ""
                           if let data = jsonData{
                               text = "\"" + (data["quoteText"] as? String ?? "") + "\""
                               if let author = data["quoteAuthor"] as? String {
                                   text += " " + author + "."
                               }
                           }
                           if let responseData = self?.getResponse(with: .message, payload: text){
                            completion?(responseData, nil)
                           }
                       }
                       else{
                           completion?(nil, "Ошибка запроса афоризма")
                       }
                   })
    }
}

extension VBQuotaProcessing : VBProcessingProtocol{
    
    func processMessage(message: String, userName: String?, completion: (processingMessageHandler?)) -> Bool {
        
        if message.sentenceContainsAny(phrases: "афоризм,цитата,высказывание,фраза,анекдот"){
           self.processQuoteRequest(completion: completion)
           return true
       }
        
        return false
    }
    
}
