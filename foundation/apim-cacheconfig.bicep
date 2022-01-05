param apimName string
param redisName string

resource apim 'Microsoft.ApiManagement/service@2021-04-01-preview' existing = {
  name: apimName
}

resource redis 'Microsoft.Cache/redis@2020-12-01' existing = {
  name: redisName
}

var redisconnectionstring = '${redis.properties.hostName}:${redis.properties.sslPort},password=${redis.listKeys().primaryKey},ssl=True,abortConnect=False'

resource apimcache 'Microsoft.ApiManagement/service/caches@2021-04-01-preview' = {
  name: resourceGroup().location
  parent: apim
  properties: {
    useFromLocation: resourceGroup().location
    description: redis.properties.hostName
    resourceId: '${environment().resourceManager}${substring(redis.id,1)}'
    connectionString: redisconnectionstring
  }
}
