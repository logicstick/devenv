[![Build Status](https://travis-ci.org/logicstick/devenv.png?branch=master)](https://travis-ci.org/logicstick/devenv)

Development Environment
=========================


Goals

1. Open Souce Tool kits
1. Testing Functionality 
1. Simulation functionality
1. Continous Integration support from hudson ci or travis ci


List of archieved branches are in [Archive](./ARCHIEVE])


###How to merge features

1. Create a seperate branch for a feature
1. Do implement the work in that perticular branch
1. After implmenting come back to the master branch
1. Merge the final work with the master branch
  
  git merge --no-ff <branchname>

1. Do this till the feature has been added
1. After feature has been added archive the branch



###How to archive a branch

I believe the proper way to do this is to tag the branch. If you delete the branch after you have tagged it then you've effectively kept the branch around but it won't clutter your branch list.

If you need to go back to the branch just check out the tag. It will effectively restore the branch from the tag.

To archive and delete the branch:

  git tag archive/<branchname> <branchname>
  git branch -d <branchname>
To restore the branch some time later:

  git checkout -b <branchname> archive/<branchname>

The history of the branch will be preserved exactly as it was when you tagged it.