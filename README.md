# Apim Traffic Splitting
A demonstration of using APIM for traffic splitting, useful when the underlying service does not support traffic splitting or where the configuration of the web apps is breaking, necessitating a new deployment.

## Capability

Using an APIM policy, for traffic splitting.

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
