
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

This will establish connection between local machine and the server.
Then on other machines, you can ssh into your machine with:

```
./greenlight connect <machine_alias>
```

