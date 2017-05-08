# make sure we are inside a valid git dir
git rev-parse --is-inside-work-tree

# important: it is utmost important that both FL4RE_PUBLISH_BRANCH@HEAD and git tag of the new patched version
# are atomically commited.  We ensure this by checking out the branch and managing the changes ourselves (instead)
# of through 'npm version patch'.  If we could be guaranteed that 'npm publish' can return without failure, we can
# reduce this script to 2 lines of code i.e. version patch & npm publish.  But we make no such assumption.  This 
# is similar to how we do StarVR SDK.  
# The most important thing is nothing is commited to master while a publish is in progress

# since jenkins git plugin checks out to a headless branch, we need to indeed checkout to a named branch, master
# since later we will be comitting it
git checkout $FL4RE_PUBLISH_BRANCH
# merge whatever changes there still be from origin/master.  We do this because while the headless branch would 
# be latest cause that's how the plugin works on it, the named branch may not be.  Since origin/master is 
# definitely pulled, we can use it
git merge origin/$FL4RE_PUBLISH_BRANCH

# npm version patch w/o git actions and obtain the new patch version that appears in the changed package.json file
FL4RE_TAGGED_VERSION=$(npm --no-git-tag-version version patch)

# fianlly npm publish the new version 
npm publish

# all good, so now commit back the package.json and create a tag for this version
git add package.json
git commit -m "$FL4RE_TAGGED_VERSION"
git tag -a $FL4RE_TAGGED_VERSION -m "$FL4RE_TAGGED_VERSION"

# we'll need GH credentials to do the push
set +x
echo "https://$FL4RE_GH_USERNAME:$FL4RE_GH_PASSWORD@github.com" > $WORKSPACE/gh.credentials
set -x
git config --global credential.helper "store --file=\"$WORKSPACE/gh.credentials\""
# here we do an atomic push of the tag & branch
git push --atomic origin refs/heads/$FL4RE_PUBLISH_BRANCH refs/tags/$FL4RE_TAGGED_VERSION
git config --global --remove-section credential
rm $WORKSPACE/gh.credentials

exit 0

