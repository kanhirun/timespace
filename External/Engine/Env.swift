public struct Env {

    /// The shared App Group identifier for storing oauth credentials
    public static let appGroupName = "group.com.domain.vcal.app"
    
    /// OAuth
    public struct Google {
        public static let hostUrl = "https://www.googleapis.com"
        public static let testHostUrl = "https://97866f8d-e3c4-4eab-93a0-6184a903d956.mock.pstmn.io"  // Postman
        
        public static let redirectUrl = "com.googleusercontent.apps.316860074697-ekerp9o8rp710pvapjbbn6t2gt9468qt:/"
        public static let state = ""
        public static let authorizeUrl   = "https://accounts.google.com/o/oauth2/auth"
        public static let accessTokenUrl = "https://accounts.google.com/o/oauth2/token"
        public static let scope          = "https://www.googleapis.com/auth/calendar.events"
        public static let clientId       = "316860074697-ekerp9o8rp710pvapjbbn6t2gt9468qt.apps.googleusercontent.com"
        public static let clientSecret   = ""  // does not need
    }
    
}
