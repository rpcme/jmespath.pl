requires 'perl' => '5.014000';
requires 'Try::Tiny';
requires 'File::Slurp';
requires 'Moose';
requires 'JSON';
requires 'String::Util';
requires 'List::Util', '1.42';

on develop => sub {
  requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
  requires 'Dist::Zilla::Plugin::VersionFromModule';
  requires 'Dist::Zilla::PluginBundle::Git';
  requires 'Dist::Zilla::Plugin::RunExtraTests';
};
