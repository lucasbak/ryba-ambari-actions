
# Ambari Configs update

Get ambari named config using the [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name` (string)   
  Name of the cluster, required
* `config_type` (string)   
  config of the name to modify example core-site, hdfs-site... required.
* `properties` (object)   
  properties to add to the configuration, required.
* `tag` (object)   
  tag of the updated config, will be computed if no provided.

## Exemple

```js
configs.get({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "config_type": 'hdfs-site'
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
      options.debug ?= false
      do_end = ->
        callback error, status, properties if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil properties
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        throw Error 'Required Options: config_type' unless options.config_type
        throw Error 'Required Options: tag' unless options.tag
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/clusters/#{options.cluster_name}/configurations?type=#{options.config_type}&tag=#{options.tag}"
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
          result = JSON.parse response
          throw Error 'Properties not found' if statusCode isnt 200
          items = result.items.filter( (item) -> item.tag is options.tag && item.type is options.config_type)
          throw Error "#{options.config_type} not found with tag #{options.tag}" unless items.length > 0
          properties = items[0].properties
          status = true
          do_end()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../utils'
