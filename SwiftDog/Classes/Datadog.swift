

public class Datadog: API {
    
    internal static var base_url: String = "api.datadoghq.com/api/v1/"
    internal static var interval_seconds: TimeInterval = TimeInterval(10)
    public static var metric: Metric = Metric.metric
    public static var event: Event = Event.event
    private static var timer: Timer = Timer()
    internal static let host = UIDevice.current.identifierForVendor!.uuidString
    internal static let model = UIDevice.current.model
    internal static var use_agent = false
    internal static var auth:DatadogAuthentication? = nil
    
    @objc private static func sendData() {
        print("Sending metrics to the Datadog API.")
        if use_agent {
            IOSAgent.send_agent_metrics()
        }
        do {
            try self.metric._send_data(url: base_url) { (error: Error?) in
                print(error!)
            }
            try self.event._send_data(url: base_url) { (error: Error?) in
                print(error!)
            }
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
    
    public static func initialize_api(with agent:Bool=false, default_tags:Bool=false) {
        self.auth = DatadogAuthentication()
        self.use_agent = agent
        if default_tags {
            self.metric.addTags(tags: ["agent:ios", "model:\(IOSAgent.modelIdentifier())"])
            self.event.addTags(tags: ["agent:ios", "model:\(IOSAgent.modelIdentifier())"])
        }
        self.timer = Timer.scheduledTimer(timeInterval: self.interval_seconds, target: self, selector: #selector(Datadog.sendData), userInfo: nil, repeats: true)
    }
    
    public static func resetCredentials() {
        if self.auth != nil {
            self.auth!.resetCredentials()
        }
    }
    
    
}
