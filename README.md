# hap-d

At this moment it is just a minimal example. A lot to be done.
Implemented mdns service advertising, pairing procedure and sample lightbulb accessory.

A lot of stuff(whole pairing procedure) I just ported from other projects.

TODO:
1. Characteristic value update with notification.
2. Define services and characteristics in accs.d.
3. Improve code quality.

# References

Works and specs I was guided by:

## mdns:

1. https://github.com/futomi/node-dns-sd
2. https://github.com/hashicorp/mdns
3. https://tools.ietf.org/html/rfc1035
4. https://tools.ietf.org/html/rfc6763

## HAP

1. https://github.com/homebridge/HAP-NodeJS/blob/master/src/lib/HAPServer.ts
2. https://github.com/ikalchev/HAP-python/blob/dev/pyhap/hap\_server.py

## Dependencies

1. libsodium
