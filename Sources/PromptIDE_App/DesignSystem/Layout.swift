/*
 Layout constants for the Design System.
 Layer: App (Design System)
*/

import Foundation

public struct Layout {
    
    /// Spacing constants based on a 4pt grid.
    public struct Spacing {
        /// 4pt
        public static let small: CGFloat = 4
        /// 8pt
        public static let standard: CGFloat = 8
        /// 16pt
        public static let medium: CGFloat = 16
        /// 24pt
        public static let large: CGFloat = 24
        /// 32pt
        public static let extraLarge: CGFloat = 32
    }
    
    /// Corner radius constants.
    public struct Radius {
        /// 4pt - Subtle inputs
        public static let small: CGFloat = 4
        /// 8pt - Standard buttons
        public static let standard: CGFloat = 8
        /// 12pt - Cards and Modals
        public static let card: CGFloat = 12
        /// 999pt - Capsules and Lozenges
        public static let capsule: CGFloat = 999
    }
}
