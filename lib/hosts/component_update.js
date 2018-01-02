// Generated by CoffeeScript 2.0.2
// # Ambari Component Update to host

// Add a host to an ambari cluster [REST API v2](https://github.com/apache/ambari/blob/trunk/ambari-server/docs/api/v1)
// The node should already exist in ambari.

// * `password` (string)
//   Ambari Administrator password.
// * `url` (string)
//   Ambari External URL.
// * `username` (string)
//   Ambari Administrator username.
// * `component_name` (string)
//   The name of the component to add.
// * `hostname` (string)
//   The name of host to add the component to.
// * `properties` (object)
//   The object of proeprties to put, required.

// ## Exemple

// ```js
// .hosts.component_add({
//   "username": 'ambari_admin',
//   "password": 'ambari_secret',
//   "url": "http://ambari.server.com",
//   "component_name": 'NAMENODE'
//   "hostname": 'master1.metal.ryba'
//   }
// }, function(err, status){
//   console.log( err ? err.message : "Node Added To Cluster: " + status)
// })
// ```

// ## Source Code
var utils;

module.exports = function(options, callback) {
  var do_end, err, error, hostname, opts, path, port, requests, status;
  error = null;
  status = false;
  requests = null;
  if (options.debug == null) {
    options.debug = false;
  }
  do_end = function() {
    console.log(error, status, requests);
    if (callback != null) {
      return callback(error, status, requests);
    }
    return new Promise(function(fullfil, reject) {
      if (error != null) {
        reject(error);
      }
      return fullfil(status, requests);
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
    if (!options.component_name) {
      throw Error('Required Options: component_name');
    }
    if (!options.hostname) {
      throw Error('Required Options: hostname');
    }
    if (!options.cluster_name) {
      throw Error('Required Options: cluster_name');
    }
    if (!options.properties) {
      throw Error('Required Options: properties');
    }
    [hostname, port] = options.url.split("://")[1].split(':');
    if (options.sslEnabled == null) {
      options.sslEnabled = options.url.split('://')[0] === 'https';
    }
    path = `/api/v1/clusters/${options.cluster_name}/hosts/${options.hostname}/host_components`;
    opts = {
      hostname: hostname,
      port: port,
      rejectUnauthorized: false,
      headers: utils.headers(options),
      sslEnabled: options.sslEnabled
    };
    opts['method'] = 'GET';
    opts.path = `${path}/${options.component_name}`;
    return utils.doRequestWithOptions(opts, function(err, statusCode, response) {
      var hostroles, ref;
      try {
        if (err) {
          throw err;
        }
        response = JSON.parse(response);
        if (statusCode !== 200) {
          throw Error(response.message);
        }
        hostroles = response['HostRoles'];
        if ((ref = hostroles.desired_state) === 'INSTALLED') {
          return do_end();
        }
        opts['method'] = 'PUT';
        opts.content = JSON.stringify(options.properties);
        console.log(opts);
        return utils.doRequestWithOptions(opts, function(err, statusCode, response) {
          try {
            if (err) {
              throw err;
            }
            response = JSON.parse(response);
            requests = response['Requests'];
            status = true;
            return do_end();
          } catch (error1) {
            err = error1;
            error = null;
            return do_end();
          }
        });
      } catch (error1) {
        err = error1;
        error = err;
        return do_end();
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