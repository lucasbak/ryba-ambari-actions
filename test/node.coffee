
  config = require '../config'
  cluster_add = require '../src/cluster/add'
  cluster_delete = require '../src/cluster/delete'
  node_add = require '../src/cluster/node_add'
  nikita = require('nikita')()

  describe 'hosts actions', ->

    it 'error if no name', (done) ->
      options = Object.assign {}, config.options
      node_add options, (err) ->
        err.message.should.eql 'Required Options: hostname'
        done()

    it 'post host to cluster (nikita)', ->
      #note: node is registered an external cluster (will not delete it)
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.hostname = 'master01.metal.ryba'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'cluster','node_add'], "#{__dirname}/../src/cluster/node_add"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.node_add options
      , (err, status) ->
        throw err if err
        status.should.be.true()

    it 'post existing host to cluster (nikita)', ->
      #note: node is registered an external cluster (will not delete it)
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.hostname = 'master01.metal.ryba'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'cluster','node_add'], "#{__dirname}/../src/cluster/node_add"
      .registry.register ['ambari', 'host','add'], "#{__dirname}/../src/hosts/add"
      .registry.register ['ambari', 'host','delete'], "#{__dirname}/../src/hosts/delete"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.node_add options
      .ambari.cluster.node_add options
      , (err, status) ->
        throw err if err
        status.should.be.false()


    it 'post component zookeeper_server (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'zoo.cfg'
      options.component_name = 'ZOOKEEPER_SERVER'
      options.service_name = 'ZOOKEEPER'
      options.hostname = 'master01.metal.ryba'
      options.properties =
        "autopurge.purgeInterval":"24",
        "autopurge.snapRetainCount":"30",
        "dataDir":"/hadoop/zookeeper",
        "tickTime":"2000",
        "initLimit":"11",
        "syncLimit":"5",
        "clientPort":"2181"
      services_add = Object.assign {}, options
      services_add.name = 'ZOOKEEPER'
      host_component_add = Object.assign {}, options
      host_component_add.hostname = 'master01.metal.ryba'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .registry.register ['ambari', 'services', 'add'], "#{__dirname}/../src/services/add"
      .registry.register ['ambari', 'hosts', 'add'], "#{__dirname}/../src/hosts/add"
      .registry.register ['ambari', 'services', 'component_add'], "#{__dirname}/../src/services/component_add"
      .registry.register ['ambari', 'hosts', 'component_add'], "#{__dirname}/../src/hosts/component_add"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      .ambari.hosts.add options
      .ambari.cluster.node_add options
      .ambari.services.add services_add
      .ambari.services.component_add services_add
      .ambari.hosts.component_add host_component_add
      , (err, status) ->
        status.should.be.true()
      .next (err) ->
        throw err if err?

    it 'put state installed component zookeeper_server(nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'zoo.cfg'
      options.component_name = 'ZOOKEEPER_SERVER'
      options.service_name = 'ZOOKEEPER'
      options.hostname = 'master01.metal.ryba'
      options.properties =
        "autopurge.purgeInterval":"24",
        "autopurge.snapRetainCount":"30",
        "dataDir":"/hadoop/zookeeper",
        "tickTime":"2000",
        "initLimit":"11",
        "syncLimit":"5",
        "clientPort":"2181"
      services_add = Object.assign {}, options
      services_add.name = 'ZOOKEEPER'
      host_component_add = Object.assign {}, options
      host_component_add.hostname = 'master01.metal.ryba'
      host_component_add.properties  = 
        'HostRoles': state: 'INSTALLED'
      smoke_user_config = Object.assign {}, options
      smoke_user_config.config_type = 'cluster-env'
      smoke_user_config.properties =
        smokeuser: 'ambari-qa'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','node_add'], "#{__dirname}/../src/cluster/node_add"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .registry.register ['ambari', 'services', 'add'], "#{__dirname}/../src/services/add"
      .registry.register ['ambari', 'hosts', 'add'], "#{__dirname}/../src/hosts/add"
      .registry.register ['ambari', 'services', 'component_add'], "#{__dirname}/../src/services/component_add"
      .registry.register ['ambari', 'hosts', 'component_add'], "#{__dirname}/../src/hosts/component_add"
      .registry.register ['ambari', 'hosts', 'component_update'], "#{__dirname}/../src/hosts/component_update"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      .ambari.configs.update smoke_user_config
      .ambari.hosts.add options
      .ambari.cluster.node_add options
      .ambari.services.add services_add
      .ambari.services.component_add services_add
      .ambari.hosts.component_add host_component_add
      .ambari.hosts.component_update host_component_add
      , (err, status, requests) ->
        requests.status.should.eql 'Accepted'
        status.should.be.true()
      .next (err) ->
        throw err if err?
