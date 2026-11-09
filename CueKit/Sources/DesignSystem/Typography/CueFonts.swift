import CoreText
import Foundation

/// Fonts bundled with the design system.
public enum CueFonts {
    /// Bricolage Grotesque ExtraBold (SIL Open Font License), used for titles.
    public static let titlePostScriptName = "BricolageGrotesque-ExtraBold"

    public enum RegistrationError: Error {
        case missingFile
        case rejected(CFError?)
    }

    /// Makes the bundled fonts available to the app. Call once at launch; repeating is harmless.
    public static func register() throws {
        guard let url = Bundle.module.url(forResource: titlePostScriptName, withExtension: "ttf")
        else { throw RegistrationError.missingFile }
        var error: Unmanaged<CFError>?
        if CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) { return }
        let cfError = error?.takeRetainedValue()
        if let cfError, CFErrorGetDomain(cfError) as String == kCTFontManagerErrorDomain as String,
            CFErrorGetCode(cfError) == CTFontManagerError.alreadyRegistered.rawValue
        {
            return
        }
        throw RegistrationError.rejected(cfError)
    }
}
