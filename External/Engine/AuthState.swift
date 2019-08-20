import class Foundation.UserDefaults

public struct AuthState {
    private static let defaults = UserDefaults(suiteName: Env.appGroupName)
    private static let kAccessToken = "accessToken"
    private static let kRefreshToken = "refreshToken"
    
    public static func getAccessToken() -> String? {
        let token = defaults?.object(forKey: kAccessToken) as? String
        return token
    }
    
    public static func setAccessToken(_ str: String) {
        defaults?.setValue(str, forKey: kAccessToken)
    }
    
    public static func getRefreshToken() -> String? {
        let token = defaults?.object(forKey: kRefreshToken) as? String
        return token
    }
    
    public static func setRefreshToken(_ str: String) {
        defaults?.setValue(str, forKey: kRefreshToken)
    }
}
