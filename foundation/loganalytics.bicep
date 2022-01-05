@description('The name seed for all your other resources.')
param resNameSeed string

@description('The Log Analytics retention period')
param retentionInDays int = 30

var log_name = 'log-${resNameSeed}'

resource log 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: log_name
  location: resourceGroup().location
  properties: {
    retentionInDays: retentionInDays
  }
}
output id string = log.id
