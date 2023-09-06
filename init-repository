#!/usr/bin/env perl
# Copyright (C) 2015 The Qt Company Ltd.
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR LGPL-3.0-only OR GPL-2.0-only OR GPL-3.0-only

use v5.8;
use strict;
use warnings;

package Qt::InitRepository;


sub printUsage($)
{
    my ($ex) = @_;

    print <<EOF ;
Usage:
      ./init-repository [options]

    This script may be run after an initial `git clone' of Qt5 in order to
    check out all submodules. It fetches them from canonical URLs inferred
    from the clone's origin.

Options:
  Global options:

    --force, -f
        Force initialization (even if the submodules are already checked
        out).

    --force-hooks
        Force initialization of hooks (even if there are already hooks in
        checked out submodules).

    --quiet, -q
        Be quiet. Will exit cleanly if the repository is already
        initialized.

  Module options:

    --module-subset=<module1>,<module2>...
        Only initialize the specified subset of modules given as the
        argument. Specified modules must already exist in .gitmodules. The
        string "all" results in cloning all known modules. The strings
        "essential", "addon", "preview", "deprecated", "obsolete",
        "additionalLibrary", and "ignore" refer to classes of modules
        identified by "status=" lines in the .gitmodules file.
        You can use "default" in the subset as a short-hand for
        "essential,addon,preview,deprecated", which corresponds to the set of
        maintained modules included in standard Qt releases; this is also the
        default module subset when this option is not given. Entries
        may be prefixed with a dash to exclude them from a bigger
        set, e.g. "all,-ignore".

    --no-update
        Skip the `git submodule update' command.

    --no-fetch
        Skip the `git fetch' commands. Implied by --no-update.

    --branch
        Instead of checking out specific SHA1s, check out the submodule
        branches that correspond with the current supermodule commit. By
        default, this option will cause local commits in the submodules to
        be rebased. With --no-update, the branches will be checked out, but
        their heads will not move.

    --ignore-submodules
        Set git config to ignore submodules by default when doing operations
        on the qt5 repo, such as `pull', `fetch', `diff' etc.

        After using this option, pass `--ignore-submodules=none' to git to
        override it as needed.

  Repository options:

    --berlin
        Switch to internal URLs and make use of the Berlin git mirrors.
        (Implies `--mirror').

    --oslo
        Switch to internal URLs and make use of the Oslo git mirrors.
        (Implies `--mirror').

    --codereview-username <Gerrit/JIRA username>
        Specify the user name for the (potentially) writable `gerrit' remote
        for each module, for use with the Gerrit code review tool.

        If this option is omitted, the gerrit remote is created without a
        username and port number, and thus relies on a correct SSH
        configuration.

    --alternates <path to other Qt5 repo>
        Adds alternates for each submodule to another full qt5 checkout.
        This makes this qt5 checkout very small, as it will use the object
        store of the alternates before unique objects are stored in its own
        object store.

        This option has no effect when using `--no-update'.

        NOTE: This will make this repo dependent on the alternate, which is
        potentially dangerous! The dependency can be broken by also using
        the `--copy-objects' option, or by running "git repack -a" in each
        submodule, where required. Please read the note about the `--shared'
        option in the documentation of `git clone' for more information.

    --copy-objects
        When `--alternates' is used, automatically do a "git repack -a" in
        each submodule after cloning, to ensure that the repositories are
        independent from the source used as a reference for cloning.

        Note that this negates the disk usage benefits gained from the use
        of `--alternates'.

    --mirror <url-base>
        Uses <url-base> as the base URL for submodule git mirrors.

        For example:

          --mirror user\@machine:/foo/bar/qt/

        ...will use the following as a mirror for qtbase:

          user\@machine:/foo/bar/qt/qtbase.git

        The mirror is permitted to contain a subset of the submodules; any
        missing modules will fall back to the canonical URLs.

EOF
    exit($ex);
}

use Carp         qw( confess             );
use Cwd          qw( getcwd abs_path     );
use English      qw( -no_match_vars      );
use File::Spec::Functions qw ( rel2abs   );
use Getopt::Long qw( GetOptions          );

my $script_path = abs_path($0);
$script_path =~ s,[/\\][^/\\]+$,,;

my $GERRIT_SSH_BASE
    = 'ssh://@USER@codereview.qt-project.org@PORT@/qt/';

my $BER_MIRROR_URL_BASE
    = 'git://hegel/qt/';

my $OSLO_MIRROR_URL_BASE
    = 'git://qilin/qt/';

sub new
{
    my ($class, @arguments) = @_;

    my $self = {};
    bless $self, $class;
    $self->parse_arguments(@arguments);

    return $self;
}

# Like `system', but possibly log the command, and die on non-zero exit code
sub exe
{
    my ($self, @cmd) = @_;

    if (!$self->{quiet}) {
        print "+ @cmd\n";
    }

    if (system(@cmd) != 0) {
        confess "@cmd exited with status $CHILD_ERROR";
    }

    return;
}

sub parse_arguments
{
    my ($self) = @_;

    %{$self} = (%{$self},
        'alternates'          => "",
        'branch'              => 0,
        'codereview-username' => "",
        'detach-alternates'   => 0 ,
        'force'               => 0 ,
        'force-hooks'         => 0 ,
        'ignore-submodules'   => 0 ,
        'mirror-url'          => "",
        'update'              => 1 ,
        'fetch'               => 1 ,
        'module-subset'       => "default",
    );

    GetOptions(
        'alternates=s'      =>  \$self->{qw{ alternates        }},
        'branch'            =>  \$self->{qw{ branch            }},
        'codereview-username=s' => \$self->{qw{ codereview-username }},
        'copy-objects'      =>  \$self->{qw{ detach-alternates }},
        'force|f'           =>  \$self->{qw{ force             }},
        'force-hooks'       =>  \$self->{qw{ force-hooks       }},
        'ignore-submodules' =>  \$self->{qw{ ignore-submodules }},
        'mirror=s'          =>  \$self->{qw{ mirror-url        }},
        'quiet'             =>  \$self->{qw{ quiet             }},
        'update!'           =>  \$self->{qw{ update            }},
        'fetch!'            =>  \$self->{qw{ fetch             }},
        'module-subset=s'   =>  \$self->{qw{ module-subset     }},

        'help|?'            =>  sub { printUsage(1);            },

        'berlin' => sub {
            $self->{'mirror-url'}        = $BER_MIRROR_URL_BASE;
        },
        'oslo' => sub {
            $self->{'mirror-url'}        = $OSLO_MIRROR_URL_BASE;
        },
    ) || printUsage(2);
    @ARGV && printUsage(2);

    # Replace any double trailing slashes from end of mirror
    $self->{'mirror-url'} =~ s{//+$}{/};

    $self->{'module-subset'} =~ s/\bdefault\b/preview,essential,addon,deprecated/;
    $self->{'module-subset'} = [ split(/,/, $self->{'module-subset'}) ];

    $self->{'fetch'} = 0 if (!$self->{'update'});

    return;
}

sub check_if_already_initialized
{
    my ($self) = @_;

    # We consider the repo as `initialized' if submodule.qtbase.url is set
    if (qx(git config --get submodule.qtbase.url)) {
        if (!$self->{force}) {
            exit 0 if ($self->{quiet});
            print "Will not reinitialize already initialized repository (use -f to force)!\n";
            exit 1;
        }
    }

    return;
}

sub git_submodule_init
{
    my ($self, @init_args) = @_;

    if ($self->{quiet}) {
        unshift @init_args, '--quiet';
    }
    $self->exe('git', 'submodule', 'init', @init_args);

    my $template = getcwd()."/.commit-template";
    if (-e $template) {
        $self->exe('git', 'config', 'commit.template', $template);
    }

    return;
}

use constant {
    STS_PREVIEW => 1,
    STS_ESSENTIAL => 2,
    STS_ADDON => 3,
    STS_DEPRECATED => 4,
    STS_OBSOLETE => 5,
    STS_ADDITIONAL => 6
};

sub has_url_scheme
{
    my ($url) = @_;
    return $url =~ "^[a-z][a-z0-9+\-.]*://";
}

sub git_clone_all_submodules
{
    my ($self, $my_repo_base, $co_branch, $alternates, @subset) = @_;

    my %subdirs = ();
    my %subbranches = ();
    my %subbases = ();
    my %subinits = ();
    my @submodconfig = qx(git config -l -f .gitmodules);
    foreach my $line (@submodconfig) {
        # Example line: submodule.qtqa.url=../qtqa.git
        next if ($line !~ /^submodule\.([^.=]+)\.([^.=]+)=(.*)$/);
        if ($2 eq "path") {
            $subdirs{$1} = $3;
        } elsif ($2 eq "branch") {
            $subbranches{$1} = $3;
        } elsif ($2 eq "url") {
            my ($mod, $base) = ($1, $3);
            if (!has_url_scheme($base)) {
                $base = $my_repo_base.'/'.$base;
            }
            while ($base =~ s,(?!\.\./)[^/]+/\.\./,,g) {}
            $subbases{$mod} = $base;
        } elsif ($2 eq "update") {
            push @subset, '-'.$1 if ($3 eq 'none');
        } elsif ($2 eq "status") {
            if ($3 eq "preview") {
                $subinits{$1} = STS_PREVIEW;
            } elsif ($3 eq "essential") {
                $subinits{$1} = STS_ESSENTIAL;
            } elsif ($3 eq "addon") {
                $subinits{$1} = STS_ADDON;
            } elsif ($3 eq "deprecated") {
                $subinits{$1} = STS_DEPRECATED;
            } elsif ($3 eq "obsolete") {
                $subinits{$1} = STS_OBSOLETE;
            } elsif ($3 eq "additionalLibrary") {
                $subinits{$1} = STS_ADDITIONAL;
            } elsif ($3 eq "ignore") {
                delete $subinits{$1};
            } else {
                die("Invalid subrepo status '$3' for '$1'.\n");
            }
        }
    }

    my %include = ();
    foreach my $mod (@subset) {
        my $del = ($mod =~ s/^-//);
        my $fail = 0;
        my @what;
        if ($mod eq "all") {
            @what = keys %subbases;
        } elsif ($mod eq "essential") {
            @what = grep { ($subinits{$_} || 0) eq STS_ESSENTIAL } keys %subbases;
        } elsif ($mod eq "addon") {
            @what = grep { ($subinits{$_} || 0) eq STS_ADDON } keys %subbases;
        } elsif ($mod eq "additionalLibrary") {
            @what = grep { ($subinits{$_} || 0) eq STS_ADDITIONAL } keys %subbases;
        } elsif ($mod eq "preview") {
            @what = grep { ($subinits{$_} || 0) eq STS_PREVIEW } keys %subbases;
        } elsif ($mod eq "deprecated") {
            @what = grep { ($subinits{$_} || 0) eq STS_DEPRECATED } keys %subbases;
        } elsif ($mod eq "obsolete") {
            @what = grep { ($subinits{$_} || 0) eq STS_OBSOLETE } keys %subbases;
        } elsif ($mod eq "ignore") {
            @what = grep { ($subinits{$_} || 0) eq 0 } keys %subbases;
        } elsif (defined($subdirs{$mod})) {
            push @what, $mod;
        } else {
            $fail = 1;
        }
        if ($del) {
            print "Warning: excluding non-existent module '$mod'.\n"
                if ($fail);
            map { delete $include{$_} } @what;
        } else {
            die("Error: module subset names non-existent '$mod'.\n")
                if ($fail);
            map { $include{$_} = 1; } @what;
        }
    }

    my @modules = sort keys %include;

    $self->git_submodule_init(map { $subdirs{$_} } @modules);

    # manually clone each repo here, so we can easily use reference repos, mirrors etc
    my @configresult = qx(git config -l);
    foreach my $line (@configresult) {
        # Example line: submodule.qtqa.url=git://code.qt.io/qt/qtqa.git
        next if ($line !~ /submodule\.([^.=]+)\.url=/);
        my $module = $1;

        if (!defined($include{$module})) {
            $self->exe('git', 'config', '--remove-section', "submodule.$module");
            next;
        }

        if ($self->{'ignore-submodules'}) {
            $self->exe('git', 'config', "submodule.$module.ignore", 'all');
        }
    }

    my $any_bad = 0;
    foreach my $module (@modules) {
        $any_bad = 1
            if ($self->git_stat_one_submodule($subdirs{$module}));
    }
    die("Dirty submodule(s) present; cannot proceed.\n")
        if ($any_bad);

    foreach my $module (@modules) {
        $self->git_clone_one_submodule($subdirs{$module}, $subbases{$module},
                                       $co_branch && $subbranches{$module}, $alternates);
    }

    if ($co_branch) {
        foreach my $module (@modules) {
            my $branch = $subbranches{$module};
            die("No branch defined for submodule $module.\n") if (!defined($branch));
            my $orig_cwd = getcwd();
            my $module_dir = $subdirs{$module};
            chdir($module_dir) or confess "chdir $module_dir: $OS_ERROR";
            my $br = qx(git rev-parse -q --verify $branch);
            if (!$br) {
                $self->exe('git', 'checkout', '-b', $branch, "origin/$branch");
            } else {
                $self->exe('git', 'checkout', $branch);
            }
            chdir("$orig_cwd") or confess "chdir $orig_cwd: $OS_ERROR";
        }
    }
    if ($self->{update}) {
        my @cmd = ('git', 'submodule', 'update', '--force', '--no-fetch');
        push @cmd, '--remote', '--rebase' if ($co_branch);
        $self->exe(@cmd);

        foreach my $module (@modules) {
            if (-f $module.'/.gitmodules') {
                my $orig_cwd = getcwd();
                chdir($module) or confess "chdir $module: $OS_ERROR";
                $self->git_clone_all_submodules($subbases{$module}, 0, "$alternates/$module", "all");
                chdir("$orig_cwd") or confess "chdir $orig_cwd: $OS_ERROR";
            }
        }
    }

    return;
}

sub git_add_remotes
{
    my ($self, $gerrit_repo_basename) = @_;

    my $gerrit_repo_url = $GERRIT_SSH_BASE;
    # If given a username, make a "verbose" remote.
    # Otherwise, rely on proper SSH configuration.
    if ($self->{'codereview-username'}) {
        $gerrit_repo_url =~ s,\@USER\@,$self->{'codereview-username'}\@,;
        $gerrit_repo_url =~ s,\@PORT\@,:29418,;
    } else {
        $gerrit_repo_url =~ s,\@[^\@]+\@,,g;
    }

    $gerrit_repo_url .= $gerrit_repo_basename;
    $self->exe('git', 'config', 'remote.gerrit.url', $gerrit_repo_url);
    $self->exe('git', 'config', 'remote.gerrit.fetch', '+refs/heads/*:refs/remotes/gerrit/*', '/heads/');
}

sub git_stat_one_submodule
{
    my ($self, $submodule) = @_;

    return 0 if (! -e "$submodule/.git");

    my $orig_cwd = getcwd();
    chdir($submodule) or confess "chdir $submodule: $OS_ERROR";

    my @sts = qx(git status --porcelain --untracked=no --ignore-submodules=all);

    # After a git clone --no-checkout, git status reports all files as
    # staged for deletion, but we still want to update the submodule.
    # It's unlikely that a genuinely dirty index would have _only_ this
    # type of modifications, and it doesn't seem like a horribly big deal
    # to lose them anyway, so ignore them.
    @sts = grep(!/^D  /, @sts);

    chdir($orig_cwd) or confess "cd $orig_cwd: $OS_ERROR";

    return 0 if (!@sts);

    print STDERR "$submodule is dirty.\n";

    return -1;
}

sub git_clone_one_submodule
{
    my ($self, $submodule, $repo_basename, $branch, $alternates) = @_;

    my $mirror_url            = $self->{ 'mirror-url'        };
    my $protocol              = $self->{ 'protocol'          };

    # `--reference FOO' args for the clone, if any.
    my @reference_args;

    if ($alternates) {
        # alternates is a qt5 repo, so the submodule will be under that.
        if (-e "$alternates/$submodule/.git") {
            @reference_args = ('--reference', "$alternates/$submodule");
        }
        else {
            print " *** $alternates/$submodule not found, ignoring alternate for this submodule\n";
        }
    }

    my $do_clone = (! -e "$submodule/.git");

    my $url = $repo_basename;
    if (!has_url_scheme($url)) {
        $url = $self->{'base-url'}.$url;
    }

    my $mirror;
    if (!has_url_scheme($repo_basename) && $mirror_url && ($do_clone || $self->{fetch})) {
        $mirror = $mirror_url.$repo_basename;
    }

    if ($mirror) {
        # Only use the mirror if it can be reached.
        eval { $self->exe('git', 'ls-remote', $mirror, 'test/if/mirror/exists') };
        if ($@) {
            warn "mirror [$mirror] is not accessible; $url will be used\n";
            undef $mirror;
        }
    }

    if ($do_clone) {
        if ($branch) {
            push @reference_args, '--branch', $branch;
        } else {
            push @reference_args, '--no-checkout';
        }
        $self->exe('git', 'clone', @reference_args,
                   ($mirror ? $mirror : $url), $submodule);
    }

    my $orig_cwd = getcwd();
    chdir($submodule) or confess "chdir $submodule: $OS_ERROR";

    if ($mirror) {
        # This is only for the user's convenience - we make no use of it.
        $self->exe('git', 'config', 'remote.mirror.url', $mirror);
        $self->exe('git', 'config', 'remote.mirror.fetch', '+refs/heads/*:refs/remotes/mirror/*');
    }

    if (!$do_clone && $self->{fetch}) {
        # If we didn't clone, fetch from the right location. We always update
        # the origin remote, so that submodule update --remote works.
        $self->exe('git', 'config', 'remote.origin.url', ($mirror ? $mirror : $url));
        $self->exe('git', 'fetch', 'origin');
    }

    if (!($do_clone || $self->{fetch}) || $mirror) {
        # Leave the origin configured to the canonical URL. It's already correct
        # if we cloned/fetched without a mirror; otherwise it may be anything.
        $self->exe('git', 'config', 'remote.origin.url', $url);
    }

    my $template = $orig_cwd."/.commit-template";
    if (-e $template) {
        $self->exe('git', 'config', 'commit.template', $template);
    }

    if (!has_url_scheme($repo_basename)) {
        $self->git_add_remotes($repo_basename);
    }

    if ($self->{'detach-alternates'}) {
        $self->exe('git', 'repack', '-a');

        my $alternates_path = '.git/objects/info/alternates';
        if (-e $alternates_path) {
            unlink($alternates_path) || confess "unlink $alternates_path: $OS_ERROR";
        }
    }

    chdir($orig_cwd) or confess "cd $orig_cwd: $OS_ERROR";

    return;
}

sub ensure_link
{
    my ($self, $src, $tgt) = @_;
    return if (!$self->{'force-hooks'} and -f $tgt);
    unlink($tgt); # In case we have a dead symlink or pre-existing hook
    print "Aliasing $src\n      as $tgt ...\n" if (!$self->{quiet});
    if ($^O ne "msys" && $^O ne "MSWin32") {
        return if eval { symlink($src, $tgt) };
    }
    # Windows doesn't do (proper) symlinks. As the post_commit script needs
    # them to locate itself, we write a forwarding script instead.
    open SCRIPT, ">".$tgt or die "Cannot create forwarding script $tgt: $!\n";
    # Make the path palatable for MSYS.
    $src =~ s,\\,/,g;
    $src =~ s,^(.):/,/$1/,g;
    print SCRIPT "#!/bin/sh\nexec $src \"\$\@\"\n";
    close SCRIPT;
}

sub git_install_hooks
{
    my ($self) = @_;

    my $hooks = $script_path.'/qtrepotools/git-hooks';
    if (!-d $hooks) {
        print "Warning: cannot find Git hooks, qtrepotools module might be absent\n";
        return;
    };

    my @configresult = qx(git config --list --local);
    foreach my $line (@configresult) {
        next if ($line !~ /submodule\.([^.=]+)\.url=/);
        my $module = $1;
        my $module_gitdir = $module.'/.git';
        if (!-d $module_gitdir) {
            open GITD, $module_gitdir or die "Cannot open $module: $!\n";
            my $gd = <GITD>;
            close GITD;
            chomp($gd);
            $gd =~ s/^gitdir: // or die "Malformed .git file $module_gitdir\n";
            $module_gitdir = rel2abs($gd, $module);
            if (open COMD, $module_gitdir.'/commondir') {
                my $cd = <COMD>;
                chomp($cd);
                $module_gitdir .= '/'.$cd;
                $module_gitdir = abs_path($module_gitdir);
                close COMD;
            }
        }
        $self->ensure_link($hooks.'/gerrit_commit_msg_hook', $module_gitdir.'/hooks/commit-msg');
        $self->ensure_link($hooks.'/git_post_commit_hook', $module_gitdir.'/hooks/post-commit');
        $self->ensure_link($hooks.'/clang-format-pre-commit', $module_gitdir.'/hooks/pre-commit');
    }
}

sub run
{
    my ($self) = @_;

    $self->check_if_already_initialized;

    chomp(my $url = `git config remote.origin.url`);
    die("Have no origin remote.\n") if (!$url);
    $url =~ s,\.git/?$,,;
    $url =~ s/((?:tqtc-)?qt5)$//;
    my $qtrepo = $1 || 'qt5';
    $self->{'base-url'} = $url;

    $self->git_clone_all_submodules($qtrepo, $self->{branch}, $self->{alternates}, @{$self->{'module-subset'}});

    $self->git_add_remotes($qtrepo);

    $self->git_install_hooks;

    return;
}

#==============================================================================

Qt::InitRepository->new()->run if (!caller);
1;
