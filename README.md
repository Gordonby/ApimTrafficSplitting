# Apim Traffic Splitting
A demonstration of using APIM for traffic splitting, useful when the underlying service does not support traffic splitting or where the configuration of the api apps is breaking, necessitating a new deployment.

## Capability

Using an Azure API Management policy, for traffic splitting API calls based on a percentage weight.

## Implementation

Azure API Management does not come with a traffic splitting policy/algorithm. Fortunately it does leverage C# and some .NET Framework types in the policy expression engine. We can therefore use a simple Random function to randomly create a number between 1 and 100, then allocate the traffic based off that number. All things working as they should, we have a simple but effective way of balancing load.

This can be leveraged in the following types of scenario;

- Canary (by sending a small percentage of traffic)
- Blue/Green
- Staged Migrations

## Anti pattern

Where using an Azure service that supports traffic splitting (like App Service, or Service Mesh in AKS) that should be the way to implement this capability. Where this is not possible, APIM can be used to provide this capability.
## Bicep

Bicep 'Infrastructure as Code' files are included in this repo to provide an end to end deployment of this scenario that you can run in your own subscription.

The infrastructure we are creating focusses on

- API Management
- 2 Function Apps with the dummy API
- App Insights to log the function App telemetry

## APIM Policy

An APIM policy provides the opportunity to manipulate requests that are proxied by API Management.
## Load testing

In order to test the traffic splitting we need to send a lot of traffic through APIM.
Azure Load Testing provides an easy way to send bulk requests, simulated from multiple users.
## The results

The following Log Analytics query can be run to show the traffic split

```kql
AppRequests |
where SDKVersion  startswith "azurefunctions" |
summarize count() by AppRoleName |
render piechart
```

| AppRoleName | count_ |
| ----------- | ------ |
| app-app1-sqvskzhbllsbc | 16,912 |
| app-app2-oastktr32gjrw | 993 |

![pie chart](trafficsplitresultspie.png)

We can see that we didn't miss the mark by much. After sending nearly 18000 requests, we aimed to split **5%** of the traffic away and have successfully separated exactly **5.55%** of the traffic to App2.

## Further Reading

The official documentation for [APIM policy - set-backend-service](https://docs.microsoft.com/en-us/azure/api-management/api-management-transformation-policies#SetBackendService) is well worth a read.

This is a great [blog post](https://borzenin.com/apim-canary-policy/) from
Evgeny Borzenin that gives a great explanation of the Canary APIM policy. The implementation with the Policy code is a little different to this post, but i thoroughly recommend reading his blog post.


