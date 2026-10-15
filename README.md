# privacy-dashboard-iOS

The iGrant.io privacy dashboard SDK for iOS (Swift Package, iOS 15 or later).

## Installation

Add the package in Xcode (File > Add Package Dependencies) or in `Package.swift`:

```swift
.package(url: "https://github.com/L3-iGrant/privacy-dashboard-ios", from: "<version>")
```

## Authentication: token provider

The SDK acts for the user that your app has logged in. The SDK has no login
screen, and your app does not need OAuth 2.0 or OpenID Connect.

```
Your app ── "privacy dashboard token" ──► Your backend            (your own session)
Your backend ── POST /v3/service/individual/token ──► iGrant.io API
              Authorization: Bearer <API key with scope individual-token:issue>
iGrant.io API ── { access_token, expires_in } ──► Your backend ──► Your app ──► SDK
SDK ── Authorization: Bearer <access_token> ──► iGrant.io API
```

1. Your backend gets a token for the individual of the logged-in user. Take
   the individual from your login session. Do not use an ID that the app sends.
   The API key stays on your backend. Do not put an API key into the app.
2. Your app gives the token to the SDK through the token provider.

```swift
import PrivacyDashboardiOS

PrivacyDashboard.configure(baseUrl: "https://api.igrant.io/v2", organisationId: orgId) { completion in
    myBackend.privacyDashboardToken { result in   // Result<String, Error>
        completion(result)
    }
}

PrivacyDashboard.showPrivacyDashboard(turnOnAskme: true, turnOnUserRequest: true, turnOnAttributeDetail: true)
```

With async/await:

```swift
PrivacyDashboard.configure(baseUrl: "https://api.igrant.io/v2", organisationId: orgId) {
    try await myBackend.privacyDashboardToken()
}
```

Behaviour of the SDK:

- The SDK calls the token provider on the main queue before its first API
  request, when the token is less than 60 seconds from expiry (the SDK reads
  `exp` from the token, without a signature check), and one time after the API
  refuses the token (HTTP 401). After a 401 the SDK sends the request again one
  time only.
- The token is kept in memory only.
- The SDK sends `Authorization: Bearer <token>` and no
  `X-ConsentBB-IndividualId` header.
- The token is valid for 10 minutes. Your backend can ask for a new token each
  time the provider is called.

When the user logs out, call:

```swift
PrivacyDashboard.reset()
```

`reset()` deletes the token, the token provider and the Keychain items of the SDK.

## Other functions

These functions work after `configure(baseUrl:organisationId:tokenProvider:)`:

- `PrivacyDashboard.showDataSharingUI(dataAgreementId:organisationName:organisationLogoImageUrl:termsOfServiceText:termsOfServiceUrl:cancelButtonText:)`
- `PrivacyDashboard.updateDataAgreementStatus(dataAgreementId:status:)`
- `PrivacyDashboard.readDataAgreementRecordApi(dataAgreementId:completionBlock:)`
- `PrivacyDashboard.readDataAgreementApi(dataAgreementId:completionBlock:)`
- `PrivacyDashboard.showDataAgreementPolicy(dataAgreementDic:viewMode:)`

Set `PrivacyDashboard.receiveDataBackFromPrivacyDashboard` to get the results.

## Logging

Debug logging is off by default. To turn it on during development:

```swift
PrivacyDashboard.isLoggingEnabled = true
```

The messages go to the unified log (subsystem `io.igrant.PrivacyDashboardiOS`)
as private values.

## Deprecated: API key in the app

The entry points with an API key and a user ID still work, but they are
deprecated and log one warning:

- `showPrivacyDashboard(withApiKey:withUserId:withOrgId:withBaseUrl:...)`
- `showDataSharingUI(apiKey:userId:...)`
- `configure(withApiKey:withUserId:withOrgId:withBaseUrl:withLocale:accessToken:)`

The admin functions `createAnIndividual`, `readAnIndividual`,
`updateAnIndividual`, `deleteAnIndividual` and `fetchAllIndividuals` are also
deprecated. Call these operations from your backend. An API key in an app can
be extracted and lets anyone act as any individual of your organisation.
They will be removed in a later major version.

## Tests

```sh
xcodebuild test -scheme PrivacyDashboardiOS -destination 'platform=iOS Simulator,name=iPhone 16'
```
