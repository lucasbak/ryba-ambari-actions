curl 'https://master01.metal.ryba:8442/api/v1/version_definitions' -H 'Host: master01.metal.ryba:8442' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:56.0) Gecko/20100101 Firefox/56.0' -H 'Accept: application/json, text/javascript, */*; q=0.01' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://master01.metal.ryba:8442/' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'X-Requested-By: X-Requested-By' -H 'X-Requested-With: XMLHttpRequest' -H 'Cookie: hadoop.auth="u=hdfs&p=hdfs@HADOOP.RYBA&t=kerberos&e=1509334295665&s=8i2zQ7anXc8zv4NJraZ377mKuCM="; _ga=GA1.2.1959454760.1509291064; _gid=GA1.2.723541937.1509291064; AMBARISESSIONID=dypqijfyiji6cfmuwau3mojq' -H 'Connection: keep-alive' --data '{"VersionDefinition":{"available":"HDP-2.5-2.5.3.0"}}'

# Ambari Version Definition Add

Create a Repository definition for a stack version using [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/repository-version-resources.md).
Its required to know the stack Name and the stack version.

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `stack_name` (string)   
  HDP Stack. (required)
* `stack_version` (string)   
  HDP Stack. (required)

## Exemple

```js
nikita
.cluster_add({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "stack": 'HDP-2.5'
  "version": '2.5.3.0'
  }
}, function(err, status){
  console.log( err ? err.message : "Policy Created: " + status)
})
```
#Handles: PUT

    module.exports = (options) ->
      throw Error 'Required Options: username' unless options.username
      throw Error 'Required Options: password' unless options.password
      throw Error 'Required Options: url' unless options.url
      throw Error 'Required Options: stack' unless options.stack
      throw Error 'Required Options: version' unless options.version
      ## TODO validate stack and version definition
      data =
        VersionDefinition:
          available: "#{options.stack}-#{options.version}"
      items = []
      exist = false
      ## Get list of version_definitions
      @call
        shy: true
      ,  ->
        @system.execute
          cmd: """
          curl --fail -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -k -X GET -H 'X-Requested-By: ambari' \
            -u #{options.username}:#{options.password} \
            "#{options.url}/api/v1/version_definitions"
          """
        , (err, status, stdout, stderr) ->
          throw err if err
          try
            result = JSON.parse stdout
            items = result.items
          catch err
            throw err
      ## loop through definitions to look for service definitions
      @call
        shy: true
        unless: -> items.length is 0
      , ->
        @each items, (opts, cb) ->
          item = opts.key
          @system.execute
            cmd: """
            curl --fail -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -k -X GET -H 'X-Requested-By: ambari' \
              -u #{options.username}:#{options.password}  \
              "#{options.url}/api/v1/version_definitions/#{item['VersionDefinition']['id']}"
            """
          , (err, status, stdout, stderr) ->
            throw err if err
            try
              result = JSON.parse stdout
              exist = result['VersionDefinition']['repository_version'] is options.version
            catch err
              throw err
          @then cb
      ## add repository version if not exist
      @system.execute
        unless: -> exist is true
        cmd: """
        curl --fail -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -k -X POST -H 'X-Requested-By: ambari' \
          -u #{options.username}:#{options.password} --data '#{JSON.stringify data}' \
          "#{options.url}/api/v1/version_definitions"
        """
        # unless_ex
        # code_skipped: 22
        # curl 'https://master01.metal.ryba:8442/api/v1/clusters/ryba_cluster' -H 'Host: master01.metal.ryba:8442' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:56.0) Gecko/20100101 Firefox/56.0' -H 'Accept: text/plain, */*; q=0.01' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Referer: https://master01.metal.ryba:8442/' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'X-Requested-By: X-Requested-By' -H 'X-Requested-With: XMLHttpRequest' -H 'Cookie: hadoop.auth="u=hdfs&p=hdfs@HADOOP.RYBA&t=kerberos&e=1509334295665&s=8i2zQ7anXc8zv4NJraZ377mKuCM="; _ga=GA1.2.1959454760.1509291064; _gid=GA1.2.723541937.1509291064; AMBARISESSIONID=dypqijfyiji6cfmuwau3mojq' -H 'Connection: keep-alive' --data '{"Clusters":{"version":"HDP-2.5","repository_version":"2.5.3.0"}}'
      # @system.execute
      #   cmd: """
      #   curl --fail -H "Content-Type: application/json" -k -X POST \
      #     -d '#{JSON.stringify options.policy}' \
      #     -u #{options.username}:#{options.password} \
      #     "#{options.url}/service/public/v2/api/policy"
      #   """
      #   unless_exec: """
      #   curl --fail -H "Content-Type: application/json" -k -X GET  \
      #     -u #{options.username}:#{options.password} \
      #     "#{options.url}/service/public/v2/api/service/#{options.policy.service}/policy/#{options.policy.name}"
      #   """
      #   code_skipped: 22
