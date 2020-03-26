# About

This is a small egg to provide Unix socket transport to msgpack-rpc-client egg without making
the socket egg a direct dependencie.

It provide two procedures:

```scheme
procedure: (make-unix-port-connector path)
```
Return a thunk that connect to the unix socket
found at path and return two values: in and out ports.
This is can be use as follow:
```scheme
(import (prefix msgpack-rpc-client mrpc:))
(import mrpc-client-unix)
(define client
  (mrpc:make-client 'extend
    (make-unix-port-connector "/tmp/sock")))
```

```scheme
procedure: (make-client path)
```
Create a msgpack-rpc-client instance ready to connect to the unix socket fount at `path`. Basically a shortcut to the previous snippet.
