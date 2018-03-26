# Contributing to Engine Yard v5 Cookbooks repository

We're glad you want to contribute to a Engine Yard v5 Cookbooks repository ! This document will help answer common questions you may have during your first contribution.

## Steps required for Pull Request submitting

1. Ensure you are working in a branch in <b>ey-cookbooks-stable-v5</b>
 * Please do not fork to another repository, as this can prevent us from
   making minor changes to your code that may otherwise prevent your commit
   from being accepted.
 * The branch should be named after the feature being worked on. Ticket id (For example: CC-1123 ) should be used instead of feature name if you are Engine Yard employee.
2. Rebase your branch against the most recent version of the master branch:
  * `git fetch --all && git rebase -i origin/master`
  * Squash all the commits down to a single commit, with a summary commit
    message with the ticket as a prefix
    (e.g.: [CC-199] Enables users to ..."
3. Use the following Pull Request template in the description field

```
Description of your patch
-------------

Recommended Release Notes
-------------

Estimated risk
-------------

Components involved
-------------

Description of testing done
-------------

QA Instructions
-------------
```

_Notes:_
For "Estimated risk", specify low, medium or high, and justify your selection.
"Components involved" should list not the files changed, but the area of work (i.e.: a region specific change, customers on ruby 1.8.7, all node customers, etc)

## Steps after submitting your Pull Request

1. Update the ticket to 'Pull Request' status, and add a link to the pull
   request
1. Do not continue to do work in the branch used for the pull request -- PRs
   are automatically updated with any changes
1. Monitor your pull request for updates.  Your pull request will be reviewed
   on or before each Thursday at 8:30 am Pacific.  Any deficiencies found must
   be rectified by 12:pm Pacific to make it into that week's release.
