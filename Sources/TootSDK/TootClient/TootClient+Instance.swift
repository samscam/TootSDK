// Created by konstantin on 10/02/2023.
// Copyright (c) 2023. All rights reserved.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension TootClient {
    /// Obtain general information about the server
    func getInstanceInfo() async throws -> Instance {
        let req = HTTPRequestBuilder {
            $0.url = getURL(["api", "v1", "instance"])
            $0.method = .get
        }
        return try await fetch(Instance.self, req)
    }
}
