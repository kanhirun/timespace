import Foundation
import Alamofire

// http mocking
let postmanSessionManager: SessionManager = {
    // Set custom postman header that controls mock
    var headers = Alamofire.SessionManager.defaultHTTPHeaders
    headers["x-mock-response-code"] = "200"
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = headers
    
    let res = SessionManager(configuration: config)
    
    return res
}()
