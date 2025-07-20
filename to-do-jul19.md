I've temporarily commented out the problematic sections that were trying to access non-existent properties on the WebsiteViewModel. The compilation errors should now be resolved.

Current Status:

✅ Top Pages section - Working correctly using websiteMetrics with proper mapping
⏸️ Other metric sections - Temporarily commented out until proper implementation
The Issue: The current architecture has a single websiteMetrics property that contains data for one metric type at a time (based on the type parameter when fetching). However, the UI was designed expecting separate properties for each metric type.

Next Steps (if you want to restore these sections): You have two options:

Add separate properties to WebsiteViewModel:
swift
@Published var websiteReferrers: [MetricItem]?
@Published var websiteBrowsers: [MetricItem]?
@Published var websiteDevices: [MetricItem]?
@Published var websiteCountries: [MetricItem]?
Or modify the approach to fetch different metric types sequentially and update the UI accordingly.
For now, your app should compile successfully with the Top Pages section working correctly. The other metric sections are commented out and won't cause compilation errors.

Would you like me to help implement one of these approaches to restore the other metric sections?