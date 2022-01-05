@description('The name seed for all your other resources.')
param resNameSeed string = 'trafficSplitDemo'

@description('The short application name of the first Function App to receive 95% of the traffic')
param app1Name string = 'app1'

@description('The short application name of the first Function App to receive 95% of the traffic')
param app2Name string = 'app2'

@description('Creating the serverless app stack')
module app1 '../archetype/apimWebApp.bicep' = {
  name: 'serverlessapp-${app1Name}'
  params: {
    resNameSeed: resNameSeed
    appName: app1Name
    AppGitRepoUrl: 'https://github.com/Gordonby/SimpleFunctionApp.git'
    AppSettings: [
      {
        name: 'TRAFFICID'
        value: app1Name
      }
    ]
  }
}

@description('Creating the serverless app stack')
module app2 '../archetype/apimWebApp.bicep' = {
  name: 'serverlessapp-${app2Name}'
  params: {
    resNameSeed: resNameSeed
    appName: app2Name
    AppGitRepoUrl: 'https://github.com/Gordonby/SimpleFunctionApp.git'
    AppSettings: [
      {
        name: 'TRAFFICID'
        value: app2Name
      }
    ]
  }
  dependsOn: [
    app1
  ]
}

var apiName = 'MyTrafficSplitApp'
@description('Using a module to uniformly create api')
module appApi '../foundation/apim-api.bicep' = {
  name: 'appApi-apim-${resNameSeed}'
  params: {
    apimName: app1.outputs.ApimName
    apimLoggerId: app1.outputs.ApimLoggerId
    AppInsightsName: app1.outputs.AppInsightsName
    servicename: apiName
    baseUrl: 'https://${app1.outputs.ApplicationUrl}'
    serviceApimPath: 'test'
    serviceDisplayName: 'MyTrafficSplitApp'
    apimSubscriptionRequired: false
    apis: [
      {
        method: 'GET'
        urlTemplate: '/api/context'
        displayName : 'Get Api Context'
        name: 'GetContext'
      }
    ]
  }
}
