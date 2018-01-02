
  config = require '../config'
  cluster_add = require '../src/cluster/add'
  cluster_delete = require '../src/cluster/delete'
  persist = require '../src/cluster/persist'
  update = require '../src/configs/update'
  service_add = require '../src/services/add'
  service_delete = require '../src/services/delete'
  nikita = require('nikita')()

  
  describe 'services actions', ->
      
    it 'error no cluster name', (done) ->
      options = Object.assign {}, config.options
      options.config_type = 'hdfs-site'
      options.properties =
        'dfs.nameservices': 'ryba_test'
      update options, (err) ->
        err.message.should.eql 'Required Options: cluster_name'
        done()

    it 'error no version provided', (done) ->
      options = Object.assign {}, config.options
      options.cluster_name = "ryba_test"
      options.properties =
        'dfs.nameservices': 'ryba_test'
      update options, (err) ->
        err.message.should.eql 'Required Options: config_type'
        done()

    it 'error no properties provided', (done) ->
      options = Object.assign {}, config.options
      options.cluster_name = "ryba_test"
      options.config_type = 'hdfs-site'
      update options, (err) ->
        err.message.should.eql 'Required Options: source or properties'
        done()

    it 'error no cluster name (nikita)', ->
      options = Object.assign {}, config.options
      options.config_type = 'hdfs-site'
      options.properties =
        'dfs.nameservices': 'ryba_test'
      nikita
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .ambari.configs.update options
      .then (err) ->
        err.message.should.eql 'Required Options: cluster_name'

    it 'error no config name (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = 'ryba_test'
      options.properties =
        'dfs.nameservices': 'ryba_test'
      nikita
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .ambari.configs.update options
      .then (err) ->
        err.message.should.eql 'Required Options: config_type'

    it 'error no properties (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = 'ryba_test'
      options.config_type = 'hdfs-site'
      nikita
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .ambari.configs.update options
      , (err) ->
        err.message.should.eql 'Required Options: source or properties'

    it 'post service zookeeper (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'zoo.cfg'
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
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .registry.register ['ambari', 'services', 'add'], "#{__dirname}/../src/services/add"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      .ambari.services.add services_add
      , (err, status) ->
        status.should.be.true()
      .then (err) ->
        throw err if err?

    it 'post service zookeeper already exist (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'zoo.cfg'
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
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .registry.register ['ambari', 'services', 'add'], "#{__dirname}/../src/services/add"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      .ambari.services.add services_add
      .ambari.services.add services_add
      , (err, status) ->
        status.should.be.false()
      .then (err) ->
        throw err if err?

    it 'delete service zookeeper exist (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'zoo.cfg'
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
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .registry.register ['ambari', 'services', 'add'], "#{__dirname}/../src/services/add"
      .registry.register ['ambari', 'services', 'delete'], "#{__dirname}/../src/services/delete"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      .ambari.services.add services_add
      .ambari.services.delete services_add
      , (err, status) ->
        status.should.be.true()
      .then (err) ->
        throw err if err?

    it 'delete service zookeeper not exist (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'zoo.cfg'
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
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .registry.register ['ambari', 'services', 'add'], "#{__dirname}/../src/services/add"
      .registry.register ['ambari', 'services', 'delete'], "#{__dirname}/../src/services/delete"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      .ambari.services.delete services_add
      , (err, status) ->
        status.should.be.false()
      .then (err) ->
        throw err if err?

    it 'post  component zookeeper_server (nikita)', ->
      options = Object.assign {}, config.options
      options.cluster_name = options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      options.config_type = 'zoo.cfg'
      options.component_name = 'ZOOKEEPER_SERVER'
      options.service_name = 'ZOOKEEPER'
      options.properties =
        "autopurge.purgeInterval":"24",
        "autopurge.snapRetainCount":"30",
        "dataDir":"/hadoop/zookeeper",
        "tickTime":"2000",
        "initLimit":"11",
        "syncLimit":"5",
        "clientPort":"2181"
      services_add = Object.assign {}, options
      services_add.component_name = 'ZOOKEEPER_SERVER'
      nikita
      .registry.register ['ambari', 'cluster','add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster','persist'], "#{__dirname}/../src/cluster/persist"
      .registry.register ['ambari', 'cluster','delete'], "#{__dirname}/../src/cluster/delete"
      .registry.register ['ambari', 'configs', 'update'], "#{__dirname}/../src/configs/update"
      .registry.register ['ambari', 'services', 'add'], "#{__dirname}/../src/services/add"
      .registry.register ['ambari', 'services', 'component_add'], "#{__dirname}/../src/services/component_add"
      .ambari.cluster.delete options
      .ambari.cluster.add options
      .ambari.cluster.persist options
      .ambari.configs.update options
      .ambari.services.add services_add
      .ambari.services.component_add options
      , (err, status) ->
        status.should.be.true()
      .then (err) ->
        throw err if err?
