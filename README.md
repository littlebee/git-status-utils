# git-status-utils

javascript utilities for parsing information from git status command

### Installation
```
npm install --save git-status-utils
```

### Usage

```javascript

GitStatusUtils = require('git-status-utils')
console.log(GitStatusUtils.getStatus())

```

Should output a javascript object that looks like below.   
See [API Docs on Github.io](http://littlebee.github.io/git-status-utils/docs/api) for the current details.

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