param resNameSeed string
param apimName string
param apimLoggerId string
param appInsightsName string

@description('The default base URL for the API')
param apiBaseUrl string

@description('The Name of the API, used in the named value entries and must match the traffic split policy')
param apiName string

@description('The baseUrl to override the primary API with')
param apiOverrideUrl string

@maxValue(100)
@minValue(0)
@description('The percentage of traffic to send to the apiOverride Url')
param apiOverrideWeight int = 5

@description('Enforces requirement for an api subscription key')
param requireSubscriptionForApis bool = true

@description('Creating a proper reference to APIM')
resource apim 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimName
}

var namedValueBaseUrl = '${apiName}_TrafficBaseUrlOverride'
@description('This is used by a policy to know where to send the traffic in case of overriding the backend')
resource apimTrafficSplitAppConfig 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apim
  name: namedValueBaseUrl
  properties: {
    displayName: namedValueBaseUrl
    secret: false
    value: apiOverrideUrl
    tags: [
      'createdby_trafficsplitdemobicep'
    ]
  }
}

var namedValueSplitWeight = '${apiName}_TrafficSplitWeight'
@description('This is used to indicate what percentage of traffic to override with the appOverrideBaseUrl')
resource apimTrafficSplitPercentConfig 'Microsoft.ApiManagement/service/namedValues@2021-08-01' = {
  parent: apim
  name: namedValueSplitWeight
  properties: {
    displayName: namedValueSplitWeight
    secret: false
    value: '${apiOverrideWeight}'
    tags: [
      'createdby_trafficsplitdemobicep'
    ]
  }
}

@description('Using a module to uniformly create api')
module appApi '../foundation/apim-api.bicep' = {
  name: 'appApi-apim-${resNameSeed}'
  params: {
    apimName: apimName
    apimLoggerId: apimLoggerId
    AppInsightsName: appInsightsName
    servicename: apiName
    baseUrl: apiBaseUrl
    serviceApimPath: 'test'
    serviceDisplayName: 'MyTrafficSplitApp'
    apimSubscriptionRequired: requireSubscriptionForApis
    apis: [
      {
        method: 'GET'
        urlTemplate: '/api/context'
        displayName : 'Get Api Context'
        name: 'GetContext'
      }
    ]
    servicePolicyXmlUrl: 'https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureApimPolicies/ChangeBackendOnRandom.xml'
  }
  dependsOn: [
    apimTrafficSplitAppConfig
    apimTrafficSplitPercentConfig
  ]
}
