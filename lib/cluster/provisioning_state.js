// Generated by CoffeeScript 2.1.1
// # Ambari Cluster Update Cluster State

// Update a cluster State using the [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)

// * `password` (string)
//   Ambari Administrator password.
// * `url` (string)   
//   Ambari External URL.
// * `username` (string)
//   Ambari Administrator username.
// * `name` (string)   
//   Name of the cluster.
// * `provisioning_state` (String)   
// The desired provisioning state.

// ## Exemple

// ```js
// nikita
// .cluster.provisioning_state({
//   "username": 'ambari_admin',
//   "password": 'ambari_secret',
//   "url": "http://ambari.server.com",
//   "name": 'my_cluster',
//   "provisioning_state": "INSTALLED"
//   }
// }, function(err, status){
//   console.log( err ? err.message : "Cluster Updated: " + status)
// })
// ```

// ## Source Code
var utils;

module.exports = function(options, callback) {
  var do_end, err, error, hostname, opts, path, port, status;
  error = null;
  status = false;
  if (options.debug == null) {
    options.debug = false;
  }
  do_end = function() {
    if (callback != null) {
      return callback(error, status);
    }
    return new Promise(function(fullfil, reject) {
      if (error != null) {
        reject(error);
      }
      return fullfil(response);
    });
  };
  try {
    if (!options.username) {
      throw Error('Required Options: username');
    }
    if (!options.password) {
      throw Error('Required Options: password');
    }
    if (!options.url) {
      throw Error('Required Options: url');
    }
    if (!options.name) {
      throw Error('Required Options: name');
    }
    if (!options.provisioning_state) {
      throw Error('Required Options: provisioning_state');
    }
    [hostname, port] = options.url.split("://")[1].split(':');
    if (options.sslEnabled == null) {
      options.sslEnabled = options.url.split('://')[0] === 'https';
    }
    path = "/api/v1/clusters";
    opts = {
      hostname: hostname,
      port: port,
      rejectUnauthorized: false,
      headers: utils.headers(options),
      sslEnabled: options.sslEnabled
    };
    opts['method'] = 'GET';
    opts.path = `${path}/${options.name}`;
    return utils.doRequestWithOptions(opts, function(err, statusCode, response) {
      if (err) {
        throw err;
      }
      response = JSON.parse(response);
      if (statusCode !== 200) {
        throw Error(response.message);
      }
      if ((response != null ? response.status : void 0) === 404) {
        throw Error(`Cluster ${options.name} does not exist in ambari-server`);
      } else {
        if (response['Clusters']['provisioning_state'] === options.provisioning_state) {
          return do_end();
        }
        opts['method'] = 'PUT';
        if (opts.content == null) {
          opts.content = {
            RequestInfo: {
              context: 'Update Provisoning State Cluster'
            },
            Body: {
              Clusters: {
                provisioning_state: options.provisioning_state
              }
            }
          };
        }
        opts.content = JSON.stringify(opts.content);
        return utils.doRequestWithOptions(opts, function(err, statusCode, response) {
          try {
            if (err) {
              throw err;
            }
            status = true;
            return do_end();
          } catch (error1) {
            err = error1;
            error = err;
            return do_end();
          }
        });
      }
    });
  } catch (error1) {
    err = error1;
    error = err;
    return do_end();
  }
};

// ## Depencendies
utils = require('../utils');