import AppKit.NSApplication

NSRegisterServicesProvider(GoogleLinkShortenerProvider(), "Shorten with Google")
NSRunLoop.currentRunLoop().run()
