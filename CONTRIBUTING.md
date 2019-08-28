# Contributing

Whether you've got a bug fix, documentation update, or new feature for us, these are the steps to follow to contribute code back into the main Trisquel repository.

## 1. Prerequisites

 1. Install needed packages for both, sources and binary builds
```
sudo apt-get install dpkg-dev devscripts git quilt patch sed rpl parsewiki
```

 1. Configure build environment for binary packages
```
git clone https://devel.trisquel.info/trisquel/trisquel-builder.git
```

Follow the instructions in the [README.md](https://devel.trisquel.info/trisquel/trisquel-builder/blob/master/README.md) file of the repository just cloned.

## 2. Get the latest code from GitLab

You'll need to understand a little bit about how git and GitLab work before this step (GitHub works the same way, but we like free software). In simple terms, log in [our GitLab instance](https://devel.trisquel.info/users/sign_in?redirect_to_referer=yes), visit the [trisquel/package-helpers project page there](https://devel.trisquel.info/trisquel/package-helpers), and click the "Fork" button to create your own copy of the repo. You will push your changes to this new repo under your own GitLab account, and we will pull changes into the main repo from there.

For the sake of the rest of the examples in this guide, we're going to assume your GitLab account is "**richardtorvalds**" and you will be working with the "**hello**" package, and use those in our examples.

Now, we want to grab the latest from this newly created repository and pull it down to your local machine. Getting the latest code from your repository is simple, just clone it and go inside:

```bash
git clone https://devel.trisquel.info/richardtorvalds/package-helpers.git
cd package-helpers
```

This will give you a directory called "package-helpers" on your local machine with the latest checkout from your fork of the main package-helpers repository. **Note:** this is *not* a direct reference to the main trisquel repository. When you make changes in your fork, you'll need to let us know about it so we can pull it over... but that's later in the process.

## 3. Add a remote for the main package-helpers repository

One thing you'll need to do to make things easier to integrate and keep up to date in your fork is to add the main repository as a remote reference. This way you can fetch the latest code from the production version and integrate it. So, here's how to set that up:

```bash
git remote add upstream https://devel.trisquel.info/trisquel/package-helpers.git
git remote
```

The last part will list out your remotes, showing the new one we added.

Then, when you need to pull the latest from the main trisquel repository, you just fetch and merge the master branch:

```bash
git fetch upstream
git merge upstream/master
```

You can also use *git pull upstream master* if you want it all in one step.

## 4. Making a branch for your changes

When adding features or bug fixes, please create a separate branch for each set/subject of changes you want us to pull in, either with the issue number in the branch name or with an indication of what the feature is (example: feature, bug fix).

To list all branches made so far, do:
```bash
git branch
```

Now, as an example, to make a branch for a bug fix called `bugfix-hello`, do:
```bash
git checkout -b bugfix-hello
```

## 5. Building the source package

If you want to create a new help for, say, the `hello` package, the `make-apache2` file is a good starting point, so:
```bash
cd helpers
cp make-apache2 make-hello
```

This goes to the `helpers` directory and copies `make-apache2` to `make-hello`. From now one you can make changes to `make-hello` when needed.

For importing free packages from PPA's or other sources, check [make-toxcore](https://devel.trisquel.info/trisquel/package-helpers/blob/belenos/helpers/make-toxcore) and update the _EXTERNAL_ , _SIGNKEY_ and _changelog_ lines  with your own values.

Once the changes are done, prepare the source package by running the helper with
```bash
bash make-hello
```

If everything goes fine, you will have your new `.DSC` source package ready at `PACKAGES/hello`.

## 6. Build and test the binary package

The last step generated a source package file, so we need to build the binary one.

First switch to the `PACKAGES/hello` directory.
```bash
cd PACKAGES/hello
```

Then, as is pointed out in the [README.md](https://devel.trisquel.info/trisquel/trisquel-builder/blob/master/README.md) of the trisquel-builder repository, you can do so by doing the following:
```bash
sbuild -v --dist $CODENAME --arch $ARCH $PACKAGE_DSC_FILE
```
Or as follows if you also want to build the architecture-independent packages:
```bash
sbuild -v --dist $CODENAME --arch $ARCH --arch-all $PACKAGE_DSC_FILE
```

Keep in mind that in both the last command suggestions, `$CODENAME` and `$ARCH` must be replaced by you since they are the codename of the Trisquel release and the architecture that you want to test against (to see the host architecture, that is the one your system is on, you can use `dpkg --print-architecture`), and for this to work, a `schroot` matching both `$CODENAME` and `$ARCH` must be available - which should be all set if all went well when following the [README.md](https://devel.trisquel.info/trisquel/trisquel-builder/blob/master/README.md) of trisquel-builder (see `schroot --list`). Besides this, `$PACKAGE_DSC_FILE` must be manually replaced with the name of a `.DSC` file that was created by `sbuild` in the previous section.

Having said that, both the alternative commands above should put all the `.DEB` packages in the same directory, including or excluding the architecture-independent ones, respectively to which of the previous command alternatives were used.

From now on you can either install the packages in the Trisquel installation you're using or, if there is an issue with the result, use a testing session as optionally advised in the next session.

After testing, considering that all went well, you can jump to the last section.

## 7. Installing the packages in a testing session

Sometimes the issues with a given package vary depending on the environment, and in such cases it's a good idea to test it inside a `schroot` session.

To do so, begin the session and get its location as follows:
```bash
TEST_SCHROOT_SESSION=$(schroot --begin-session -c $CODENAME-$ARCH)
TEST_SCHROOT_SESSION_PATH=$(schroot --location -c session:$TEST_SCHROOT_SESSION)
echo $TEST_SCHROOT_SESSION_PATH
```

This should output a path, for future reference, it will be available for you in the variable `$TEST_SCHROOT_SESSION_PATH`, as well as the session identity in `$TEST_SCHROOT_SESSION`.

To install the packages, you must copy the `.DEB` files from `PACKAGES/hello` to a place inside `$TEST_SCHROOT_SESSION_PATH`, like so:
```bash
sudo cp -t $TEST_SCHROOT_SESSION_PATH/root *.deb
```

In the example above, all the `.DEB` files are copied to `$TEST_SCHROOT_SESSION_PATH/root`.

It's time to run the session, first as root, in order to install the packages, like so:
```bash
schroot -r -c $TEST_SCHROOT_SESSION -u root
```

In the new shell, the installation is first done by adding the files of the packages to do so, then using the repositories to fix these according to the dependencies needed, as follows:
```bash
dpkg -i /root/*.deb
apt-get -f install
```

The `dpkg` command might end with errors, but those can be ignored. `apt-get` may ask permission to download packages, which in most cases is expected. If all the packages built are installed and configured, `apt-get` mustn't exit with errors.

If all went well so far, now is time to decide if the package needs super user/root permissions or not. If the privileged access is needed, exit by either using the `exit` command or by typing Ctrl + D. Then, switch user by doing the following:
```bash
schroot -r -c $TEST_SCHROOT_SESSION
```

This continues the session as normal user.

From now on, you can take the necessary steps to test the package.

Considering that the job is done and being aware that all changes will be lost, exit the `schroot` session and do:
```bash
schroot -e -c $TEST_SCHROOT_SESSION
```

## 8. Commit/register the changes, push your code and make a pull request

When you have finished making your changes, you'll need to push up your changes to your fork so we can grab them.

Now it's required that you commit/register the changes and add a detailed comment of what was done, both can be done by manually adding the files to be committed with `git add`, like so:
```bash
git add ../../make-hello
```

When all the new or changed files are added, make the commit with the following example command:
```bash
EDITOR=pluma git commit
```

Inside the Pluma text editor tab that opened, in the first uncommented line make a summary of what was done, like an email subject, then in the other lines describe in detail what was done.

With all commits done, push them with:
```bash
git push origin bugfix-hello
```

This pushes everything in that branch up. Then you can go back to your forked package-helpers GitLab page and issue a pull request from there. Tell us what you want us to merge and, if you haven't done so in the commit messages, what it does/fixes, and one of us will pick it up.

That lets us know that there's something new from you that needs to be pulled in. We'll review it and get back to you about it if we have any questions. Otherwise, we'll integrate it and let you know when it's in!

Hope this guide helps you get started in contributing to the Trisquel project! If you still have questions, don't hesitate to join us on IRC - we're in #trisquel-dev on Freenode -, or send a mail to the development mailing list trisquel-devel at listas.trisquel.info.
