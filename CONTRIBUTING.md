# Contributing 

Whether you've got a bugfix, documentation update, or new feature for us, these are the steps to follow to contribute code back into the main trisquel repo.

## 1. Prerequisites



 1. Install needed packages for both, sources and binary builds
```
sudo apt-get install  dpkg-dev devscripts git pbuilder quilt patch sed rpl parsewiki
```

 1. Configure build environment for binary packages
```
git clone https://devel.trisquel.info/trisquel/trisquel-builder.git
ln -s $(readlink -f trisquel-builder/pbuilderrc) ~/.pbuilderrc
sudo ln -s $(readlink -f trisquel-builder/hooks) /var/cache/pbuilder/hooks.d
```

 1. Create the build environment for each distribution/architecture you want to work with
```
sudo BUILDDIST=belenos BUILDARCH=amd64 pbuilder create 
```


## 2. Get the latest code from gitlab

You'll need to understand a little bit about how git and gitlab work before this step (GitHub works the same way, but we like free software). In simple terms, log in [here](https://devel.trisquel.info/users/sign_in?redirect_to_referer=yes), visit the [trisquel/package-helpers project page](https://devel.trisquel.info/trisquel/package-helpers), and click the "fork" button to create your own copy of the repo.  You will push your changes to this new repo under your own git account, and we will pull changes into the main repo from there.

For the sake of the rest of the examples in this guide, we're going to assume your gitlab username is "**richardtorvalds**" and you will be working with the  "**hello**" package, and use those in our examples.

Now, we want to grab the latest from this newly created repository and pull it down to your local machine. Getting the latest code from your repo is simple, just clone it:

```bash
git clone https://devel.trisquel.info/richardtorvalds/package-helpers.git
cd package-helpers
```

This will give you a directory called "package-helpers" on your local machine with the latest checkout from your fork of the main package-helpers repo. **Note:** this is *not* a direct reference to the main trisquel repo. When you make changes in your fork, you'll need to let us know about it so we can pull it over....but that's later in the process.

## 3. Add a remote for the main package-helpers repo

One thing you'll need to do to make things easier to integrate and keep up to date in your fork is to add the main repo as a remote reference. This way you can fetch the latest code from the production version and integrate it. So, here's how to set that up:

```bash
git remote add upstream https://devel.trisquel.info/trisquel/package-helpers.git
git remote   (this will list out your remotes, showing the new one we added)
```

Then, when you need to pull the latest from the main trisquel repo, you just fetch and merge the master branch:

```bash
git fetch upstream
git merge upstream/belenos
```

You can also use *git pull upstream belenos* if you want it all in one step.

## 4. Making a branch for your changes

When adding features or bug fixes, please create a separate branch for each changeset you want us to pull in, either with the issue number in the branch name or with an indication of what the feature is (feature, bugfix...). 

```bash
git branch   (lists your current branches)
git checkout -b bugfix-hello   (makes a new branch called bugfix-hello)
```


## 5. Building the source package

If you want to create a new package, apache2 is a good starting point, so:
```
cd helpers
cp make-apache2 make-hello
```

For importing free packages from ppa's or other sources, check [make-toxcore](https://devel.trisquel.info/trisquel/package-helpers/blob/belenos/helpers/make-toxcore) and update the _EXTERNAL_ , _SIGNKEY_ and _changelog_ lines  with your own values.

Then, run the helper with
```
bash make-hello
```

If everything goes fine, you will have your new source package ready at _PACKAGES/hello/_

## 6. Build and test the binary package

The last step generated a source package file, so we need to build the binary one:
```
sudo BUILDDIST=belenos BUILDARCH=amd64 pbuilder build PACKAGES/hello/*.dsc
```

The binary packages will be avaliable at _/var/cache/pbuilder/jenkins-repos/$BUILDDIST/_


## 7. Push your code and make a pull request

When you have finished making your changes, you'll need to push up your changes to your fork so we can grab them. With them all committed, push them:

```bash
git push origin bugfix-hello
```

This pushes everything in that branch up. Then you can go back to your forked package-helpers gitlab page and issue a pull request from there.  Tell us what you want us to merge and what it does/fixes, and one of us will pick it up.

That lets us know that there's something new from you that needs to be pulled in. We'll review it and get back to you about it if we have any questions. Otherwise, we'll integrate it and let you know when it's in!


Hope this guide helps you get started in contributing to the trisquel project! If you still have questions, don't hesitate to join us on IRC - we're in #trisquel-dev on freenode -, or send a mail to the development mailing list trisquel-devel at listas.trisquel.info.

   
