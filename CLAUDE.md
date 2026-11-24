# CLAUDE.md

This file is the procedure for work in this repository.  The POD and the files
named below say what the code is and how it is written.

App-Prove-Remote is `rprove`, a wrapper around `prove` that runs each test on
another host over SSH and reads the TAP that comes back.  All of the code is in
`bin/rprove`.  `lib/App/Prove/Remote.pm` holds only the POD of the
distribution, and `t/rprove.t` says what the program does.

## Read the code before you change it

Before you answer a question about the code here, look for something in it, or
edit it, invoke `perl-slop:reading-perl`.

Most of the code here is older than the conversation about it.  A line that
looks pointless is usually the scar of something that went wrong once.  The
reason is in the commit, not in the file.  So read before the first edit, not
after the tests fail.

The same pass asks whether the code that you want to write is already here,
under a name that you did not search for.  Two subs that do one job are a
defect, whichever one is better.

## What perl this runs on

Every module and every test says `use 5.014`, and `perl:` in
`prereqs.yml` says the same.  `.perlcriticrc` depends on it.  The header of
that file names the policies that this version of perl makes unnecessary.  So
if you raise or lower the floor, change the profile as well as the `use` lines.

## Where it is written down

| | |
|---|---|
| `perldoc App::Prove::Remote` | what this is for, and how to install it |
| `perldoc bin/rprove` | the options of `rprove`, and how it runs a test |
| `.perlcriticrc` | the policies, which are the house style made enforceable |
| `.conformance.yml` | the overrides of the profile, and why each one is there |
| `Changes` | what changed and when, per release |
| `dist.ini` | the build, and what has to be installed to run it |

## Finishing a changeset

Before you commit, apply these skills in this order:

1. `perl-slop:data-perl`: make sure that the data is defined, coerced,
   validated and scoped in the way that perl expects.
2. `perl-slop:testing-perl`: make sure that each behavior that you added or
   changed has a test, and that the test is the right kind.
3. `perl-slop:reviewing-perl`: read the whole diff back against it.  This pass
   finds a second copy of something that the library already does.  It also
   finds a call out to the shell, and a comment that belongs in the commit
   message.

Then run `dzil podchecker` on the changed files, for example `dzil podchecker
lib/Foo/Bar.pm`.  It reads the POD as Pod::Weaver writes it into the build.
`podchecker` on a source file reports each `=func`, `=method` and `=attr` as an
error, so its verdict says nothing here.  Run `perl -Ilib -c` on each changed
script that no test loads, because the tests do not compile it.

The pre-commit hook does the rest.  It tidies the Perl that you staged, runs
perlcritic on it, and runs the tests that the commit can break, which
`tests-covering` chooses.  The post-commit, post-merge and post-rewrite hooks
keep the records of `tests-covering` up to date, in the background, after a
commit, a pull and a rebase.  If a step fails, the hook stops the
commit and prints the reason.  Do not run `perltidy` or `perlcritic` yourself,
and do not run the tests to decide whether a change is ready to commit.

The hook names each test that failed.  Its output does not say why.  If a test
fails, run that file yourself with `-v`, and read the output:

```
prove -lv t/<file>.t
```

Do the same to see a new test fail before you fix what it tests.

In each clone that you commit from, install the hooks once.  Git does not
install them for you, and without the hooks the tree drifts from its style:

```
cp git-hooks/pre-commit git-hooks/post-commit git-hooks/post-merge \
   git-hooks/post-rewrite git-hooks/refresh-coverage .git/hooks/
```

A file that no test loads, such as a fixture, gets its tests from
`.tests-covering-map.pl`.  A path that the map cannot place runs every test.
If a commit runs every test but does not touch everything, the map probably
needs a rule.  Add the rule in the same change, and name the tests that read
the file.

## When something is slow

Use `perl-slop:profiling-perl`.  Measure before you conclude anything, and
measure again after a change.  "It is just slow" is not a finding.  A line
number and a percentage is a finding.

## Releasing

`perl-slop:packaging-perl` made this distribution, and it explains what
`dist.ini` means.  It also lists the problems that stop `dzil release` with no
clear error.  Read it before the first release, not during it.

```
dzil authordeps --missing | cpanm --notest
dzil build && dzil test --release
```

The version and the entry in `Changes` come from git.  Do not edit either by
hand.  The version is the last release tag plus one.  The entry is the
`Changelog:` trailers of the commits since that tag.

## Commits and pull requests

Make a branch.  Do not commit to the default branch.

A commit message here says what was wrong and why the change fixes it.  Write
it in prose and in the imperative mood.  Name the behavior, not the diff, for
example "Ask the pool whether it takes O_DIRECT, rather than guessing from its
name".  The message has a job.  `perl-slop:reading-perl` describes a person who
finds your line with `git blame` two years from now.  The message is the only
thing that can still tell that person why.  For the same reason, the why goes
in the message and not in a comment.

If a user of the distribution can see the change, end the message with a
`Changelog:` trailer.  Its value is the line for `Changes`, written for that
user:

```
git commit --trailer 'Changelog: Refuse a pool that does not take O_DIRECT'
```

A commit that a user cannot see, such as a tidy or a change to a test, gets no
trailer.  If no commit since the last release has one, the release stops.

After you make sure that something works, say what you ran and what it said.
A claim that the tests pass needs the line that shows them passing.  A claim
about your own work needs its evidence too, such as the URL from `gh pr
create` or the sha from `git push`.  A PR number that nobody can open is worse
than no number.

If the code of a branch depends on another branch, stack it on that branch.
If only a test of it depends on the other branch, do not stack it.  A change
whose tests need a fix from somebody else is still an independent change.
Open it against the default branch, and say in the description what must
merge first.  A stacked branch merges into its base, whatever that base is.
If the base reached the default branch by another route, the stacked change
reaches nowhere, and nothing says so.
