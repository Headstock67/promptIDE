/*
 Typography Tokens.
 Layer: App (Design System)
*/

import SwiftUI

public extension Font {
    
    /// The centralized typography accessor.
    static let theme = ThemeFonts()
}

public struct ThemeFonts: Sendable {
    
    // MARK: - Structure
    
    /// Large, bold headers (e.g., Page Titles).
    /// Maps to: Large Title / Title 1
    public let header: Font = .largeTitle.weight(.bold)
    
    /// Section headers or sub-page titles.
    /// Maps to: Headline
    public let sectionHeader: Font = .headline.weight(.semibold)
    
    /// Standard body text.
    /// Maps to: Body
    public let body: Font = .body
    
    /// Small metadata or footnotes.
    /// Maps to: Footer / Caption
    public let caption: Font = .caption
    
    /// Code or Monospaced content (Editor Blocks).
    /// Maps to: Body (Monospaced)
    public let code: Font = .body.monospaced()
    
    /// A slightly larger monospaced font for headings within the editor.
    public let codeHeader: Font = .headline.monospaced()
}
