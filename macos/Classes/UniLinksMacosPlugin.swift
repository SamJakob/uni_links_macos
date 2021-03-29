import Cocoa
import FlutterMacOS

public class UniLinksMacosPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private static var instance: UniLinksMacosPlugin? = nil;

    public static func getInstance() -> UniLinksMacosPlugin? {
        return instance!;
    }
    
    private var initialLink: String?;
    
    private var _latestLink: String?;
    var latestLink: String? {
        set {
            _latestLink = newValue;
            if (_eventSink != nil) {
                _eventSink!(_latestLink);
            }
        }
        get { return _latestLink; }
    }
    
    private var _eventSink: FlutterEventSink?;
    
    public func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([NSUserActivityRestoring]) -> Void) -> Bool {
        
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingUrl = userActivity.webpageURL?.absoluteString
        else {
            return false;
        }
        
        self.latestLink = incomingUrl;
        if (_eventSink == nil) {
            self.initialLink = self.latestLink;
        }
        return true;
        
    }
    
    public func handleEvent(_ event: NSAppleEventDescriptor!, withReplyEvent: NSAppleEventDescriptor!) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue else { return };
        
        self.latestLink = urlString;
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        
        instance = UniLinksMacosPlugin();

        let channel = FlutterMethodChannel(name: "uni_links/messages", binaryMessenger: registrar.messenger);
        registrar.addMethodCallDelegate(instance!, channel: channel);

        let chargingChannel = FlutterEventChannel(name: "uni_links/events", binaryMessenger: registrar.messenger);
        chargingChannel.setStreamHandler(instance!);
        
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
            case "getInitialLink":
                result(self.initialLink);

            default:
                result(FlutterMethodNotImplemented);
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self._eventSink = events;
        return nil;
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self._eventSink = nil;
        return nil;
    }

}
