# Apim Traffic Splitting
A demonstration of using APIM for traffic splitting, useful when the underlying service does not support traffic splitting or where the configuration of the web apps is breaking, necessitating a new deployment.

## Capability

Using an APIM policy, for traffic splitting.

## Implementation

Azure API Management does not come with a traffic splitting policy/algorithm. Fortunately it does leverage C# and some .NET Framework types in the policy expression engine. We can therefore use a simple Random function to randomly create a number between 1 and 100, then allocate the traffic based off that number. All things working as they should, we have a simple but effective way of balancing load.

This can be leveraged in the following types of scenario

- Canary (by sending a small percentage of traffic)
- Blue/Green
- Staged Migrations

## Anti pattern

Where using an Azure service that supports traffic splitting (like App Service, or Service Mesh in AKS) that should be the way to implement this capability. Where this is not possible

## Demonstration

Using an Azure Load Test resource for traffic, then App Insights query to compare traffic volumes.

## Diagram

```
              ┌────────────────────────────┐                   ┌──────────────────┐
              │                            │                   │                  │
              │                            │                   │                  │
              │       API Management       ◄───────────────────┤   Load Testing   │
              │                            │                   │                  │
              │                            │                   │                  │
              └──────┬─────────────┬───────┘                   └──────────────────┘
                     │             │
                     │             │
                     │             │
   95% of the traffic│             │5% of the traffic
                     │             │
                     │             │
                     │             │
                     │             │
                     │             │
                     │             │
                     │             │
┌────────────────────▼─┐         ┌─▼────────────────────┐
│                      │         │                      │
│                      │         │                      │
│      Web Api 1       │         │       Web Api 2      │
│                      │         │                      │
│                      │         │                      │
└───────────────────┬──┘         └──┬───────────────────┘
                    │               │
                    │               │
                    │               │
                    │               │
                ┌───▼───────────────▼───┐
                │                       │
                │                       │
                │     App Insights      │
                │                       │
                │                       │
                └───────────────────────┘
```

## Bicep

## APIM Policy



## More Reading

[set-backend-service](https://docs.microsoft.com/en-us/azure/api-management/api-management-transformation-policies#SetBackendService)
