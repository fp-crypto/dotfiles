import CoreText
import Foundation

for path in CommandLine.arguments.dropFirst() {
    let url = URL(fileURLWithPath: path)
    var error: Unmanaged<CFError>?
    if CTFontManagerRegisterFontsForURL(url as CFURL, .user, &error) {
        print("registered \(url.lastPathComponent)")
    } else if let err = error?.takeRetainedValue(),
              CFErrorGetCode(err) == CTFontManagerError.alreadyRegistered.rawValue {
        print("already registered \(url.lastPathComponent)")
    } else {
        let msg = error.map { CFErrorCopyDescription($0.takeRetainedValue()) as String } ?? "unknown error"
        print("failed \(url.lastPathComponent): \(msg)")
    }
}
