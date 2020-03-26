# About

This is a small egg to provide Unix socket transport to msgpack-rpc-client egg without making
the socket egg a direct dependencie.

It provide a single procedure:

```scheme
procedure: (make-client path)
```

Create a msgpack-rpc-client instance ready to connect to the unix socket fount at `path`.
