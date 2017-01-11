use strict;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Jmespath',
    VERSION_FROM  => 'lib/Jmespath.pm',
    ABSTRACT_FROM => 'lib/Jmespath.pm',
    AUTHOR        => 'Richard Elberger',
    INSTALLDIRS   => ($] < 5.011 ? 'perl' : 'site'),
    PREREQ_PM => {
                  'Try::Tiny'      => 0,
                  'File::Slurp'    => 0,
                  'Moose'          => 0,
                  'JSON'           => 0,
                  'String::Util'   => 0,
                  'Ref::Util'      => 0,
		  'List::Util'     => "1.46",
    },
    clean => {
        FILES => 'cover_db test-*',
    },
    (eval { ExtUtils::MakeMaker->VERSION(6.46) } ? ( META_MERGE => {
      'meta-spec' => { version => 2 },
      resources => {
        repository  => {
          url  => 'https://github.com/rpcme/jmespath.pl',
          web  => 'https://github.com/rpcme/jmespath.pl',
          type => 'git',
        },
      },
      license => 'perl',
    }) : () ),
);
