# Metrics Endpoint Compatibility Fix

This document outlines the issues and solutions for the metrics endpoint compatibility problems in the Umami iOS app.

## Identified Issues

1. **Parameter Format Inconsistency**: 
   - The app tries both camelCase (`startAt`, `endAt`) and snake_case (`start_at`, `end_at`) parameters, but might not be handling all possible combinations.
   - Some Umami server versions might require specific parameter formats.

2. **Endpoint Path Variations**:
   - Current paths being tried:
     - `/api/websites/{id}/metrics` (standard v2)
     - `/api/website/{id}/metrics` (singular v1)
     - `/api/metrics/{id}` (alternative)
     - `/api/v1/websites/{id}/metrics` (v1 API plural)
     - `/api/v1/website/{id}/metrics` (v1 API singular)
   - Your server might be using a different path format.

3. **Date Parameter Handling**:
   - The app sends dates as Unix timestamps in milliseconds.
   - Some Umami versions might expect different formats (seconds, ISO strings).

4. **Timezone Parameter**:
   - The app sends the local timezone identifier.
   - Some Umami versions might expect a different format or not support this parameter.

5. **Unit Parameter**:
   - The app sends "hour", "day", or "month" based on the selected period.
   - Some Umami versions might use different values or not support this parameter.

6. **Caching Logic**:
   - The app caches successful endpoint formats but might not be clearing the cache properly when needed.

## Comprehensive Solution

### 1. Add More Endpoint Format Variations

Add these additional endpoint formats to try:

- `/api/v2/websites/{id}/metrics`
- `/api/v2/website/{id}/metrics`
- `/api/website/{id}/stats/metrics`
- `/api/websites/{id}/stats/metrics`

### 2. Improve Parameter Format Handling

- Try both with and without the `unit` parameter
- Try both with and without the `timezone` parameter
- Try dates in both milliseconds and seconds formats
- Try ISO date strings instead of timestamps

### 3. Add Debugging Capabilities

- Add a "Reset API Cache" button in the app settings
- Add more detailed logging for API requests and responses
- Add a debug view to show all attempted endpoint formats and their results

### 4. Implement Fallback Mechanism

- If all endpoint formats fail, implement a simplified fallback that requests minimal data
- Consider adding a "compatibility mode" setting that users can enable for problematic servers

### 5. Server Version Detection

- Add more robust server version detection
- Store and use the detected server version to prioritize endpoint formats

## Implementation Steps

1. Update the `tryAlternativeMetricsEndpoints` method to try more endpoint formats
2. Enhance the parameter handling to try more combinations
3. Improve the caching mechanism to better handle failures
4. Add the debugging capabilities
5. Implement the fallback mechanism
6. Enhance server version detection

## Testing

After implementing these changes, test with various Umami server versions:
- Umami v1.x
- Umami v2.x
- Latest Umami version
- Custom Umami forks

## Expected Outcome

With these changes, the app should be able to:
1. Detect and adapt to any Umami server version
2. Use the correct endpoint format for metrics data
3. Provide useful debugging information when issues occur
4. Gracefully handle incompatible servers with fallback mechanisms
