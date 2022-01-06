/*
  A simple function app, fronted by APIM.
  As an Archetype there is no specific application information, just the right configuration for a standard App deployment.
*/

@description('The name seed for your functionapp. Check outputs for the actual name and url')
param appName string

@description('The name seed for all your other resources.')
param resNameSeed string

@allowed([
  'Developer'
  'Premium'
  'Consumption'
])
@description('The Sku of APIM thats appropriate for the App')
param apiManagementSku string = 'Consumption'

@description('Restricts inbound traffic to your functionapp, to just from APIM')
param restrictTrafficToJustAPIM bool = false

@description('Needs to be unique as ends up as a public endpoint')
var webAppName = 'app-${appName}-${uniqueString(resourceGroup().id, appName)}'

// --------------------App Identity-------------------
//Creating the function App identity here as otherwise it'll cause circular problems in the modules
@description('The Azure Managed Identity Name assigned to the FunctionApp')
param fnAppIdentityName string = 'id-app-${appName}-${uniqueString(resourceGroup().id, appName)}'

resource fnAppUai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: fnAppIdentityName
  location: resourceGroup().location
}

// --------------------Function App-------------------
@description('The ful publicly accessible external Git(Hub) repo url')
param AppGitRepoUrl string

param AppGitRepoProdBranch string = 'main'
param AppGitRepoStagingBranch string = ''

param AppSettings array = []

module functionApp '../foundation/functionapp.bicep' = {
  name: 'functionApp-${appName}-${resNameSeed}'
  params: {
    appName: appName
    webAppName: webAppName
    AppInsightsName: appInsights.outputs.name
    additionalAppSettings: AppSettings
    restrictTrafficToJustAPIM: restrictTrafficToJustAPIM
    fnAppIdentityName: fnAppUai.name
    repoUrl: AppGitRepoUrl
    repoBranchProduction: AppGitRepoProdBranch
    repoBranchStaging: AppGitRepoStagingBranch
  }
}
@description('The raw ')
output ApplicationUrl string = functionApp.outputs.appUrl

// --------------------App Insights-------------------
module appInsights '../foundation/appinsights.bicep' = {
  name: 'appinsights-${resNameSeed}'
  params: {
    appName: webAppName
    logAnalyticsId: logAnalyticsResourceId
  }
}
output AppInsightsName string = appInsights.outputs.name

// --------------------Log Analytics-------------------
@description('If you have an existing log analytics workspace in this region that you prefer, set the full resourceId here')
param centralLogAnalyticsId string = ''
module log '../foundation/loganalytics.bicep' = if(empty(centralLogAnalyticsId)) {
  name: 'log-${resNameSeed}'
  params: {
    resNameSeed: resNameSeed
    retentionInDays: 30
  }
}
var logAnalyticsResourceId =  !empty(centralLogAnalyticsId) ? centralLogAnalyticsId : log.outputs.id

// --------------API Management-----------------------
module apim '../foundation/apim.bicep' =  {
  name: 'apim-${resNameSeed}'
  params: {
    nameSeed: resNameSeed
    AppInsightsName: appInsights.outputs.name
    sku: apiManagementSku
    logId: logAnalyticsResourceId
    useRedisCache: false
  }
}
output ApimName string = apim.outputs.ApimName
output ApimLoggerId string = apim.outputs.loggerId
