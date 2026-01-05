/*
 This file defines the PolicyRules model.
 It encapsulates the constraints imposed by an organization's management profile.
 Layer: Domain
*/

import Foundation

/// Defines the restrictions applied by the enterprise environment.
public struct PolicyRules: Equatable, Sendable {
    
    /// Indicates whether the application is currently managed by MDM.
    public let isManaged: Bool
    
    /// If true, the user is prohibited from exporting data.
    public let exportBlocked: Bool
    
    /// A list of terms that are flagged as prohibited within prompts.
    public let forbiddenTerms: [String]
    
    /// The name of the managing organization, if available.
    public let organizationName: String?
    
    /// Initialises a PolicyRules instance.
    public init(
        isManaged: Bool = false,
        exportBlocked: Bool = false,
        forbiddenTerms: [String] = [],
        organizationName: String? = nil
    ) {
        self.isManaged = isManaged
        self.exportBlocked = exportBlocked
        self.forbiddenTerms = forbiddenTerms
        self.organizationName = organizationName
    }
    
    /// A default unmanaged policy implementation.
    public static let standard = PolicyRules(
        isManaged: false,
        exportBlocked: false,
        forbiddenTerms: [],
        organizationName: nil
    )
}
