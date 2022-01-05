@description('Used in the naming of Az resources')
@minLength(3)
param nameSeed string

param redisName string =  'redis-${nameSeed}'

resource redis 'Microsoft.Cache/redis@2020-12-01' = {
  name:redisName
  location: resourceGroup().location
  properties: {
    sku: {
      capacity: 0
      family: 'C'
      name: 'Basic'
    }
    redisVersion: '6'
    minimumTlsVersion: '1.2'
  }
}

@description('Log Analytics ResourceId')
param logId string

@description('Diagnostic categories to log')
param logCategory array = [
  'ConnectedClientList'
]

resource diags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'aksDiags'
  scope: redis
  properties: {
    workspaceId: logId
    logs: [for diagCategory in logCategory: {
      category: diagCategory
      enabled: true
    }]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

output name string = redis.name
output hostName string = redis.properties.hostName
output sslPort int = redis.properties.sslPort
output id string = redis.id
output redisfullresourceid string = '${environment().resourceManager}${substring(redis.id,1)}'
