jmespath.pl
============
[![Build Status](https://travis-ci.org/rpcme/jmespath.pl.svg?branch=master)](https://travis-ci.org/rpcme/jmespath.pl)
[![Coverage Status](https://coveralls.io/repos/rpcme/jmespath.pl/badge.svg)](https://coveralls.io/r/rpcme/jmespath.pl)
[![CPAN version](https://badge.fury.io/pl/Jmespath.svg)](http://badge.fury.io/pl/Jmespath)

Repository for the [Jmespath](http://jmespath.org) for Perl implementation.

See the [Changes](Changes) file for release notes.

About
------

[JMESPath](http://jmespath.org) is a query language for JSON.  This
repository is the JMESPath implementation for
the [Perl](http://perl.org) programming language.

Installation
--------------

Although you can install from Github, certainly the better way is to
install using CPAN.

```bash
$ cpan Jmespath
```

Usage
------

JMESPath releases with the command line utility ```jp```.

```bash
$ curl -s -XPOST https://fastapi.metacpan.org/v1/author/RICHE | \
    perl -I lib/ script/jp email
"["riche@cpan.org"]"
```

To remove the quotes, use the JP_UNQUOTED environment variable.

```bash
$ curl -s -XPOST https://fastapi.metacpan.org/v1/author/RICHE | \
    JP_UNQUOTED=1 perl -I lib/ script/jp email
["riche@cpan.org"]
```

Rather,

```bash
$ curl -s -XPOST https://fastapi.metacpan.org/v1/author/RICHE | \
    JP_UNQUOTED=1 perl -I lib/ script/jp email[0]
riche@cpan.org
```

With full JMESPath compliance, for example:

```bash
$  curl -s -XPOST https://fastapi.metacpan.org/v1/author/RICHE | \
    JP_UNQUOTED=1 perl -I lib/ script/jp "email[0].length(@)"
14
```
