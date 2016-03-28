
ChildProcess = require "child_process"
Path = require "path"
Fs = require "fs"

_ = require('underscore')
Str = require "bumble-strings"


module.exports = class GitStatusUtils 

  ###
    Returns a javascript object of information from calling git status, like: 
    ```
    {
      branch: "master"
      remote: "origin/master"
      commitsAheadBehind: -5
      stagedChanges: [
        "new file: docs/api/index.html"
        "modified: package.json"
        ...
      ]
      unstagedChanges: [{
        "deleted: relative/path/to/file.ext"
        ...
      }]
      untrackedFiles: [
        "path/to/file.txt"
        "another-path/to/file.txt"
        ...
      ]
    }
    ```
    Not that remote and commitsAheadBehind are not always given by git status, for example, 
    files a local branch with no tracking remote
  ###
  @getStatus: (dirName) ->
    rawStatus = @_fetchStatus(dirName)
    return @_parseGitStatus(rawStatus)
    
    
  # Implementation
    

      
  @_fetchStatus: (directory) ->
    flags = ""
    cmd = "cd #{directory} && git status#{flags}"
    # console.log '$ ' + cmd
    return ChildProcess.execSync(cmd, {stdio: 'pipe' }).toString()
    

  @FILE_BLOCKS: [{
    match: /Changes to be committed.*/
    attr: "stagedChanges"
  },{
    match: /Changes not staged.*/
    attr: "unstagedChanges"
  },{
    match: /Untracked.*/
    attr: "untrackedFiles"
  }]

    
  @_parseGitStatus: (rawOutput) ->
    lines = rawOutput.split('\n')
    
    # console.log "_parseGitStatus", lines
    [match, branch] = matches = lines[0].match /On branch (.*)/i
    if matches?.length > 0
      branch = matches[1]
      lines = lines.slice(1)
    else
      branch = null  
    
    matches = lines[0].match(/branch is (up to date|[^\s]*)\s*(of|with)?\s*[\'\"]([^\'\"]*)[\'\"](\s*by (\d*) commit)?/i)
    #console.log "line:", lines[1], 'matches:', matches
    if matches?
      [match, status, ofWith, remote, affix, commitCount] = matches
      lines = lines.slice(1)
      commitsOff = switch status
        when 'ahead' then parseInt(commitCount)
        when 'behind' then parseInt(commitCount) * -1
        else 0
    else
      commitsOff = 0
    
    statusOut = {
      branch: branch
      remote: remote
      commitsAheadBehind: commitsOff
      stagedChanges: []
      unstagedChanges: []
      untrackedFiles: []
    }
    # console.log 'statusOut', statusOut
    currentFileBlock = null
    for line in lines
      isNewFileBlock = false
      line = Str.trim(line, all: true)
      for fileBlock in @FILE_BLOCKS
        #console.log "line is:", line
        #console.log "fileBlock:", fileBlock
        if line.match(fileBlock.match)?.length > 0
          currentFileBlock = fileBlock
          isNewFileBlock = true
          break
      
      continue unless currentFileBlock?
      continue if isNewFileBlock || line.match(/\s*\(.*\).*/) || line.length == 0
      statusOut[currentFileBlock.attr].push line
          
    return statusOut
    
        
        