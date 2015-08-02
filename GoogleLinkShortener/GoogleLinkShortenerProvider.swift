import AppKit

class GoogleLinkShortenerProvider: NSObject, NSApplicationDelegate {
    let googleUrl = NSURL(string: "https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyCR2rLi_-twrUnGGhovQ5yailngtoEIZhA")!
    
    func applicationDidFinishLaunching(notification: NSNotification) {
        println("applicationDidFinishLaunching")
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        println("applicationDidBecomeActive")
    }
    
    func showOverlay (urlString: String) {
      
    }
    
    func postToGoogleLinkShorter (url: NSURL) {
        var request = NSMutableURLRequest(URL: googleUrl)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"

        var params = ["longUrl": url.absoluteString!] as Dictionary<String, String>
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    let shortUrl: String = parseJSON["id"] as! String
                    NSPasteboard.generalPasteboard().clearContents()
                    NSPasteboard.generalPasteboard().setString(shortUrl, forType: NSStringPboardType)
                    self.showOverlay(shortUrl)
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
    }
    
    func shortenLinkWithGoogle (pboard: NSPasteboard, userData: NSString, error: NSErrorPointer) {
        if let attrString = pboard.readObjectsForClasses([NSAttributedString.self], options: [:])?.first as? NSAttributedString {            
            let detector = NSDataDetector(types: NSTextCheckingType.Link.rawValue, error: nil)
            var matches = detector!.matchesInString(attrString.string, options: nil, range: NSMakeRange(0, count(attrString.string))) as! [NSTextCheckingResult]
            
            if let _match = matches.first {
                postToGoogleLinkShorter(_match.URL!)
            } else {
                println("there is no link")
            }
        }
    }
}
