
# Ambari Configs Groups

Create ambari config groups [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `cluster_name` (string)   
  Name of the cluster, required
* `group_name` (string)   
  The config groups name, required
* `tag` (string)   
  tag of the config groups, required
  Tha tag is wht identified uniquely on admin side the config groups
* `id` (int)
  the id of the config groups to delete
  If no id is provided, the group_name and tag should be provided

## Exemple

```js
configs.groups({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "cluster_name": 'ryba_test',
  "group_name": "compute_worker"
  "tag": "a tag"
  "description": "yarn high compute power"
  "hosts": ['worker01.metal.ryba']
  "desired_configs": {
    "type: "hdfs-site",
    "tag": "advances hdfs site",
    "properties": {
      "datanode.dir": "[DISK]file://data/1/hdfs"
      }  
  }
  }
}, function(err, status){
  console.log( err ? err.message : "Config groups CREATED/UPDATED: " + status)
})
```

## Source Code
This functions does a single post request with desired_configs and config_group.
Hosts can be empty as the config group can be uptade with a later PUT request.

    module.exports = (options, callback) ->
      options = options.options if typeof options.options is 'object'
      process.stdout.write "Entering config.grous.delete\n" if options.debug
      error = null
      status = false
      options.debug ?= false
      options.merge ?= true
      do_end = ->
        return callback error, status if callback?
        new Promise (fullfil, reject) ->
          reject error if error?
          fullfil status
      try
        throw Error 'Required Options: username' unless options.username
        throw Error 'Required Options: password' unless options.password
        throw Error 'Required Options: url' unless options.url
        throw Error 'Required Options: cluster_name' unless options.cluster_name
        throw Error 'Required Options: group_name' unless options.group_name
        throw Error 'Required Options: tag' unless options.tag
        throw Error 'Required Options: desired_configs' unless options.desired_configs
        options.desired_configs = [options.desired_configs] unless Array.isArray options.desired_configs 
        options.hosts ?= []
        options.description ?= "config group cluster: #{options.cluster_name} group #{options.config_name}"
        [hostname,port] = options.url.split("://")[1].split(':')
        options.sslEnabled ?= options.url.split('://')[0] is 'https'
        path = "/api/v1/clusters/#{options.cluster_name}"
        opts = {
          hostname: hostname
          port: port
          rejectUnauthorized: false
          headers: utils.headers options
          sslEnabled: options.sslEnabled
        }
        #check desired_configs keys
        for config in options.desired_configs
          for k, v of config
            throw Error Missing "config.type" unless config.type
            throw Error Missing "config.tag" unless config.tag
            throw Error Missing "config.properties" unless config.properties
        opts['method'] = 'GET'
        path = "#{path}/config_groups"
        do_search_items = ->
          process.stdout.write "Search config groups item\n" if options.debug
          #config groups are identified by id
          # as a consequence need to compare group name and tag to delete if not id is provided
          search_item = (index, items) ->
            item = items[index]
            opts.path = "#{path}/#{item.ConfigGroup.id}"
            opts.method = 'GET'
            process.stdout.write "Compare group item  with id n° #{item.ConfigGroup.id}\n" if options.debug
            utils.doRequestWithOptions opts, (err, statusCode, response) ->
              try
                throw err if err
                throw Error response.message unless parseInt(statusCode) is 200
                response = JSON.parse response
                if (response.ConfigGroup.group_name is options.group_name) and (response.ConfigGroup.tag is options.tag)
                  options.id = response.ConfigGroup.id
                  do_delete_id()
                else
                  index = index + 1
                  return if index is items.length then search_item index, items else do_end()
              catch err
                error = err
                do_end()
          opts.method = 'GET'
          opts.path = path
          process.stdout.write "Searching items by id\n" if options.debug
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
            try
              throw err if err
              throw Error response.message unless parseInt(statusCode) is 200
              response = JSON.parse response
              if response.items.length > 0 then search_item 0, response.items else do_end()
            catch err
              error = err
              do_end()
        do_delete_id = ->
          process.stdout.write "Deleting by id #{options.id}\n" if options.debug
          opts.path = "#{path}/#{options.id}"
          opts.method = 'DELETE'
          utils.doRequestWithOptions opts, (err, statusCode, response) ->
            try
              throw err if err
              if parseInt(statusCode) isnt 200
                response = JSON.parse response
                throw Error response.message
              status = true
              do_end()
            catch err
              error = err
              do_end()
        if options.id then do_delete_id() else do_search_items()
      catch err
        error = err
        do_end()

## Depencendies

    utils = require '../../utils'
    path = require 'path'
    {merge} = require 'nikita/lib/misc'
