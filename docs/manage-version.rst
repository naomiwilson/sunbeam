.. _manage-version:

=================
manage-version.sh
=================

.. contents::
   :depth: 2

Overview
========

This script enables users of sunbeam to easily switch between different 
versions of sunbeam; automatically managing the environments and the code  
branches/tags. Sunbeam is designed such that you can have multiple versions 
installed at the same time, either in one repository or in multiple. The 
simpler option is to simply install each version of sunbeam that you want 
in separate directories (i.e. you could have ``sunbeam2``, ``sunbeam3``, 
and ``sunbeam4`` directories, each containing a separate installation of 
sunbeam). If you prefer to keep everything in one directory, this script 
allows you to change versions in place.

The most common use case will be once you've had sunbeam installed for a while 
and new versions have come out, you can easily upgrade to the latest version 
by running ``./manage-version.sh -s stable``. This will update your code, install 
the newest environment, and then give you instructions for how to activate it.

Options
=======

All available options for the command line, used with ``./manage-version.sh [options]``.

-l/--list [arg]
++++++++++++++++++++++++

List all [installed] or all [available] versions of sunbeam. The [installed] 
argument will search your local conda environments for the prefix 'sunbeam'. 
The [available] argument will list available release tags and developement 
branches.

-a/--active
++++++++++++++

List environment for the code currently installed (active branch tag). I.e. 
this will get the current git tag and display the appropriate environment.

-c/--clean
+++++++++++++

Remove all auxiliary sunbeam conda environments. These will typically be stored 
in ``$SUNBEAM_DIR/.snakemake/`` and can take up space, especially if you're a 
developer and make changes to environment files often.

.. tip::

    The next time running sunbeam after ``./manage-version.sh --clean`` will 
    take longer because it has to remake some of the cleaned environments.

-s/--switch [arg]
++++++++++++++++++++++++++

Switch to a new version of sunbeam (install if not installed). This version 
argument can be 'dev', 'stable', any other branch name, or any version tag. 
A list of available versions can be shown with 
``./manage-version.sh -l available``.

-r/--remove [arg]
++++++++++++++++++++++++++

Uninstall the specified version of sunbeam. A list of installed versions can 
be shown with ``./manage-version.sh -l installed``.

-v/--verbose
+++++++++++++++

Show subcommand output.

-d/--debug
+++++++++++++

Run in debug mode.

-h/--help
++++++++++++

Display help message.

.. _manual-version-management:
Manual Version Management
=========================

Sunbeam was developed to only need one installation and still support using any 
of its versions. The two tools you will need to understand in order to manually 
switch between sunbeam versions are git and conda. Git is used to switch 
between versions of the code while conda is used to switch between execution 
environments for that code.

.. tip::

    This is the recommended method for developers of sunbeam. While the script 
    provides useful utilities, it can become a nuisance if you're making a lot 
    of updates to the code as it will keep trying to make new environments 
    when you switch.

As an example, let's say you've just installed sunbeam following the quickstart 
guide. At this point you should have code that is on the 'stable' branch and 
an environment called something like 'sunbeamX.X.X'. You can verify this by 
running ``git status`` and ``echo $CONDA_DEFAULT_ENV`` (provided your environment 
is activated).

But now you want to switch to the developement branch. The first step is to 
``git checkout dev``, switching your code to the dev branch. Next, run 
``conda deactivate``, deactivating your current environment, then to create 
the new 'dev' environment run, ``./install.sh -e sunbeamX.X.X-dev`` (you can 
also use the suggested env name given by ``git describe --tag`` but that will 
change every commit). If the install script succeeds, it should finish by 
giving instructions on how to activate your new environment and you're good to 
go.

.. tip::

    Check out the code for manage-version.sh if you're ever unsure of how to 
    do something, it can be a good reference.

Troubleshooting
===============

The manage-version.sh script uses `git` to manage the version of the code but 
is itself part of the code. To keep the script functional no matter what 
version you're switching to, it will do some git magic to first checkout the 
new version and then immediately switch the version of the script to the 
latest stable release. This means that whenever you switch to a version that 
isn't the latest stable release there will be a staged change for the script 
(you can see with `git status`). As long as you're not making other changes to 
the code, this shouldn't be an issue.

If you do make changes to a version, before switching you should either commit 
or stash these changes but not the changes to manage-version.sh. Once you only 
have the script as a change you can use the script as normal.

If you do make a mistake and end up deleting or downgrading manage-version.sh, 
either 1) run `git checkout stable manage-version.sh` OR 2) commit or stash 
any changes you want to keep and run `git checkout stable` to get back to the 
latest release (you can get the environment associated with this branch with 
`./manage-version.sh -a`).