import Alamofire
import Foundation

class OAuthRequestHandler: RequestAdapter {
    
    private let authState: AuthState.Type
    
    init(authState: AuthState.Type) {
        self.authState = authState
    }
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        guard let token = authState.getAccessToken() else {
            return urlRequest
        }

        var urlRequest = urlRequest
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }
}
