# named-docker

## Overview

This docker image contains [Berkeley Internet Name Domain](https://www.isc.org/downloads/bind/) (<tt>BIND</tt>).

## Entrypoint Scripts

### bind

The embedded entrypoint script is located at `/etc/entrypoint.d/bind` and performs the following actions:

1. A new bind configuration is generated using the following environment variables:

 | Variable | Default Value | Description |
 | -------- | ------------- | ----------- |
 | BIND_FORWARDERS | 8.8.8.8; 8.8.4.4; 2001:4860:4860::8888; 2001:4860:4860::8844; | A semicolon separated list of nameservers. |

## Healthcheck Scripts

### named

The embedded healthcheck script is located at `/etc/healthcheck.d/named` and performs the following actions:

1. Verifies that named is able to resolve `www.google.com`.

## Standard Configuration

### Container Layout

```
/
├─ etc/
│  ├─ bind/
│  ├─ entrypoint.d/
│  │  └─ bind
│  └─ healthcheck.d/
│     └─ bind
└─ usr/
│  └─ local/
│     └─ bin/
│        └─ bind-keygen
└─ var/
   └─ lib/
      └─ bind/
```

### Exposed Ports

* `53/udp` - bind listening port.

### Volumes

* `/etc/bind` - bind configuration directory.

## Development

[Source Control](https://github.com/crashvb/named-docker)

