param appName string

param logAnalyticsId string

//var webAppName = 'app-${appName}-${uniqueString(resourceGroup().id, appName)}'

resource AppInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appName
  location: resourceGroup().location
  kind: 'web'
  tags: {
    //This looks nasty, but see here: https://github.com/Azure/bicep/issues/555
    'hidden-link:${resourceGroup().id}/providers/Microsoft.Web/sites/${appName}': 'Resource'
  }
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId:logAnalyticsId
    IngestionMode: 'LogAnalytics'
  }
}
output id string = AppInsights.id
output name string = AppInsights.name
