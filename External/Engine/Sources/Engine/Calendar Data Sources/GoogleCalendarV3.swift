import SwiftDate
import Alamofire
import struct Foundation.URLRequest
import struct SwiftyJSON.JSON

private enum GoogleApi: URLRequestConvertible {

    /// Retrieve events from user calendar
    /// https://developers.google.com/calendar/v3/reference/events/list
    case events(calid: String, timeMin: DateInRegion, timeMax: DateInRegion)
    
    public func asURLRequest() throws -> URLRequest {
        switch self {
        case .events(let calid, let timeMin, let timeMax):
            let url = try "\(Env.Google.hostUrl)/calendar/v3/calendars/\(calid)/events".asURL()
            let urlRequest = URLRequest(url: url)
            let queryParams = [
                "singleEvents": "true",
                "orderBy": "startTime",
                "timeMin": timeMin.toISO(),
                "timeMax": timeMax.toISO()
            ]
            
            return try URLEncoding.default.encode(urlRequest, with: queryParams)
        }
    }
}

public final class GoogleCalendarV3: CalendarDataSource {
    
    private let calid: String
    private let sessionManager: SessionManager
    
    public init(calid: String, sessionManager: SessionManager = SessionManager.default) {
        self.calid = calid
        self.sessionManager = sessionManager
        
        // Adds oauth support
        if let _ = AuthState.getAccessToken() {
            let handler = OAuthRequestHandler(authState: AuthState.self)
            self.sessionManager.adapter = handler
        }
    }
    
    public func book(service: Service, period: TimePeriod) -> Bool {
        fatalError("Not yet implemented")
    }
    
    /// Returns a list of events from the user's Google calendar
    public func timePeriods(from: DateInRegion,
                            until: DateInRegion,
                            onSuccess: @escaping ([TimePeriod]) -> Void,
                            onFailure: @escaping (Error) -> Void) {
        sessionManager
            .request(GoogleApi.events(calid: calid, timeMin: from, timeMax: until))
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    guard let results = self.asTimePeriods(JSON(value)) else {
                        debugPrint("Unable to parse successful data response.")
                        return
                    }
                    
                    onSuccess(results)
                case .failure(let err):
                    onFailure(err)
                }
        }
    }
    
    /// Converts Google's response into native Swift objects
    private func asTimePeriods(_ json: JSON) -> [TimePeriod]? {
        let calendarEvents = json["items"].arrayValue
        
        let timePeriods = calendarEvents.map { event -> TimePeriod in
            let iso8601Start = event["start"]["dateTime"].string ?? event["start"]["date"].stringValue
            let iso8601End = event["end"]["dateTime"].string ?? event["end"]["date"].stringValue
            
            return TimePeriod(start: DateInRegion(iso8601Start), end: DateInRegion(iso8601End))
        }
        
        return timePeriods
    }
}
