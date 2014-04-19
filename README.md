blackknight
============

**blackknight** is a screen locker for text terminals using [PAM] for password checking.
It locks single terminals and can be used as lock-command for [TMux].

[PAM]:  https://en.wikipedia.org/wiki/Pluggable_Authentication_Modules
[TMux]: https://en.wikipedia.org/wiki/Tmux


Invocation
------------

To run **blackknight** after installing it simply type

```
$ blackknight
```

Possible cmdline options are:

| Option                     | Description
| -------------------------- | ---------------------
| `-h`/`--help`<br>          | Display a help message.
| `-nc`/`--noclear`<br>      | Do not clear the screen before locking.
| `-nm`/`--nomsg`<br>        | Do not display a message.
| `<alternate lock message>` | Display the given message instead of the default one.


Usage as TMux lock-command
---------------------------

Place the following line in `/etc/tmux.conf` or `~/.tmux.conf`:

```
set-option -g lock-command 'blackknight --noclear'
```


Build/Installation
---------------------

Since **blackknight** uses [cabal] you only have to type

```
$ cabal install
```

to install or

```
$ cabal build
```

to build without installation.

*To are able to run **blackknight** you have to install it as root (`sudo cabal install --global`)
or copy `pam.d/blackknight` to `/etc/pam.d/` with permissions set to `0644`.*

[cabal]:  http://www.haskell.org/cabal


Copyright
-----------

Copyright (c) 2014 Johannes Rosenberger <jo.rosenberger at gmx-topmail.de>

This code is released under a BSD Style License.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.

For more details please read the '[LICENSE]' file.

[LICENSE]: https://github.com/jorsn/blackknight/blob/master/LICENSE
