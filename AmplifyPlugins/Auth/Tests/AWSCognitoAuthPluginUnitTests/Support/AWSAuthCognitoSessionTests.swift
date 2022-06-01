//
//  AWSAuthCognitoSessionTests.swift
//  
//
//  Created by Singh, Harshdeep on 2022-04-28.
//

@testable import AWSCognitoAuthPlugin
import AWSPluginsCore
import CryptoKit
import XCTest

class AWSAuthCognitoSessionTests: XCTestCase {

    /// Given: a JWT token
    /// When: expiring in 2 mins
    /// Then: method should return the correct state
    func testExpiringTokens() {

        let tokenData = [
            "sub": "1234567890",
            "name": "John Doe",
            "iat": "1516239022",
            "exp": String(Date(timeIntervalSinceNow: 121).timeIntervalSince1970)
        ]

        let tokens = AWSCognitoUserPoolTokens(idToken: CognitoAuthTestHelper.buildToken(for: tokenData),
                                              accessToken: CognitoAuthTestHelper.buildToken(for: tokenData),
                                              refreshToken: "refreshToken",
                                              expiresIn: 121)

        let session = AWSAuthCognitoSession.testData.copySessionByUpdating(cognitoTokensResult: .success(tokens))
        let cognitoTokens = try! session.getCognitoTokens().get()
        XCTAssertTrue(cognitoTokens.areTokensExpiring(in: 120))
        XCTAssertFalse(cognitoTokens.areTokensExpiring(in: 122))
        XCTAssertTrue(cognitoTokens.areTokensExpiring())
    }

    /// Given: a JWT token
    /// When: that has expired
    /// Then: method should return the correct state
    func testExpiredTokens() {

        let tokenData = [
            "sub": "1234567890",
            "name": "John Doe",
            "iat": "1516239022",
            "exp": String(Date(timeIntervalSinceNow: 1).timeIntervalSince1970)
        ]

        let tokens = AWSCognitoUserPoolTokens(idToken: CognitoAuthTestHelper.buildToken(for: tokenData),
                                              accessToken: CognitoAuthTestHelper.buildToken(for: tokenData),
                                              refreshToken: "refreshToken",
                                              expiresIn: 121)

        let session = AWSAuthCognitoSession.testData.copySessionByUpdating(cognitoTokensResult: .success(tokens))

        let cognitoTokens = try! session.getCognitoTokens().get()
        XCTAssertTrue(cognitoTokens.areTokensExpiring())
    }

}
