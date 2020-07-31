# hap-d

At this moment it is just a proof of concept.
Implemented mdns service advertising and pairing procedure. No more.

Ugly code. Errors may be thrown. 

A lot of stuff(whole pairing procedure) I just ported from other projects.

# References

Works and specs I was guided by:

## mdns:

1. https://github.com/futomi/node-dns-sd
2. https://tools.ietf.org/html/rfc1035
3. https://tools.ietf.org/html/rfc6763

## HAP

1. https://github.com/homebridge/HAP-NodeJS/blob/master/src/lib/HAPServer.ts
2. https://github.com/ikalchev/HAP-python/blob/dev/pyhap/hap_server.py

## Used libraries

1. https://github.com/LightBender/SecureD
2. https://github.com/yannick/tweetnacl.d
