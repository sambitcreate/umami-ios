# ASC CLI Activity Log

Date: 2026-02-06 (local)
Repo: `/Users/sambitbiswas/projects/umami-ios`

## Scope

This file records all significant ASC CLI actions executed for this app during the session, including failed attempts, blockers, and final successful submission for TestFlight external beta review.

## App and Build Identifiers

- App ID: `6744766156`
- App name: `Umami Analytics Internal`
- Bundle ID: `sbtbiswas.Umami-Analytics`
- Version ID: `74b07cb2-f699-48fa-8743-1bb1816d8d00` (version `1.0`)
- Previous build (rejected): `07b2794c-53ed-4199-858a-f19a18f4b22a` (build `2`)
- New build uploaded in this session: `ac891d0b-6dcb-4dde-8a1c-274f13cc0238` (build `3`)

## Skills Used

- `asc-cli-usage`
- `asc-id-resolver`
- `asc-submission-health`
- `asc-testflight-orchestration`
- `asc-release-flow`
- `asc-metadata-sync`
- `asc-xcode-build`

## Authentication and Discovery

1. Confirmed `asc` installation and CLI capability.
2. Detected no active ASC auth profile in keychain/config for this shell.
3. Resolved environment credentials and authenticated using:
   - `ASC_KEY_ID=C95435H9Q8`
   - `ASC_ISSUER_ID=bdc058d7-227e-43e2-bd54-113882fbcc8a`
   - `ASC_PRIVATE_KEY_PATH=/Users/sambitbiswas/.asc/keys/AuthKey_C95435H9Q8.p8`
4. Confirmed app resolution via bundle ID.

## Initial Status Checks

1. Checked App Store version and submission status:
   - Version `1.0` state: `PREPARE_FOR_SUBMISSION`
   - No active App Store review submission found.
2. Checked builds:
   - Build `2` was `VALID`.
3. Verified iOS app icon setup:
   - `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon`
   - `AppIcon.appiconset` exists with 1024x1024 assets.

## App Store Submission Attempt (later superseded)

1. Applied reviewer note to:
   - TestFlight What to Test for build `2`
   - App Store review notes for version `1.0`
2. Attached build `2` to version `1.0`.
3. `asc submit create` failed:
   - `appStoreVersions ... is not in valid state`
4. Preflight checks found blockers for App Store flow:
   - No App Store screenshots uploaded.
   - Version localization content incomplete.
5. This path was stopped after request changed to TestFlight external beta only.

## Switched to TestFlight External Beta Flow

1. Checked existing beta review state for build `2`:
   - `betaReviewState = REJECTED`
   - `submittedDate = 2026-02-05T22:41:00-08:00`
2. Updated TestFlight beta review details with reviewer notes.
3. Re-submit of build `2` failed with API validation:
   - `Build is not in internal testing state`
4. Checked build/group state:
   - Internal build state reported `IN_BETA_TESTING`
   - External state `BETA_REJECTED`
   - Could not recover build `2` into a re-submittable external state.

## New Build Creation and Upload

1. Bumped `CURRENT_PROJECT_VERSION` to `3` in:
   - `Umami Analytics.xcodeproj/project.pbxproj`
2. Built and exported IPA:
   - `xcodebuild clean archive ...`
   - `xcodebuild -exportArchive ...`
   - IPA output: `/tmp/UmamiAnalyticsExport/Umami Analytics.ipa`
3. Upload attempted with `--test-notes --locale` hit ASC CLI/API locale filter issue.
4. Verified upload still succeeded:
   - New build `3` exists and is `VALID`.

## Compliance and Beta Submission for Build 3

1. Found blocker on new build beta detail:
   - `internalBuildState = MISSING_EXPORT_COMPLIANCE`
   - `externalBuildState = MISSING_EXPORT_COMPLIANCE`
2. Created and assigned encryption declaration:
   - Declaration ID: `1d11861d-921a-4dce-93aa-3abaefb8b7a4`
   - Assigned to build: `ac891d0b-6dcb-4dde-8a1c-274f13cc0238`
3. Confirmed state transition:
   - `internalBuildState = READY_FOR_BETA_TESTING`
   - `externalBuildState = READY_FOR_BETA_SUBMISSION`
4. Set What to Test note on build `3` (en-US).
5. Added build `3` to external groups:
   - `dfa36026-183e-4688-aabf-b0e5fec0a71b` (`Testers`)
   - `ab74a76b-06ab-44e3-a984-59cb0e8e21e9` (`Ext`)
6. Submitted build `3` for beta app review:
   - Result: `betaReviewState = WAITING_FOR_REVIEW`
   - `submittedDate = 2026-02-06T18:05:28-08:00`
   - Build beta detail after submit:
     - `internalBuildState = IN_BETA_TESTING`
     - `externalBuildState = WAITING_FOR_BETA_REVIEW`

## Reviewer Note Used

The exact reviewer note used for TestFlight review details and What to Test:

`I've created a website and an API key for the reviewer to test the app with.  API KEY=api_nP47CiJ6mSyEtBQ3krN3w2BmrowBD4sA. Paste this to log into the app and test features.`

## Final Outcome

External TestFlight beta review submission is active for build `3` and is currently waiting for Apple beta review.
