requires 'Try::Tiny';
requires 'File::Slurp';
requires 'Moose';
requires 'JSON';
requires 'String::Util';
requires 'List::Util';

on develop => sub {
  requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
  requires 'Dist::Zilla::Plugin::VersionFromModule';
  requires 'Dist::Zilla::PluginBundle::Git';
  requires 'Dist::Zilla::Plugin::RunExtraTests';
};
