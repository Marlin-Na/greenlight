
## greenlight

This script allows you to expose your local machine through an intermediate
server so that you can conveniently ssh into your local machine
through the server.

No config or setup is required on the server, as long as you have ssh access
to the jump server.

To use this script, download it and set environment variables:

```
export GREENLT_SERVER="user@address"
export GREENLT_CLIENT_ALIAS="myalias" ## optional
```

Then run:

```sh
./greenlight host
```

```
jma@wm447-636$ ./greenlight host
=== Connection established with login ===
Now you can login your machine with:
   ssh -J login jma@localhost -p 50443
```

This will establish connection between local machine and the server.
Then on other machines, you can ssh into your machine with:

```
./greenlight connect <machine_alias>
```

```
$ ./greenlight connect wm447-636
ssh -J login jma@localhost -p 50443 # wm447-636
Password:
Last login: Wed Jan 22 11:32:01 2020

The default interactive shell is now zsh.
To update your account to use zsh, please run `chsh -s /bin/zsh`.
For more details, please visit https://support.apple.com/kb/HT208050.
```

