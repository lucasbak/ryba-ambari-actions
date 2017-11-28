
# Ambari Repository Add

Create a repository version on specific stask version the [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1/repository-version-resources.md)

* `password` (string)
  Ambari Administrator password.
* `url` (string)   
  Ambari External URL.
* `username` (string)
  Ambari Administrator username.
* `stack_name` (string)   
  Stack name, required.
* `stask_version` (string)   
  Stack version, required.

## Exemple

```js
nikita
.cluster_add({
  "username": 'ambari_admin',
  "password": 'ambari_secret',
  "url": "http://ambari.server.com",
  "name": 'my_cluster'
  "version": 'HDP-2.5.3'
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
      throw Error 'Required Options: name' unless options.name
      # throw Error 'Required Options: version' unless options.version
      clusters =
        Clusters:
          version: 'HDP-2.5'
          repository_version: '2.5.3.0'
      @system.execute
        cmd: """
        curl --fail -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -k -X POST -H 'X-Requested-By: ambari' \
          -u #{options.username}:#{options.password} --data '#{JSON.stringify clusters}' \
          "#{options.url}/api/v1/clusters/#{options.name}"
        """
        unless_exec: """
        curl --fail -H "Content-Type: application/json" -k -X GET -H 'X-Requested-By: ambari' \
          -u #{options.username}:#{options.password} \
          "#{options.url}/api/v1/clusters/#{options.name}"
        """
        code_skipped: 22
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
