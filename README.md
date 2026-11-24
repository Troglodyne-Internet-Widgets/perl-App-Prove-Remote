# NAME

App::Prove::Remote - Run prove here, and each test on another host over SSH

# VERSION

version 0.001

# SYNOPSIS

```
rprove --host test.test --workdir /srv/checkout -v t/
```

# DESCRIPTION

This distribution installs [rprove](https://metacpan.org/pod/rprove), a wrapper around [prove](https://metacpan.org/pod/prove).  **rprove**
runs `prove` on your machine, and `prove` runs each test on another host
over SSH, with [Net::OpenSSH](https://metacpan.org/pod/Net%3A%3AOpenSSH).  The TAP and the exit code of each test come
back to `prove`, so the summary is the same as if the tests ran on your
machine.

Use it when a test must run in a disposable environment, such as a virtual
machine, instead of on your machine.  It can also run from the orchestrator of
a CI system.

**rprove** does not copy anything to the remote host.  Before you run it, put
the tests and the code that they test on the remote host.  See [rprove](https://metacpan.org/pod/rprove) for
the options.

This module has no code.  It holds the documentation of the distribution.

# INSTALLATION

```
cpanm App::Prove::Remote
```

The tests of [Net::OpenSSH](https://metacpan.org/pod/Net%3A%3AOpenSSH) try to connect to localhost over SSH.  If that
host does not accept your key, install [Net::OpenSSH](https://metacpan.org/pod/Net%3A%3AOpenSSH) first with
`cpanm --notest Net::OpenSSH`.

# TROUBLESHOOTING

**rprove** connects with your OpenSSH client and its configuration.  If
`ssh` connects to the host without a password prompt, **rprove** connects too.
If it cannot connect, the test fails with the message from [Net::OpenSSH](https://metacpan.org/pod/Net%3A%3AOpenSSH).

# SEE ALSO

Please see those modules/websites for more information related to this module.

- [rprove](https://metacpan.org/pod/rprove)
- [App::Prove](https://metacpan.org/pod/App%3A%3AProve)
- [Net::OpenSSH](https://metacpan.org/pod/Net%3A%3AOpenSSH)

# BUGS

Please report any bugs or feature requests on the bugtracker website
[https://github.com/Troglodyne-Internet-Widgets/perl-App-Prove-Remote/issues](https://github.com/Troglodyne-Internet-Widgets/perl-App-Prove-Remote/issues)

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

# AUTHORS

Current Maintainers:

- George S. Baugh <george@troglodyne.net>

# CONTRIBUTORS

- Andy Baugh <andy@troglodyne.net>
- Blaine Motsinger <blaine@renderorange.com>

# COPYRIGHT AND LICENSE

Copyright (c) 2022 Troglodyne LLC

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

\* Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

\* Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

\* Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
