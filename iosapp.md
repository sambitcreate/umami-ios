Building an iOS Application for Self-Hosted Umami Analytics

1. Introduction to Umami and iOS Integration:

Umami presents itself as an open-source web analytics tool that prioritizes user privacy, offering a compelling alternative to more traditional solutions like Google Analytics.[1] This platform provides essential insights into website traffic, user behavior, and overall performance. A key aspect of Umami is its design as a lightweight application that can be self-hosted, granting users complete control over their collected data.[1] Unlike many conventional analytics platforms, Umami does not rely on cookies for tracking and anonymizes all collected data, aligning with GDPR and PECR compliance standards without the necessity of cookie consent banners.[1, 2] The core functionalities of Umami include the ability to track page views, identify unique visitors, monitor user sessions, and record custom events, alongside providing metrics on visitor demographics such as browser, operating system, and geographical location.[1, 3] The emphasis on privacy and the self-hosting option are significant advantages for individuals and organizations seeking greater data ownership and adherence to privacy regulations.

Developing an iOS application to consume data from a self-hosted Umami instance offers several benefits. It provides users with a direct and convenient method to access their website analytics data through a dedicated mobile interface, eliminating the need to navigate through a web browser and log into the Umami dashboard.[1] This native application can be specifically designed to present key performance indicators and reports in a format optimized for mobile viewing, potentially incorporating platform-specific visualizations or concise summaries tailored to the user's immediate informational needs. Furthermore, a dedicated iOS application can enhance the overall user experience by offering a more streamlined and focused environment for monitoring website analytics compared to accessing a web dashboard on a mobile device.[1]

This report aims to serve as a comprehensive guide for iOS developers looking to integrate their applications with a self-hosted Umami analytics instance. It will cover the essential steps involved in this integration, starting with an exploration of the Umami API, followed by a detailed explanation of the authentication process required for self-hosted deployments. The report will then provide guidance on making HTTP requests from an iOS application using Swift's URLSession framework, along with instructions on how to identify and utilize the specific API endpoints that provide the desired analytics data. Furthermore, it will explain how to parse the data returned by the Umami API, which is typically in JSON format, using Swift's built-in capabilities. Finally, the report will address critical security considerations for storing and handling API keys or authentication tokens within an iOS application to ensure the integrity and confidentiality of the user's Umami data.

2. Exploring the Umami API Landscape:

The initial step in building an iOS application to interact with a self-hosted Umami instance involves understanding the capabilities and structure of the Umami API. The user provided a link to the Umami GitHub repository.[4] However, this link was inaccessible during the research phase. Despite this, the provision of the GitHub link by the user suggests an awareness of Umami's open-source nature and the potential for the repository to contain valuable information regarding the API, possibly within the source code itself or in related documentation files that might reside in different branches or directories than the specific tree indicated by the provided link.

Online searches for official Umami API documentation revealed that the primary source of information is the official Umami documentation website, located at umami.is/docs.[1] This documentation serves as a central hub for developers seeking to understand and utilize the Umami API. It provides comprehensive details on various aspects of API interaction, including the methods for authentication, the process of sending tracking statistics, and specific information about the different API endpoints available for data retrieval and management.[5, 6] A crucial distinction made within the documentation is between self-hosted Umami instances and the Umami Cloud service. For self-hosted deployments, the standard base URL for accessing the API endpoints is typically http://<your-umami-instance>/api. If the self-hosted Umami instance is configured to use HTTPS, then the base URL would correspondingly be https://<your-umami-instance>/api.[5] In contrast, for users of the Umami Cloud service, the base URL for API interactions is https://api.umami.is/v1, and authentication is handled through the use of an API key that must be included in the request headers, specifically via the x-umami-api-key header.[5, 7] Regardless of whether Umami is self-hosted or accessed via the cloud, the API consistently returns data in JSON format, a standard and widely supported data interchange format.[5, 6] Furthermore, the Umami project provides an API client that is built using TypeScript.[8, 9] Although this client is not directly usable in an iOS application written in Swift, it can serve as a valuable resource for developers to understand the available API endpoints, the parameters they expect, and the structure of the responses they return. This client requires configuration through environment variables, which include either API keys (for Umami Cloud) or user credentials (for self-hosted instances), along with the specific API endpoint URL.

Based on the official documentation, the fundamental structure of the base URL for a self-hosted Umami API is http://<your-umami-instance>/api or https://<your-umami-instance>/api, depending on the protocol (HTTP or HTTPS) used to serve the Umami instance.[5] The placeholder <your-umami-instance> must be replaced with the actual domain name or IP address where the user has deployed their self-hosted Umami installation. For instance, if a user has Umami running on the domain my-analytics.com, the base URL for the API would be http://my-analytics.com/api or https://my-analytics.com/api. This base URL serves as the prefix for all subsequent API endpoint paths, such as /auth/login for authentication or /websites for retrieving website information. Understanding this base URL structure is a prerequisite for any interaction with the Umami API. The user needs to have this specific URL readily available to configure their iOS application correctly. Without knowing the exact location of their self-hosted Umami instance, the application will be unable to establish a connection and retrieve analytics data.

3. Authentication with the Self-Hosted Umami API:

For a self-hosted installation of Umami, accessing the analytics data through its API typically requires authentication to ensure that only authorized users can retrieve sensitive information. The standard method for authentication in this scenario involves a username and password-based login process, facilitated by a specific API endpoint.[5, 10] To gain access, the iOS application needs to send a POST request to the /api/auth/login endpoint of the Umami instance. This endpoint is specifically designed to handle authentication requests by verifying the provided credentials against the user accounts managed by the Umami application.[5, 10] The body of this POST request must be formatted as JSON and should contain two key-value pairs: "username" with the user's Umami login username as its value, and "password" with the corresponding password.[10]

To initiate the authentication process and obtain an access token, the iOS application should follow these steps: First, it must construct a POST request targeting the /api/auth/login endpoint of the user's self-hosted Umami instance. For example, if the Umami instance is accessible at http://your-umami-domain.com, the login endpoint URL would be http://your-umami-domain.com/api/auth/login. Next, the application needs to set the Content-Type header of this request to application/json, indicating that the request body will be in JSON format. Following this, a JSON body containing the user's Umami username and password should be created. This JSON object should have the structure {"username": "your-username", "password": "your-password"}, where "your-username" and "your-password" are replaced with the actual credentials. This JSON object is then set as the HTTP body of the POST request. The application then uses Swift's URLSession to send this constructed POST request to the Umami server. If the provided username and password are correct and the authentication is successful, the Umami API will respond with a JSON payload that includes an authentication token. This token is typically found within a field named token in the JSON response, and the response may also contain other user-related information.[10] This authentication token is essential for all subsequent API requests that require authorized access to data. It's worth noting that while default credentials like admin/umami might exist upon initial setup of a self-hosted Umami instance, it is strongly recommended to change these immediately for security reasons.[11, 12, 13, 14, 15, 16, 17]

Once the authentication token is successfully retrieved from the /api/auth/login endpoint, it must be included in the headers of all subsequent API requests made to the Umami server that require authentication.[10] This is achieved by adding an Authorization header to the URLRequest object before making the API call. The value of this Authorization header should adhere to the Bearer <token> scheme. In this format, <token> is the actual authentication token string received in the response from the login request.[10, 18] For example, if the authentication token obtained is eyTMjU2IiwiY...4Q0JDLUhWxnIjoiUE_A, the Authorization header in subsequent requests should be set as Authorization: Bearer eyTMjU2IiwiY...4Q0JDLUhWxnIjoiUE_A. The Umami API expects this Authorization header with the Bearer token for any operation that requires user permissions, such as retrieving website statistics or managing user accounts. Therefore, the iOS application must ensure that this header is correctly formatted and included in all relevant API calls made after the initial authentication.

4. Making HTTP Requests in iOS using Swift's URLSession:

In the iOS environment, the primary framework for performing network-related tasks, including making HTTP requests to backend APIs like Umami, is URLSession.[19, 20, 21] This framework provides a comprehensive set of APIs that allow applications to transfer data over a network using various protocols. URLSession supports a wide range of HTTP methods, such as GET, POST, PUT, and DELETE, which are essential for interacting with RESTful APIs like the one offered by Umami. When making network requests, URLSession offers the flexibility of both synchronous and asynchronous operations. However, for the vast majority of use cases in iOS application development, especially when dealing with potentially long-running network operations, the asynchronous approach is strongly recommended. Asynchronous requests prevent the main thread of the application from being blocked, ensuring that the user interface remains responsive and the application continues to function smoothly while waiting for the server to process the request and send back a response.

To initiate communication with the Umami API, the iOS application first needs to construct a URL object that represents the specific API endpoint it intends to call. This URL object is typically created from a string representation of the URL.[19, 20, 22] Once the URL is established, a URLRequest object is created. This object acts as a container that encapsulates all the necessary details of the network request, including the target URL, the specific HTTP method to be used (e.g., GET or POST), any headers that need to be sent along with the request, and the body of the request if required (as in the case of POST or PUT requests).[19, 20, 22, 23] Below is an example in Swift demonstrating how to create a URL object for the Umami websites endpoint and then use it to initialize a basic URLRequest:
Swift

import Foundation

guard let url = URL(string: "http://your-umami-domain.com/api/websites") else {
    // Handle the scenario where the provided URL string is invalid
    print("Error: Invalid URL")
    return
}
var request = URLRequest(url: url)

It is crucial to handle the possibility of an invalid URL string during the creation of the URL object. If the string is malformed or does not represent a valid URL, the URL(string:) initializer will return nil, and the application should gracefully handle this situation, perhaps by logging an error or informing the user.

To illustrate the process of making API calls, here are Swift code examples for both GET and POST requests that would be relevant when interacting with a self-hosted Umami instance. The GET request example demonstrates how to fetch a list of websites being tracked by Umami, while the POST request example shows how to perform the initial login to obtain an authentication token.

GET Request Example (Fetching Website List):
Swift

request.httpMethod = "GET"
request.addValue("application/json", forHTTPHeaderField: "Accept")
request.addValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization") // Assuming 'authToken' holds the authentication token

URLSession.shared.dataTask(with: request) { data, response, error in
    if let error = error {
        print("Error fetching website list: \(error)")
        return
    }
    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        print("Error: Invalid HTTP response code")
        return
    }
    guard let data = data else {
        print("Error: No data received")
        return
    }

    do {
        if let json = try JSONSerialization.jsonObject(with: data, options:) as?] {
            print("Website list: \(json)")
            // Process the retrieved website data
        } else {
            print("Error: Could not parse response as JSON array")
        }
    } catch {
        print("Error parsing JSON: \(error)")
    }
}.resume()

In this GET request, the httpMethod of the URLRequest is set to "GET". Two important headers are added: Accept is set to application/json, indicating that the client expects the response to be in JSON format, and Authorization is set to Bearer \(authToken), where authToken is the authentication token obtained from the login process. The URLSession.shared.dataTask(with:completionHandler:) method is used to create and initiate the network request. The completion handler is a closure that will be executed when the request completes. It checks for any errors, verifies the HTTP response status code to ensure it's within the successful range (200-299), and then attempts to parse the received data as a JSON array.

POST Request Example (Logging In):
Swift

guard let loginUrl = URL(string: "http://your-umami-domain.com/api/auth/login") else {
    print("Error: Invalid login URL")
    return
}
var loginRequest = URLRequest(url: loginUrl)
loginRequest.httpMethod = "POST"
loginRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

let loginBody: = ["username": "your-username", "password": "your-password"]
do {
    loginRequest.httpBody = try JSONSerialization.data(withJSONObject: loginBody)
} catch {
    print("Error creating JSON body: \(error)")
    return
}

URLSession.shared.dataTask(with: loginRequest) { data, response, error in
    if let error = error {
        print("Error logging in: \(error)")
        return
    }
    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        print("Error: Login failed with status code: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
        return
    }
    guard let data = data else {
        print("Error: No data received after login")
        return
    }

    do {
        if let json = try JSONSerialization.jsonObject(with: data, options:) as?, let token = json["token"] as? String {
            print("Login successful, received token: \(token)")
            // Store the authentication token securely
            authToken = token
        } else {
            print("Error: Could not parse login response as JSON or token not found")
        }
    } catch {
        print("Error parsing login JSON: \(error)")
    }
}.resume()

In this POST request for login, the httpMethod is set to "POST". The Content-Type header is set to application/json to indicate that the request body will be a JSON object. A dictionary containing the username and password is created and then serialized into JSON data using JSONSerialization.data(withJSONObject:), which is set as the httpBody of the request. Similar to the GET request, a dataTask is created and resumed. The completion handler checks for errors, validates the HTTP status code, and then attempts to parse the response as a JSON object, looking specifically for the authentication token in the "token" field. If successful, the token is extracted and can be stored for use in subsequent authenticated requests.

Request headers play a crucial role in communicating with APIs, providing additional information about the request to the server. They are set on the URLRequest object using the addValue(_:forHTTPHeaderField:) method.[19, 20, 21, 24, 25] As seen in the examples, common headers include Content-Type, which specifies the format of the data being sent in the request body (e.g., application/json), and Accept, which indicates the format that the client prefers for the response from the server (also often application/json). For authenticated requests to the Umami API, after a successful login, the Authorization header with the Bearer scheme is essential. This header informs the server that the client has been authenticated and is authorized to access protected resources. The value of this header is constructed by prepending the string "Bearer " to the authentication token obtained from the login response. Understanding and correctly setting these request headers is fundamental for ensuring proper communication and authorization when interacting with the Umami API.

5. Identifying Key Umami API Endpoints for Analytics Data:

To build an effective iOS application for accessing Umami analytics, it is crucial to identify the specific API endpoints that provide the desired data. The Umami API offers several endpoints for retrieving different types of analytics information.

One of the primary endpoints for obtaining a high-level overview of website performance is /api/websites/:websiteId/stats.[26, 27] This endpoint allows developers to retrieve summarized statistics for a specific website, which is identified by its unique websiteId. The websiteId is a path parameter that must be replaced with the actual ID of the website as configured in the Umami instance. This endpoint requires parameters such as startAt and endAt, which are timestamps in milliseconds that define the specific time range for which the statistics are needed.[26] Additionally, it supports several optional parameters, including url, referrer, title, and others, which can be used to filter the statistics based on specific criteria. The response from this endpoint typically includes key metrics such as the total number of pageviews, the count of unique visitors, the number of visits (sessions), the number of bounces (visitors who only viewed a single page), and the totaltime spent on the website within the specified period.[26] This endpoint is likely to be of significant importance for the iOS application as it provides a way to display key performance indicators at a glance. It is worth noting a past discussion [28] regarding potential inaccuracies in the documentation related to the "bounces" metric, suggesting that developers should refer to the most current official documentation for precise definitions.

For more granular data on website traffic, the /api/websites/:websiteId/pageviews endpoint is available.[26, 27] This endpoint retrieves detailed page view data for a given website within a specified timeframe. Similar to the /stats endpoint, it requires the websiteId, startAt, and endAt parameters. It also accepts the same optional filter parameters like url, referrer, and title. A particularly useful parameter for this endpoint is unit, which allows the data to be bucketed into different time intervals such as year, month, day, hour, or minute.[26] The response from this endpoint typically includes an array of objects, where each object contains a time indicator x (corresponding to the specified unit) and the number of page views y for that time interval.[26] This endpoint will enable the iOS application to display trends in page views over time, offering users the ability to view data at different levels of granularity, such as daily or monthly trends. It has been noted in past issues [29, 30] that there might have been inconsistencies or issues related to the format of timestamps expected by the API, so careful attention to the required format (milliseconds) is advisable.

If the self-hosted Umami instance is configured to track custom events, the /api/websites/:websiteId/events endpoint, along with related /event-data sub-endpoints like /event-data/events, /event-data/fields, and /event-data/stats, can be used to access this data.[26, 27, 31] These endpoints allow for the retrieval of information about specific user interactions or activities that are being tracked beyond simple page views. Common parameters for these endpoints include startAt, endAt, and the websiteId. Additionally, optional filters such as the event name can be used to retrieve data for specific types of events. The format of the response will vary depending on the specific /event-data sub-endpoint being called. For instance, the /event-data/events endpoint might return a list of unique event names that have been recorded along with their respective counts.[26, 31] If the user's Umami setup utilizes custom event tracking, these endpoints will be essential for displaying this engagement data within the iOS application. It's important to be aware that discussions [32, 33] have indicated recent changes to the response format of the /events endpoint, emphasizing the need to consult the most up-to-date official documentation to ensure correct data parsing and handling.

Across these key API endpoints, there are several parameters that provide flexibility in data retrieval. The websiteId is a fundamental parameter required to specify which website's analytics data is being requested. The startAt and endAt parameters, which should be provided as timestamps in milliseconds, define the specific period for which data is to be fetched. The unit parameter is relevant for time-series data like page views and events, allowing developers to specify the desired level of aggregation (e.g., daily, monthly). Furthermore, a range of optional filter parameters, including url, referrer, title, host, os, browser, device, country, region, city, event, and query, enable the application to narrow down the results to specific subsets of data based on these criteria.[26] Some endpoints also support parameters for pagination, such as page and pageSize, which are useful for handling large datasets by allowing the application to retrieve data in manageable chunks.[31, 32] The availability of these parameters allows the iOS application to be highly configurable in terms of the specific analytics data it retrieves, enabling features like custom date range selection and the application of filters within the app's user interface.

The following table summarizes the key Umami API endpoints for retrieving analytics data, their purpose, required parameters, and the type of data typically returned:

Table: Key Umami API Endpoints for Analytics Data

| Endpoint | Purpose | Required Parameters | Optional Parameters |Data Returned |
| :-------------------------------- | :------------------------------------------------------------------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| /api/websites/:websiteId/stats | Retrieves summarized statistics for a specific website. | websiteId (as part of the path), startAt (timestamp in ms), endAt (timestamp in ms) | url, referrer, title, query, etc. | pageviews, visitors, visits, bounces, totaltime, and potentially other metrics. |
| /api/websites/:websiteId/pageviews | Retrieves detailed page view data for a specific website over a time range. | websiteId (as part of the path), startAt (timestamp in ms), endAt (timestamp in ms) | url, referrer, title, query, unit (e.g., day, month) | An array of objects with a time indicator (x) and the count of page views (y) for that period. |
| /api/websites/:websiteId/events | Retrieves data about custom events tracked for a specific website. | websiteId (as part of the path), startAt (timestamp in ms), endAt (timestamp in ms) | event, query, page, pageSize, etc. | Depends on the specific sub-endpoint used (e.g., /event-data/events might return counts of event names). |
| /api/websites/:websiteId/event-data/events | Lists unique event names and their counts. | websiteId (as part of the path), startAt (timestamp in ms), endAt (timestamp in ms) | query | An array of event names with their corresponding counts. |
| /api/websites/:websiteId/event-data/fields | Retrieves data for specific event fields (e.g., event value). | websiteId (as part of the path), startAt (timestamp in ms), endAt (timestamp in ms), field | query | Data related to the specified event field, potentially including counts or distributions. |
| /api/websites/:websiteId/event-data/stats | Provides summary statistics for custom events. | websiteId (as part of the path), startAt (timestamp in ms), endAt (timestamp in ms) | query, event, field | Summary statistics for events, which can be filtered by event name and field. |

Developers of the iOS application should consult the most current and comprehensive official Umami API documentation for the exact details on parameters, response formats, and any potential updates or changes to these endpoints.[5, 6] Understanding these details is essential for correctly constructing API requests and parsing the responses within the iOS application.

6. Parsing JSON Data from the Umami API Response:

The data returned by the Umami API is predominantly in JSON (JavaScript Object Notation) format.[5, 6] JSON is a lightweight and widely used data-interchange format that is easily readable by both humans and machines. It is based on a subset of the JavaScript programming language and consists of key-value pairs and ordered lists of values. Swift provides excellent built-in support for working with JSON data through the Foundation framework, specifically using the JSONSerialization class and the Codable protocol.

When an iOS application receives a response from an Umami API endpoint, the body of the response, if successful, will typically contain JSON data. This data needs to be parsed and converted into Swift data structures (like dictionaries, arrays, and custom objects) so that it can be effectively used within the application's logic and displayed in its user interface. The process of parsing JSON in Swift involves using the JSONSerialization class to convert the raw Data received from the network request into Foundation objects such as NSDictionary or NSArray, or more conveniently, by using the Codable protocol to decode the JSON data directly into Swift structs or classes.

Using JSONSerialization:

The JSONSerialization class is a fundamental tool for handling JSON in Swift. It allows you to convert a JSON string (represented as Data) into a Foundation object (like a dictionary or an array) and vice versa. Here's how you might use it to parse the data received from the Umami API in the previous GET request example:
Swift

do {
    if let json = try JSONSerialization.jsonObject(with: data, options:) as?] {
        // 'json' is now an optional that can be cast to a specific type,
        // such as a dictionary ([String: Any]) or an array ([Any]).

        if let websiteArray = json as? [[String: Any]] {
            // Iterate through the array of websites, where each website is a dictionary
            for website in websiteArray {
                if let id = website["id"] as? String,
                   let name = website["name"] as? String,
                   let domain = website["domain"] as? String {
                    print("Website ID: \(id), Name: \(name), Domain: \(domain)")
                    // Further process the website information
                }
            }
        } else if let statsDictionary = json as? [String: Any] {
            // Handle the case where the JSON is a dictionary, e.g., statistics
            if let pageviews = statsDictionary["pageviews"] as? Int,
               let visitors = statsDictionary["visitors"] as? Int {
                print("Pageviews: \(pageviews), Visitors: \(visitors)")
                // Use the statistics data
            }
        } else {
            print("Unexpected JSON structure")
        }
    }
} catch {
    print("Error parsing JSON: \(error)")
}

In this code snippet, JSONSerialization.jsonObject(with:options:) is used to attempt to convert the data received from the API into a Swift object. The options parameter can be used to specify options for reading the JSON data, such as whether to allow fragments at the root level. The method throws an error if the data is not valid JSON, so it's important to wrap the call in a do-catch block to handle potential errors. The result is an optional Any type, which then needs to be conditionally cast to the expected structure, such as an array of dictionaries (in the case of a list of websites) or a dictionary (in the case of statistics). You then need to further unwrap the values within these structures and cast them to their expected types (e.g., String, Int). This manual parsing approach can be verbose and error-prone, especially for more complex JSON structures.

Using the Codable Protocol:

A more modern and type-safe approach to handling JSON in Swift is to use the Codable protocol. By conforming a Swift struct or class to Codable (which is a type alias for both Encodable and Decodable), you can leverage the JSONDecoder class to automatically parse JSON data into instances of your custom types. This approach requires you to define Swift types that mirror the structure of the JSON you expect to receive from the API.

For example, if the /api/websites/:websiteId/stats endpoint returns JSON like this:
JSON

{
  "pageviews": 1234,
  "visitors": 567,
  "visits": 890,
  "bounces": 123,
  "totaltime": 456789
}

You would first define a Swift struct that matches this structure:
Swift

struct WebsiteStats: Codable {
    let pageviews: Int
    let visitors: Int
    let visits: Int
    let bounces: Int
    let totaltime: Int
}

The property names in your Swift struct should match the keys in the JSON response. If they don't match exactly, you can use a CodingKeys enum within your struct to provide custom mappings. Once you have defined your Codable struct, you can parse the JSON data as follows:
Swift

do {
    let decoder = JSONDecoder()
    let stats = try decoder.decode(WebsiteStats.self, from: data)
    // 'stats' is now an instance of WebsiteStats, and you can access its properties directly
    print("Pageviews: \(stats.pageviews), Visitors: \(stats.visitors)")
} catch {
    print("Error decoding JSON: \(error)")
}

Here, a JSONDecoder is instantiated, and its decode(_:from:) method is called with the type of the struct (WebsiteStats.self) and the data received from the API. If the JSON structure in the data matches the structure defined in WebsiteStats, the decoder will create an instance of WebsiteStats and populate its properties with the values from the JSON. If there is a mismatch or an error during parsing, the method will throw an error.

For JSON responses that contain arrays, you would define your Codable struct or class to represent each element in the array, and then you would decode an array of that type. For instance, if the /api/websites/:websiteId/pageviews endpoint returns an array of page view data points, where each point has a time (x) and a view count (y), you might define a struct like this:
Swift

struct PageViewData: Codable {
    let x: String // Or Date, depending on the format
    let y: Int
}

And then decode the data into an array of these structs:
Swift

do {
    let decoder = JSONDecoder()
    let pageViews = try decoder.decode([PageViewData].self, from: data)
    for viewData in pageViews {
        print("Time: \(viewData.x), Views: \(viewData.y)")
    }
} catch {
    print("Error decoding JSON: \(error)")
}

When dealing with dates in JSON, which are often represented as strings in a specific format or as Unix timestamps, you might need to configure the dateDecodingStrategy of the JSONDecoder to properly parse these values into Date objects in Swift.

Adopting the Codable protocol generally leads to cleaner, more readable, and less error-prone code compared to manual parsing with JSONSerialization. It also provides type safety, as the Swift compiler can help ensure that the structure of the JSON matches your Swift types. Therefore, it is highly recommended to define Codable structs or classes that correspond to the expected JSON response structures from the various Umami API endpoints you intend to use in your iOS application.

7. Security Considerations for Handling API Keys and Tokens:

When developing an iOS application that interacts with a backend API, such as a self-hosted Umami instance, one of the most critical aspects to consider is the security of sensitive information, particularly API keys and authentication tokens. These credentials, if compromised, could allow unauthorized access to user data or the analytics platform itself. Therefore, it is essential to implement robust security measures to protect them.

For a self-hosted Umami setup, the primary security concern revolves around the authentication token obtained after a successful login. This token essentially acts as a key that grants access to the API for subsequent requests. If this token is stored insecurely on the user's device, malicious actors could potentially retrieve it and use it to access the user's analytics data without their permission.

Secure Storage of Authentication Tokens:

The recommended approach for storing sensitive data like authentication tokens on iOS devices is to use the Keychain. The Keychain is a secure storage provided by iOS that is specifically designed to hold small pieces of sensitive data, such as passwords, certificates, and encryption keys. Data stored in the Keychain is encrypted and protected by the device's Secure Enclave (if available) and the user's passcode or biometric authentication (like Face ID or Touch ID).[34, 35, 36, 37]

To use the Keychain, you typically interact with it through the Security framework in Swift. You can add, retrieve, update, and delete items from the Keychain using functions like SecItemAdd, SecItemCopyMatching, SecItemUpdate, and SecItemDelete. There are also third-party wrapper libraries available, such as SwiftKeychainWrapper, that can simplify the process of working with the Keychain by providing a more convenient and higher-level API.[38, 39, 40] These libraries often handle the complexities of the Security framework, making it easier to store and retrieve data with just a few lines of code.

When storing the Umami authentication token in the Keychain, it's important to choose appropriate attributes for the Keychain item. At a minimum, you should specify a service name, which uniquely identifies the application or service that the keychain item belongs to, and an account name, which identifies the specific user or entity associated with the data. For an Umami iOS app, the service name could be something like com.yourcompany.umami-ios-app, and the account name could be the user's Umami username or a unique identifier associated with their login. You should also set the accessibility level of the keychain item to control when the data can be accessed (e.g., only when the device is unlocked).[41]

When the iOS application needs to make an authenticated request to the Umami API, it should first attempt to retrieve the authentication token from the Keychain using the service and account identifiers. If a token is found, it can then be included in the Authorization header of the API request. If no token is found (e.g., if the user has not yet logged in or has logged out), the application should prompt the user to enter their Umami credentials and then store the newly obtained token in the Keychain for future use.

Avoiding Insecure Storage Methods:

It is strongly discouraged to store sensitive information like API keys or authentication tokens in less secure places, such as:

    UserDefaults: This is meant for storing user preferences and small amounts of non-sensitive data. Data stored in UserDefaults is not encrypted and can be easily accessed, especially on jailbroken devices.[42]
    Local file storage (e.g., within the app's Documents directory): Files in the app's file system can be accessible to malicious apps or through other means, especially on compromised devices. They do not offer the same level of protection as the Keychain.[43]
    In-memory variables: While the token might be held in a variable after login, it should not persist there indefinitely. It should be securely stored in the Keychain for use in subsequent sessions and should be cleared from memory when it's no longer needed in the current operation.
    Hardcoding API keys directly in the application code: This is a very bad practice as the keys can be easily extracted from the app bundle, even if the app is not jailbroken. For self-hosted Umami, this is less of a concern since you'd be storing an authentication token, but for cloud-based services with API keys, this should always be avoided.

Additional Security Best Practices:

    Use HTTPS: Ensure that all communication between the iOS application and the self-hosted Umami instance is done over HTTPS. This encrypts the data in transit, protecting it from eavesdropping.
    Server-side security: While this report focuses on the iOS app, it's crucial to ensure that the self-hosted Umami instance itself is properly secured with strong passwords, up-to-date software, and any other recommended security measures for server environments.
    Token expiration: If the Umami API provides a mechanism for token expiration, the iOS application should be designed to handle expired tokens gracefully. This might involve prompting the user to log in again to obtain a new token when the current one expires.
    Input validation: Sanitize any user input before sending it to the API to prevent potential injection attacks.
    Rate limiting: Consider the possibility of implementing rate limiting on the API requests from the iOS application to prevent abuse. This would typically be a concern on the server side (the Umami instance) but might also need to be considered in the app's design if it makes a very large number of requests.
    Secure disposal of data: If the application handles any sensitive analytics data locally (which should ideally be minimized), ensure that it is properly secured and disposed of when no longer needed.

By adhering to these security considerations and primarily focusing on the use of the iOS Keychain for storing the authentication token, developers can significantly enhance the security of their Umami iOS application and protect the user's data from unauthorized access.

8. Displaying Analytics Data in the iOS App:

Once the iOS application has successfully authenticated with the self-hosted Umami API and retrieved the desired analytics data (such as website statistics, page views, or event data) in JSON format, the next step is to parse this data and present it to the user in a clear and meaningful way within the app's user interface.

Parsing the JSON Data:

As discussed in Section 6, the best practice for parsing JSON data in Swift is to use the Codable protocol. You should define Swift structs or classes that correspond to the structure of the JSON responses from the Umami API endpoints you are using. After making an API request and receiving the data, you would use a JSONDecoder to convert the Data into instances of your Swift types. This will make the data easy to work with in your application's logic.

Designing the User Interface:

The design of the user interface should focus on making the analytics data accessible and understandable, even on the smaller screen of an iOS device. Consider the following aspects:

    Navigation: Implement a clear and intuitive navigation system that allows users to easily access different types of analytics data (e.g., overview, page views, events) for their tracked websites. This could be achieved using a tab bar, a navigation bar with a segmented control, or a sidebar menu.
    Data Presentation: Choose appropriate UI elements to display the data. For high-level summary statistics (like total page views, visitors, and visits), you might use simple labels with large, easily readable numbers. For time-series data (like page views over time), charts and graphs are often the most effective way to visualize trends and patterns. iOS provides frameworks like SwiftUI Charts or third-party libraries like Charts (formerly iOS Charts) that can be used to create various types of charts (e.g., line charts, bar charts) to represent this data visually.[44, 45]
    Date Range Selection: Allow users to specify the time period for which they want to see analytics data. You could use a date picker or predefined ranges (e.g., last 7 days, last 30 days, current month). Make sure the selected date range is correctly translated into the startAt and endAt parameters of your Umami API requests.
    Website Selection: If a user has multiple websites tracked in their Umami instance, provide a way for them to select which website's analytics they want to view. This might be a simple dropdown or a list view of their websites. Remember to use the correct websiteId in your API requests based on the user's selection.
    Filtering and Sorting: If the Umami API endpoints you are using support filtering (e.g., by URL, referrer, title, event name), consider exposing these filtering options in your app's UI to allow users to drill down into specific segments of their data. Similarly, if the API returns data that can be sorted (e.g., top pages by views), provide sorting options in the UI.
    Real-time Updates: Depending on the nature of the data and the capabilities of the Umami API, you might want to consider implementing a mechanism to provide near real-time updates of the analytics data. This could involve periodically polling the API for new data or using more advanced techniques if the API supports them.

Example UI Layout Ideas:

    Overview Screen: This could be the main landing screen, displaying key metrics like the total number of visits in the last 7 days, the number of unique visitors, and maybe a simple line chart showing the trend of page views over the same period. You could also include a section for top referrers or most visited pages.
    Page Views Screen: This screen could focus on the detailed page view data, perhaps with a chart showing daily or monthly trends. You might also allow users to filter by specific URLs or titles.
    Events Screen: If you are tracking custom events, this screen could display a list of the events, perhaps with counts of how many times each event has occurred within the selected time range. You could also show trends of specific event occurrences over time.

Best Practices for UI Development:

    Keep it simple: Avoid overwhelming the user with too much information at once. Focus on presenting the most important metrics clearly.
    Use visual cues: Employ charts, graphs, and color coding to help users quickly understand trends and identify key insights in their data.
    Optimize for mobile: Ensure that the layout is responsive and works well on different screen sizes and orientations of iOS devices. Use appropriate font sizes and spacing for readability.
    Provide feedback: When the app is loading data or performing actions, provide visual feedback to the user (e.g., using activity indicators) so they know the app is working.
    Handle errors gracefully: If API requests fail or data parsing encounters errors, display informative error messages to the user and provide ways to retry or resolve the issue.

By carefully considering the design of your iOS app's user interface and how you present the data retrieved from the Umami API, you can create a valuable tool that allows users to easily monitor and understand their website analytics on the go. Remember to iterate on your design based on user feedback to ensure that the app meets their needs effectively.

9. Conclusion and Next Steps:

Building an iOS application to interact with a self-hosted Umami analytics tool presents a valuable opportunity for users to gain convenient access to their website data on their mobile devices. This process involves several key steps, starting with understanding the Umami API, authenticating to gain access, making HTTP requests from the iOS app to retrieve data, parsing the JSON responses, and finally, presenting this data in a user-friendly interface.

Through this detailed description, we have covered the fundamental aspects of this integration. We explored the Umami API's structure, focusing on the base URL for self-hosted instances and the importance of authentication via the /api/auth/login endpoint. We then delved into how to make HTTP requests in iOS using Swift's URLSession, providing code examples for both GET and POST requests, including setting necessary headers like Content-Type and Authorization. We also identified key Umami API endpoints for retrieving analytics data, such as /api/websites/:websiteId/stats, /pageviews, and /events, along with the parameters they accept.

The report also highlighted the importance of efficiently handling the data returned by the Umami API, which is primarily in JSON format. We discussed two main approaches in Swift: using JSONSerialization for more manual parsing and leveraging the Codable protocol for a more type-safe and automated way to map JSON data to Swift structures. Furthermore, we addressed critical security considerations, emphasizing the need to use the iOS Keychain for securely storing the authentication token obtained from the Umami login process, while also cautioning against less secure storage methods. Finally, we touched upon the aspects of displaying the analytics data within the iOS application, suggesting UI elements and layouts that can effectively present this information to the user, such as charts, graphs, and date range selectors.

As for the next steps in developing this iOS application, here's a suggested roadmap:

    Set up a self-hosted Umami instance (if you haven't already). Ensure it is accessible over HTTP or HTTPS at a known URL.
    Thoroughly review the official Umami API documentation (umami.is/docs) to get the most up-to-date information on all available endpoints, their parameters, request methods, and response structures.
    Plan the features of your iOS application. Decide which analytics data points and visualizations would be most useful for your users. This will guide you in selecting the specific Umami API endpoints you need to integrate with.
    Implement the authentication flow in your iOS app. This involves creating a UI for users to enter their Umami username and password, making a POST request to the /api/auth/login endpoint, and securely storing the received token in the Keychain.
    Build data models (Swift structs/classes) using the Codable protocol that correspond to the JSON responses from the Umami API endpoints you plan to use.
    Implement functions using URLSession to make authenticated API requests to the chosen Umami endpoints, passing any required parameters (like websiteId, startAt, and endAt).
    Use a JSONDecoder to parse the responses from the API into your defined data model objects.
    Develop the user interface of your iOS application using SwiftUI or UIKit. This involves creating views to display the parsed analytics data in an informative and visually appealing manner, using appropriate UI elements like labels, charts, and tables.
    Implement error handling to gracefully manage network issues, invalid responses, or incorrect user credentials. Provide informative feedback to the user in case of errors.
    Test your application thoroughly with different scenarios and date ranges to ensure that it correctly retrieves and displays the analytics data.
    Consider additional features based on your needs and the capabilities of the Umami API, such as allowing users to manage their Umami websites or account settings (if the API supports it), or implementing push notifications for certain analytics events (though this would likely require additional server-side logic).

By following these steps and continuously referring to the official Umami API documentation, developers can create a robust and user-friendly iOS application that effectively leverages the power of their self-hosted Umami analytics data. Remember that the open-source nature of Umami means it might evolve over time, so staying updated with any changes to the API or authentication methods will be important for the long-term maintenance of your application.

References:

    Umami Analytics. (n.d.). Retrieved from https://umami.is/
    Umami Analytics Documentation. (n.d.). Privacy. Retrieved from https://www.google.com/search?q=https://umami.is/docs/privacy
    Umami Analytics Documentation. (n.d.). Features. Retrieved from https://www.google.com/search?q=https://umami.is/docs/features
    Umami Software GitHub Repository. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/tree/38ab6851435322495a67068d7c798a92be1fef66 (Note: Access to the specified tree was unavailable during research.)
    Umami Analytics Documentation. (n.d.). API. Retrieved from https://umami.is/docs/api
    Umami Analytics API Reference (Swagger). (n.d.). Retrieved from (A valid Swagger link was not found during research. It is recommended to look for a link within the official documentation or the GitHub repository.)
    Umami Analytics Documentation. (n.d.). API Keys. Retrieved from https://www.google.com/search?q=https://umami.is/docs/api%23api-keys
    Umami Software GitHub Repository. (n.d.). API Client. Retrieved from (A specific link to the API client within the repository was not found. Refer to the repository's file structure for potential client implementations.)
    npm umami-api-client. (n.d.). Retrieved from https://www.google.com/search?q=https://www.npmjs.com/package/umami-api-client
    Umami Analytics Documentation. (n.d.). Authentication. Retrieved from https://www.google.com/search?q=https://umami.is/docs/api%23authentication
    GitHub Issue: Default credentials security issue. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/issues/415
    GitHub Issue: Security: Default credentials should be removed. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/issues/805
    GitHub Issue: Security: Default credentials admin/umami. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/issues/145
    GitHub Pull Request: Fixes #805 Removes default admin credentials. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/pull/806
    GitHub Pull Request: Remove default admin account. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/pull/416
    Umami v2.0.0. (2023). GitHub Release Notes. Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/releases/tag/v2.0.0 (Mentions removal of default credentials)
    DigitalOcean Community. (2022). How To Install Umami Web Analytics on Ubuntu 22.04. Retrieved from https://www.google.com/search?q=https://www.digitalocean.com/community/tutorials/how-to-install-umami-web-analytics-on-ubuntu-22-04 (Initial setup considerations might include default credentials)
    HTTP | MDN. (n.d.). Authorization. Retrieved from https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization
    Apple Developer Documentation. (n.d.). URLSession. Retrieved from https://developer.apple.com/documentation/foundation/urlsession
    Apple Developer Documentation. (n.d.). Making HTTP Requests. Retrieved from https://www.google.com/search?q=https://developer.apple.com/documentation/foundation/urlsession/making_http_requests
    Apple Developer Documentation. (n.d.). URLRequest. Retrieved from https://developer.apple.com/documentation/foundation/urlrequest
    Apple Developer Documentation. (n.d.). URL. Retrieved from https://developer.apple.com/documentation/foundation/url
    Apple Developer Documentation. (n.d.). HTTPBody. Retrieved from https://www.google.com/search?q=https://developer.apple.com/documentation/foundation/urlrequest/1786931-httpbody
    Apple Developer Documentation. (n.d.). addValue(_:forHTTPHeaderField:). Retrieved from https://www.google.com/search?q=https://developer.apple.com/documentation/foundation/urlrequest/1418222-addvalue
    HTTP Headers - MDN. (n.d.). Retrieved from https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers
    Umami Analytics Documentation. (n.d.). Website Endpoints. Retrieved from https://www.google.com/search?q=https://umami.is/docs/api%23website-endpoints
    Umami Software GitHub Repository. (n.d.). lib/routes/website.js. Retrieved from (A direct link to this file within the provided tree was not available. Refer to the repository's structure.)
    GitHub Issue: Documentation: bounces is not explained correctly. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/issues/544
    GitHub Issue: API returns wrong timestamp. (n.d.). Retrieved from https://github.com/umami-software/umami/issues/1264
    GitHub Issue: Inconsistent timestamp format from /api/websites/:id/pageviews. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/issues/871
    Umami Analytics Documentation. (n.d.). Event Data Endpoints. Retrieved from https://www.google.com/search?q=https://umami.is/docs/api%23event-data-endpoints
    GitHub Issue: Regression: /api/websites/:id/events no longer returns { value, count } array. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/issues/1439
    GitHub Pull Request: Fix(web): Fix broken events API. (n.d.). Retrieved from https://www.google.com/search?q=https://github.com/umami-software/umami/pull/1440
    Apple Developer Documentation. (n.d.). Keychain Services. Retrieved from https://developer.apple.com/documentation/security/keychain_services
    Apple Developer Documentation. (n.d.). Secure Enclave. Retrieved from https://www.google.com/search?q=https://developer.apple.com/documentation/security/secure_enclave
    Apple Developer Documentation. (n.d.). Protecting Data at Rest with iOS Data Protection. Retrieved from https://www.google.com/search?q=https://developer.apple.com/documentation/security/protecting_data_at_rest_with_ios_data_protection
    OWASP Mobile Security Project. (n.d.). iOS Platform Security. Retrieved from https://www.google.com/search?q=https://owasp.org/www-project-mobile-top-10/masvs/0x05-platform-security/ (Contains information on Keychain usage)
    SwiftKeychainWrapper GitHub Repository. (n.d.). Retrieved from https://github.com/jrendel/SwiftKeychainWrapper
    KeychainAccess GitHub Repository. (n.d.). Retrieved from https://github.com/kishikawakatsumi/KeychainAccess
    TrustKit GitHub Repository. (n.d.). Retrieved from https://github.com/datatheorem/TrustKit (While primarily for SSL pinning, it might offer utilities for secure storage)
    Apple Developer Documentation. (n.d.). kSecAttrAccessible. Retrieved from https://developer.apple.com/documentation/security/ksecattraccessible
    Apple Developer Documentation. (n.d.). UserDefaults. Retrieved from https://developer.apple.com/documentation/foundation/userdefaults
    Apple Developer Documentation. (n.d.). File System Overview. Retrieved from https://www.google.com/search?q=https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemOverview/FileSystemOverview.html
    Apple Developer Documentation. (n.d.). Charts. Retrieved from https://developer.apple.com/documentation/charts
    Charts GitHub Repository. (n.d.). Retrieved from https://github.com/danielgindi/Charts