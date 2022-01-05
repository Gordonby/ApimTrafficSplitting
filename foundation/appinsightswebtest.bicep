@description('Name of the App Insights Resource')
param AppInsightsName string

param Name string

@description('URL to test')
param WebTestUrl string

param RequestType string = 'Get'

resource AppInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: AppInsightsName
}

resource urlTest 'Microsoft.Insights/webtests@2018-05-01-preview' = {
  name: Name
  location: resourceGroup().location
  kind: 'ping'
    tags: {
    'hidden-link:${AppInsights.id}': 'Resource'
  }
  properties: {
    Name: Name
    Kind: 'standard'
    SyntheticMonitorId: Name
    Frequency: 300
    Timeout: 30
    Enabled:true
    Request: {
      FollowRedirects: false
      HttpVerb: RequestType
      RequestUrl: WebTestUrl
      ParseDependentRequests: false
    }
    ValidationRules: {
      ExpectedHttpStatusCode: 200
      SSLCheck:false
    }
    Locations: [
      {
        Id: 'emea-nl-ams-azr'
      }
      {
        Id: 'emea-se-sto-edge'
      }
      {
        Id: 'emea-ru-msa-edge'
      }
      {
        Id: 'emea-gb-db3-azr'
      }
      {
        Id: 'emea-ch-zrh-edge'
      }
    ]
  }
}
