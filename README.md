# Overview

This is a fork of pgporadas ansible boilerplate script with some of my own preferences on top

- - - -
# Usage

I personally choose to put this script in my `$PATH` so that I can call it from anywhere.

If you do not want to put the script on the $PATH, run the script as follows

    ./ansible-ftl.sh

You will then be prompted as follows

    phil at laptappy in ~ on master▲
    $ ./ansible-ftl.sh
    +) Name of the ansible role? Example: /home/phil/ansible-role-httpd or ansible-role-nomad-jobs [ENTER]
    ansible-role-mytest
    +) What software license do you want to use? Example: MIT or GPL 3.0 [ENTER]
    MIT
    +) Is this correct? [Y/n] [ENTER]
    y
    +) Creating folder ansible-role-mytest
    Initialized empty Git repository in /home/phil/ansible-role-mytest/.git/

The standard way I use these new roles is to

    cd ansible-role-mytest
    # Do git related things
    # Alter the role files
    # Finally test as follows
    bundle update
    bundle exec kitchen create
    bundle exec kitchen converge
    bundle exec kitchen verify
    bundle exec kitchen destroy

- - - -
# Structure of a new role

```
$ tree -aF -I .git
.
├── defaults/
│   └── main.yml
├── files/
├── Gemfile
├── Gemfile.lock
├── .gitignore
├── handlers/
│   └── main.yml
├── .kitchen.yml
├── meta/
│   └── main.yml
├── README.md
├── tasks/
│   ├── install.yml
│   └── main.yml
├── templates/
├── test/
│   └── integration/
│       └── default/
│           ├── bats/
│           │   ├── 01_test.bats
│           │   └── 99_idempotence.bats
│           └── default.yml
└── .vagrant.rb

10 directories, 14 files
```
- - - -

# Original Author:
(c) 2016 Phil Porada - philporada@gmail.com
