
  config = require '../config'
  cluster_add = require '../src/cluster/add'
  cluster_delete = require '../src/cluster/delete'
  persist = require '../src/cluster/persist'
  nikita = require('nikita')()

  
  describe 'cluster actions', ->
      
    it 'error if no name', (done) ->
      options = Object.assign {}, config.options
      cluster_add options, (err) ->
        err.message.should.eql 'Required Options: name'
        done()

    it 'error if no version', (done) ->
      options = Object.assign {}, config.options
      options.name = "ryba_test"
      cluster_add options, (err) ->
        err.message.should.eql 'Required Options: version'
        done()

    it 'error if no name (nikita)', ->
      options = Object.assign {}, config.options
      nikita
      .registry.register ['ambari', 'cluster_add'], "#{__dirname}/../src/cluster/add"
      .ambari.cluster_add options
      .next (err) ->
        err.message.should.eql 'Required Options: name'

    it 'error if no version (nikita)', ->
      options = Object.assign {}, config.options
      options.name = 'ryba_test'
      nikita
      .registry.register ['ambari', 'cluster_add'], "#{__dirname}/../src/cluster/add"
      .ambari.cluster_add options
      .next (err) ->
        err.message.should.eql 'Required Options: version'


    it 'post not existing cluster (nikita)', ->
      options = Object.assign {}, config.options
      options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      nikita
      .registry.register ['ambari', 'cluster_add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster_delete'], "#{__dirname}/../src/cluster/delete"
      .ambari.cluster_delete options
      .ambari.cluster_add options
    , (err, status) ->
      return done err if err
      status.should.be.true()

    it 'post existing cluster (nikita)', ->
      options = Object.assign {}, config.options
      options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      nikita
      .registry.register ['ambari', 'cluster_add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster_delete'], "#{__dirname}/../src/cluster/delete"
      .ambari.cluster_delete options
      .ambari.cluster_add options
      .ambari.cluster_add options
    , (err, status) ->
      return done err if err
      status.should.be.false()
    
    it 'delete existing cluster (nikita)', ->
      options = Object.assign {}, config.options
      options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      nikita
      .registry.register ['ambari', 'cluster_add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster_delete'], "#{__dirname}/../src/cluster/delete"
      .ambari.cluster_delete options
      .ambari.cluster_add options
      .ambari.cluster_delete options
    , (err, status) ->
      return done err if err
      status.should.be.true()
    
    it 'delete not existing cluster (nikita)', ->
      options = Object.assign {}, config.options
      options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      nikita
      .registry.register ['ambari', 'cluster_add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster_delete'], "#{__dirname}/../src/cluster/delete"
      .ambari.cluster_delete options
      .ambari.cluster_add options
      .ambari.cluster_delete options
    , (err, status) ->
      return done err if err
      status.should.be.true()
    

    it 'finalise ambari in progress', ->
      options = Object.assign {}, config.options
      options.name = 'ryba_test'
      options.version = 'HDP-2.5'
      nikita
      .registry.register ['ambari', 'cluster_add'], "#{__dirname}/../src/cluster/add"
      .registry.register ['ambari', 'cluster_delete'], "#{__dirname}/../src/cluster/delete"
      .ambari.cluster_delete options
      .ambari.cluster_add options
      .next (err) ->
        return done err if err
        persist options, (err, status) ->
          return done err if err
          status.should.be.true()
