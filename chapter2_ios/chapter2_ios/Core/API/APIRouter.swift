//
//  APIRouter.swift
//  VoiceBox
//
//  Created by Dmitry on 29.07.2020.
//  Copyright © 2020 Dmitry. All rights reserved.
//

import Alamofire
import CocoaLumberjack

enum APIRouter: URLRequestConvertible {

    case getQuote //Цитата дня
    case getNews //Новости vc.ru
    
    var method: HTTPMethod {
        switch self {
        default:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getQuote:
            return  "http://api.forismatic.com/api/1.0/?method=getQuote&format=json"
        case .getNews:
            return "https://vc.ru/rss/all"
        }

    }
    
    var parameters: Parameters? {
           switch self {
           default:
              return nil
        }
    }
    
    var pathParameters: Parameters?{
    
       let parameters: [String: Any] = [:]
        
        switch self {
        case .getQuote:
            break
        case .getNews:
            break
        }
       return parameters
    }
    
    func asURL() throws -> URL{
        let urlComponents = ELURLComponents(baseUrl: "",
                                             path: path,
                                             queryParameters: pathParameters)
        return urlComponents.url!
    }
    
    // MARK: - URLRequestConvertible
       func asURLRequest() throws -> URLRequest {
     
           let url = try self.asURL()
           DDLogDebug("\(url)")

           var urlRequest = URLRequest(url: url)
           urlRequest.httpMethod = method.rawValue
           
    
           let contentType = "application/json"
           // Common Headers
           switch self {
           default:
               urlRequest.setValue(contentType, forHTTPHeaderField: "Accept")
               urlRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
           }
           urlRequest.setValue("ios", forHTTPHeaderField: "mobile-platform")
           
           let authString: String? = nil
           if authString != nil{
                urlRequest.setValue(authString!, forHTTPHeaderField: "Authorization")
           }
           
           // Parameters
           if let parameters = parameters {
               do {
                   urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
               } catch {
                   throw AFError.parameterEncodingFailed(reason: .jsonEncodingFailed(error: error))
               }
           }
           
           return urlRequest
       }
}
