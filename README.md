# snmp-probe-algos

Probe which SNMPv3 authentication and privacy protocol names your local Net-SNMP has compiled in.
The actual test is just trying to start snmpget with the respective `-a` or `-x` flag. Default mode fetches candidate names and aliases from the official Net-SNMP master branch source code. 



## Ubuntu 22.04 LTS example
```

./snmp-probe-algos.sh

auth SHA          accepted
auth SHA-1        accepted
auth SHA1         accepted
auth MD5          accepted
auth SHA-224      accepted
auth SHA224       accepted
auth SHA-256      accepted
auth SHA256       accepted
auth SHA-384      accepted
auth SHA384       accepted
auth SHA-512      accepted
auth SHA512       accepted
auth BOGUS-123    unavailable

priv DES          accepted
priv AES          accepted
priv AES-128      accepted
priv AES128       accepted
priv AES-192      accepted
priv AES192       accepted
priv AES-256      accepted
priv AES256       accepted
priv AES-192-C    accepted
priv AES192C      accepted
priv AES-256-C    accepted
priv AES256C      accepted
priv BOGUS-123    unavailable

```

Offline sneakernet mode uses a static list of protocols commonly in use in 2026: `./snmp-probe-algos.sh -o`

## Why this even exists

snmpconf suggestions for "The default snmpv3 privacy (encryption) type name to use" and "The default snmpv3 authentication type name to use" are not synched with the compiled-in options, and these strings are surprisingly hard to find.

