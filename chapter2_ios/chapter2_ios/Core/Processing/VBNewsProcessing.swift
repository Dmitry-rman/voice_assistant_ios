//
//  VBNewsProcessing.swift
//  voicebox
//
//  Created by Dmitry on 18.03.2021.
//

import Foundation
import AlamofireRSSParser

class VBNewsProcessing{
    
    private var _lastFeed: RSSFeed?

    private func processNewsRequest(completion: (processingMessageHandler?)){
        
        if let feed = _lastFeed, feed.items.count > 0 {
            if let feedItem = feed.items.first{
                let responseData = self.getRSSResponse(feedItem: feedItem, source: feed.title ?? "")
                completion?(responseData, nil)
                feed.items.removeFirst()
                return
            }
        }
  
        _ = APIClient.sharedInstance.getRSSRequest(route: APIRouter.getNews,
                                                   completion: { [weak self] (result, errorMessage, feed) in
                                                    
                              if result == .success {
      
                                if let rssFeed = feed,
                                    let feedItem = rssFeed.items.first,
                                    let responseData = self?.getRSSResponse(feedItem: feedItem, source: rssFeed.title ?? ""){
                                       self?._lastFeed = rssFeed
                                       rssFeed.items.removeFirst()
                                       completion?(responseData, nil)
                                 }
                                else{
                                    completion?(nil, "Ошибка парсинга новостей")
                                }
                              }
                              else{
                                  completion?(nil, "Ошибка запроса новостей")
                              }
                          })
    }
    
    private func getRSSResponse(feedItem: RSSItem, source: String) -> ([String : Any]){
        
        let description = feedItem.itemDescription?.replacingOccurrences(of: "<[^>]+>|[\\n]", with: "", options: .regularExpression, range: nil)
  
        let news = VBNews.init(title: feedItem.title ?? "",
                               description: description ?? "",
                               url: feedItem.link != nil ? URL.init(string: feedItem.link!) : nil,
                               source: feedItem.source)
        
        return ["type" : ResponseTypeEnum.news.rawValue,
                "data" : news]
    }
}

extension VBNewsProcessing : VBProcessingProtocol{
    
    func processMessage(message: String, userName: String?, completion: (processingMessageHandler?)) -> Bool {
        
        if message.sentenceContainsAny(phrases: "новост,новое,vc.ru"){
            self.processNewsRequest(completion: completion)
            return true
        }
        
        return false
    }
}
