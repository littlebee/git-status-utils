
Fs = require 'fs'
Path = require 'path'
Sinon = require 'sinon'

ChaiSubset = require 'chai-subset'
chai.use ChaiSubset


GitStatusUtils = require('../src/git-status-utils')


debugger

describe "GitStatusUtils", ->

  describe "when parsing output with all types of files", ->
    before ->
      testInputData = Fs.readFileSync(Path.join(__dirname, 'data', 'gitStatusWithTheWorks.txt')).toString()
      Sinon.stub GitStatusUtils, "_fetchStatus", => testInputData
      @parsedStatus = GitStatusUtils.getStatus("./")

    it "should have parsed expected attributes", ->
      expected = 
        branch: "master"
        commitsAheadBehind: 0
        remote: "origin/master"
      @parsedStatus.should.containSubset expected
    
    it "should have 18 staged changes", ->
      @parsedStatus.stagedChanges.length.should.equal 18
      @parsedStatus.stagedChanges[0].should.equal "new file: docs/api/index.html"
      
    it "should have 3 unstaged changes", ->
      @parsedStatus.unstagedChanges.length.should.equal 3
      @parsedStatus.unstagedChanges[0].should.equal "deleted: README.md"
    
    it "should have 3 untracked files", ->
      @parsedStatus.untrackedFiles.length.should.equal 3
      @parsedStatus.untrackedFiles[0].should.equal 'lib/README.md'

    after ->
      GitStatusUtils._fetchStatus.restore()
      
      
  describe "when parsing output with no changes or untracked", ->
    before ->
      testInputData = Fs.readFileSync(Path.join(__dirname, 'data', 'gitStatusClean.txt')).toString()
      Sinon.stub GitStatusUtils, "_fetchStatus", => testInputData
      @parsedStatus = GitStatusUtils.getStatus("./")

    it "should have parsed expected attributes", ->
      expected = 
        branch: "master"
        commitsAheadBehind: 0
        remote: "origin/master"
      @parsedStatus.should.containSubset expected
      
    it "should not have found any files", ->
      @parsedStatus.stagedChanges.length.should.equal 0
      @parsedStatus.unstagedChanges.length.should.equal 0
      @parsedStatus.untrackedFiles.length.should.equal 0

    after ->
      GitStatusUtils._fetchStatus.restore()
      
      
  describe "when parsing output with no origin", ->
    before ->
      testInputData = Fs.readFileSync(Path.join(__dirname, 'data', 'gitStatusNoOrigin.txt')).toString()
      Sinon.stub GitStatusUtils, "_fetchStatus", => testInputData
      @parsedStatus = GitStatusUtils.getStatus("./")

    it "should have parsed expected attributes", ->
      expected = 
        branch: "development"
        commitsAheadBehind: 0
        remote: undefined
      @parsedStatus.should.containSubset expected

    after ->
      GitStatusUtils._fetchStatus.restore()
      
      
  describe "when parsing output with commits ahead of origin", ->
    before ->
      testInputData = Fs.readFileSync(Path.join(__dirname, 'data', 'gitStatusAheadOfMaster.txt')).toString()
      Sinon.stub GitStatusUtils, "_fetchStatus", => testInputData
      @parsedStatus = GitStatusUtils.getStatus("./")

    it "should have parsed expected attributes", ->
      expected = 
        branch: "master"
        remote: "origin/master"
        commitsAheadBehind: 1
      @parsedStatus.should.containSubset expected
      
    it "should have only found unstaged changes", ->
      @parsedStatus.stagedChanges.length.should.equal 0
      @parsedStatus.untrackedFiles.length.should.equal 0

      @parsedStatus.unstagedChanges.length.should.equal 1
      @parsedStatus.unstagedChanges[0].should.equal 'modified: lib/publish.coffee'

    after ->
      GitStatusUtils._fetchStatus.restore()
      

