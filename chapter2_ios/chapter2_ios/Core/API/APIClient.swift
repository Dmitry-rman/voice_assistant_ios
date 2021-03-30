//
//  APIClient.swift
//  VoiceBox
//
//  Created by Dmitry on 29.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Alamofire
import CodableAlamofire
import CocoaLumberjack
import AlamofireRSSParser

enum APIClientResponseResult{
    case success
    case fail
    case errorData
    case noInternetConnection
    case cancelled
}

typealias rssRequestHandler = (APIClientResponseResult, String?, RSSFeed?)->()
typealias dataRequestHandler = (APIClientResponseResult, String?, Dictionary<String, Any>?)->()

public class APIClient {
    
    static let sharedInstance = APIClient()
    
    private var _currentRequest: DataRequest?
    
    func getRSSRequest(route:APIRouter, completion: @escaping (rssRequestHandler)) -> DataRequest?{
        
        let urlRequest = try? route.asURLRequest()
               if urlRequest != nil {
                 if let httpBodyData = urlRequest!.httpBody,
                    let dataString =  String.init(data: httpBodyData, encoding: String.Encoding.utf8){
                    DDLogDebug(dataString)
                 }
               }
        
        _currentRequest =  AF.request(route).responseRSS { (response) in
            if let feed: RSSFeed = response.value {
                 completion(.success, nil, feed)
            }
            else{
                completion(.fail, "Ошибка при выполнении запроса", nil)
            }
        }
        
        return _currentRequest
    }

    func performAPIRequest(route:APIRouter, completion:@escaping dataRequestHandler) -> DataRequest?{
        
        let urlRequest = try? route.asURLRequest()
        if urlRequest != nil {
          if let httpBodyData = urlRequest!.httpBody,
             let dataString =  String.init(data: httpBodyData, encoding: String.Encoding.utf8){
             DDLogDebug(dataString)
          }
        }
        
        _currentRequest = AF.request(route).responseJSON { [weak self] (response) in
            
            switch response.result {
            case .success(let _):
                guard let data = response.data else{
                    completion(.errorData, "Ошибка структуры данных", nil)
                    return
                }
                self?._currentRequest = nil

                if let string = String.init(data: data, encoding: .utf8){
                    if string == "Accepted" {
                        completion(.errorData, "Неизвестная команда", nil)
                        return
                    }
                    
                    let jsonString = string.replacingOccurrences(of: "<[^>]+>|[\\n]", with: "", options: .regularExpression, range: nil)
                    if  let jsonDict = self?.convertToDictionary(text: jsonString){
                          completion(.success, nil, jsonDict)
                    }
                     else{
                        completion(.errorData, "Ошибка парсинга данных", nil)
                    }
                }
                else{
                    completion(.errorData, "Ошибка структуры данных", nil)
                }
                break
            case .failure(let error):
                completion(.fail, error.localizedDescription, nil)
                break
            }
            
        }
        
        return _currentRequest
    }
    
    internal  func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
