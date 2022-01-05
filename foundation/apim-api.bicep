/*
  This modules works great for adding simple API's.
  For more complex API's (eg. POST requests leveraging URL Template Parameteres, using this module makes little sense)
*/

param baseUrl string
param servicename string
param serviceApimPath string
param serviceDisplayName string = servicename
param apimSubscriptionRequired bool = false
param apimLoggerId string
param apis array = [
    {
      method: 'GET'
      urlTemplate: ''
      displayName : ''
      name: ''
    }
  ]

param apimName string
param AppInsightsName string = ''

resource apim 'Microsoft.ApiManagement/service@2021-01-01-preview' existing = {
  name: apimName
}

resource AppInsights 'Microsoft.Insights/components@2020-02-02' existing = if(!empty(AppInsightsName)) {
  name: AppInsightsName
}

@description('Create a new logger if one wasnt passed in')
resource ApimLogger 'Microsoft.ApiManagement/service/loggers@2021-04-01-preview' = if(empty((apimLoggerId))) {
  name: 'API-Logger'
  parent: apim
  properties: {
    loggerType: 'applicationInsights'
    resourceId: AppInsights.id
    credentials: {
      'instrumentationKey': AppInsights.properties.InstrumentationKey
    }
    description: 'Application Insights telemetry from APIs'
  }
}

var ApiLoggingProperties = {
  alwaysLog: 'allErrors'
  httpCorrelationProtocol: 'Legacy'
  verbosity: 'information'
  logClientIp: true
  loggerId: !empty((apimLoggerId)) ? apimLoggerId : ApimLogger.id
  sampling: {
    samplingType: 'fixed'
    percentage: 100
  }
}

resource apimService 'Microsoft.ApiManagement/service/apis@2021-04-01-preview' = {
  name: servicename
  parent: apim
  properties: {
    path: serviceApimPath
    displayName: serviceDisplayName
    serviceUrl: baseUrl
    protocols: [
      'https'
    ]
    subscriptionRequired: apimSubscriptionRequired
  }
}
output serviceName string = apimService.name

param servicePolicyXmlUrl string = ''
resource serviceLevelPolicy 'Microsoft.ApiManagement/service/apis/policies@2021-04-01-preview' = if(servicePolicyXmlUrl != '') {
  name: 'policy'
  parent: apimService
  properties: {
    value: servicePolicyXmlUrl
    format: 'xml-link'
  }
}

resource diags 'Microsoft.ApiManagement/service/apis/diagnostics@2021-04-01-preview' = {
  name: 'applicationinsights'
  parent: apimService
  properties: ApiLoggingProperties
}

resource apiMethod 'Microsoft.ApiManagement/service/apis/operations@2021-04-01-preview' = [for api in apis: {
  name: api.name
  parent: apimService
  properties: {
    displayName: api.displayName
    method: api.method
    urlTemplate: api.urlTemplate
    description: api.displayName
  }
}]

module webTest '../foundation/appinsightswebtest.bicep' = [for api in apis: if(!empty(AppInsightsName))  {
  name: 'DirectWebTest-${api.name}'
  params: {
    Name: '${api.name}-GetUsers-Direct'
    AppInsightsName: AppInsights.name
    WebTestUrl: '${baseUrl}${api.urlTemplate}'
  }
}]

resource cache 'Microsoft.ApiManagement/service/apis/operations/policies@2021-04-01-preview' = [for (api, index) in apis: if(contains(api, 'enableCache') && api.enableCache) {
  name: 'policy'
  parent: apiMethod[index]
  properties: {
    value: 'https://raw.githubusercontent.com/Gordonby/Snippets/master/AzureApimPolicies/CacheFor3600.xml'
    format: 'xml-link'
  }
}]
