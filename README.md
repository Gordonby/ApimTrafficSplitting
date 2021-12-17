# ApimTrafficSplitting
A demonstration of using APIM for traffic splitting, useful when the underlying service does not support traffic splitting or where the configuration of the web apps is breaking, necessitating a new deployment.

## Diagram

```
              ┌────────────────────────────┐
              │                            │
              │                            │
              │       API Management       │
              │                            │
              │                            │
              └──────┬─────────────┬───────┘
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
