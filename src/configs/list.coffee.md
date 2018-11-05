
# Ambari Configs update

Get config hsitory for by service name. It does not use rest api, but custom url as used by webui.

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name` (string)   
  Name of the cluster, required
* `service` (string)   
  service name to get config on, required.     
* `fields` (array).   
  Array of fields to return. By default all fileds are returned. Valid fields:
   * `service_config_version`
   * `hosts`
   * `group_id`
   * `group_name`
   * `is_current`
   * `createtime`
   * `service_name`
   * `service_config_version_note`
   * `stack_id`
   * `is_cluster_compatible`
* `tag` (number)   
  number of tag to get historic on. By default all tag are returned.   
* `sortBy` (string)   
  sort result by `DESC` or `ASC`. `DESC` by default.
* `user` (string)   
  filter on config authof. By default all authors are returned
* `version` (string)
  get only some config version. By default all versions are returned.


## Exemple

```js
configs.list({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "service": 'HDFS'
  }
}, function(err, status, properties){
  console.log( err ? err.message : "Properties are: " + properties)
})
```

    module.exports = (options, callback) ->
      options = options.options if typeof options.options is 'object'
      error = null
      properties = null
      status = false
      itemsReturn = null
      options.debug ?= false
      do_end = ->
        callback error, itemsReturn if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil itemsReturn
      try
        throw Error 'Missing service name' unless options.service
        options.service = options.service.toUpperCase()
        options.sortBy ?= 'desc'
        options.sortBy = options.sortBy.toLowerCase()
        options.fields ?= ['service_config_version','user','hosts','group_id','group_name','is_current','createtime','service_name','service_config_version_note','stack_id','is_cluster_compatible']
        options.fields.push 'user'
        throw Error 'sortBy not valid: desc or asc expected' unless options.sortBy in ['desc','asc']
        if options.tag?
          throw Error 'Number of tag not a number' unless typeof options.tag is 'number'
        [hostname,port] = options.url.split("://")[1].split(':')
        hostname ?= options.hostname
        port ?= options.port
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        service_config_version = 'service_config_version'
        service_list_config = "&fields=#{options.fields.join(',')}&sortBy=service_config_version.#{options.sortBy}&minimal_response=true"
        if options.version
          # services = if Array.isArray options.service then options.service.join(',') else options.service
          services = ['RANGER_KMS','AMBARI_METRICS','RANGER','YARN','KAFKA','ZOOKEEPER','ATLAS','HBASE','HIVE','KNOX','STORM','AMBARI_INFRA_SOLR','HDFS']
          service_config_version = "&#{service_config_version}.in(#{options.version.join()})|service_name.in(#{services})"
        path = "/api/v1/clusters/#{options.cluster_name}/configurations/service_config_versions?service_name=#{options.service}#{if options.version then service_config_version else service_list_config}"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
        }
        opts['method'] = 'GET'
        opts.path = "#{path}"
        utils.doRequestWithOptions opts, (err, statusCode, response) ->
          throw err if err
          throw Error 'Service not found' if statusCode is 404
          throw Error response.message if statusCode isnt 200
          result = JSON.parse response
          items = result.items.slice(0, options.tag) if options.tag?
          items = result.items.filter( (item) -> item.user is options.user ) if options.user
          itemsReturn = result.items
          # console.log items
          status = true
          do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
