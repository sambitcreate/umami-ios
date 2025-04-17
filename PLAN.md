# Umami Frontend-Backend Communication Plan

This document outlines how the frontend of Umami communicates with the backend, detailing the architecture, data flow, and key components involved in this interaction.

## 1. Architecture Overview

Umami is built using a modern web stack with the following key technologies:

- **Frontend**: Next.js (React framework)
- **Backend**: Next.js API routes (serverless functions)
- **Database**: Multiple database support
  - PostgreSQL (default relational database)
  - MySQL (alternative relational database)
  - ClickHouse (optional analytics database for high-volume data)
  - Kafka (optional message queue for event streaming)

The application follows a client-server architecture where:
1. The frontend renders UI components and makes API calls to fetch data
2. The backend processes these requests, interacts with the database, and returns responses
3. A JavaScript tracker is used to collect website analytics data from external sites

## 2. Frontend Components

### 2.1 API Client Implementation

The frontend uses a custom API client implementation to communicate with the backend:

- **`useApi` Hook** (`src/components/hooks/useApi.ts`): A React hook that provides methods for making API requests
- **Fetch Utilities** (`src/lib/fetch.ts`): Low-level functions for making HTTP requests
- **Authentication**: API requests include authentication tokens in headers

```javascript
// Example of useApi hook usage
const { get, post, put, del } = useApi();

// Making an API request
const data = await get('/websites/123');
```

### 2.2 Data Fetching Patterns

Umami uses React Query (TanStack Query) for data fetching, caching, and state management:

- **Query Hooks**: Custom hooks for specific data fetching operations (e.g., `useWebsite`, `useUsers`)
- **Cached Queries**: Data is cached to minimize redundant requests
- **Pagination**: Support for paginated data fetching

```javascript
// Example of a query hook
export function useWebsite(websiteId) {
  const { get, useQuery } = useApi();
  
  return useQuery({
    queryKey: ['website', { websiteId }],
    queryFn: () => get(`/websites/${websiteId}`),
    enabled: !!websiteId,
  });
}
```

### 2.3 State Management

- **React Context**: Used for global state (e.g., user authentication, current website)
- **React Query**: Manages server state and caching
- **Local Storage**: Stores user preferences and authentication tokens

## 3. Backend API Routes

### 3.1 API Route Structure

The backend is implemented using Next.js API routes located in `src/app/api/`:

- **Route Handlers**: Functions that process HTTP requests and return responses
- **Request Parsing**: Validates and parses incoming requests
- **Authentication**: Verifies user permissions before processing requests
- **Database Queries**: Executes database operations and returns results

```javascript
// Example API route handler
export async function GET(request, { params }) {
  const { auth, error } = await parseRequest(request);

  if (error) {
    return error();
  }

  const { websiteId } = await params;

  if (!(await canViewWebsite(auth, websiteId))) {
    return unauthorized();
  }

  const website = await getWebsite(websiteId);

  return json(website);
}
```

### 3.2 Authentication and Authorization

- **JWT Tokens**: Used for authentication
- **Permission Checks**: Functions like `canViewWebsite`, `canUpdateUser` verify permissions
- **Role-Based Access**: Different user roles have different permissions

## 4. Database Layer

### 4.1 Query Abstraction

Umami supports multiple database backends through an abstraction layer:

- **Query Functions**: Located in `src/queries/` directory
- **Database Adapters**: Support for Prisma (PostgreSQL/MySQL) and ClickHouse
- **Query Routing**: The `runQuery` function routes queries to the appropriate database

```javascript
// Example of database abstraction
export async function getWebsiteStats(...args) {
  return runQuery({
    [PRISMA]: () => relationalQuery(...args),
    [CLICKHOUSE]: () => clickhouseQuery(...args),
  });
}
```

### 4.2 Database Models

- **Prisma Schema**: Defines database models for PostgreSQL and MySQL
- **ClickHouse Schema**: Separate schema for ClickHouse analytics database
- **Data Types**: Consistent data types across database implementations

## 5. Website Tracking

### 5.1 Tracker Script

The core of Umami's analytics functionality is the JavaScript tracker:

- **Script Generation**: Built using Rollup (`rollup.tracker.config.mjs`)
- **Script Embedding**: Website owners add a script tag to their sites
- **Event Collection**: Tracks page views, custom events, and user interactions

```javascript
// Example tracker script tag
<script defer src="https://analytics.example.com/script.js" data-website-id="123"></script>
```

### 5.2 Data Collection Endpoint

- **Collection API**: `/api/send` endpoint receives tracking data
- **Batch Processing**: `/api/batch` endpoint for processing multiple events
- **Bot Detection**: Filters out bot traffic
- **Data Processing**: Parses and stores tracking data in the database

```javascript
// Simplified data flow for tracking
1. Tracker script collects data
2. Data sent to /api/send endpoint
3. Server processes and validates data
4. Data stored in database
5. Response sent back to tracker with cache token
```

### 5.3 Real-time Analytics

- **Active Visitors**: Real-time tracking of active website visitors
- **WebSocket**: Not used; relies on polling for real-time updates

## 6. Data Flow Examples

### 6.1 Dashboard Data Loading

1. User navigates to dashboard
2. React components mount and call query hooks
3. Query hooks make API requests to backend endpoints
4. Backend validates authentication and permissions
5. Backend executes database queries
6. Data is returned to frontend and displayed

### 6.2 Website Analytics Collection

1. Visitor loads a website with Umami tracker
2. Tracker script initializes and collects page data
3. Data is sent to the `/api/send` endpoint
4. Backend processes the request and stores data
5. Response includes a cache token for subsequent requests
6. Additional events (clicks, custom events) follow the same flow

## 7. Security Considerations

- **CORS Headers**: Configured to allow cross-origin requests for tracking
- **Authentication**: JWT-based authentication for admin access
- **Data Validation**: Request validation using Zod schema
- **IP Blocking**: Support for blocking specific IP addresses
- **Do Not Track**: Respects browser's Do Not Track setting

## 8. Performance Optimizations

- **Query Caching**: React Query caches API responses
- **Database Indexing**: Optimized database indexes for common queries
- **ClickHouse Support**: Optional high-performance analytics database
- **Kafka Integration**: Optional message queue for high-volume event processing

## 9. Conclusion

Umami's frontend-backend communication is built on a modern, scalable architecture that supports:

- Clean separation of concerns between UI and data layers
- Multiple database backends for different scaling needs
- Secure and efficient data collection for analytics
- Real-time data visualization and reporting

This architecture allows Umami to provide a privacy-focused alternative to commercial analytics platforms while maintaining performance and scalability.
