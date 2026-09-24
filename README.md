# snmp-probe-algos

Probe which SNMPv3 authentication and privacy protocol names your local Net-SNMP accepts.
Default mode fetches candidate names and aliases from the official Net-SNMP master branch.
Run: `./snmp-probe-algos.sh`
Offline mode uses static protocol lists: `./snmp-probe-algos.sh -o`
Requires Bash, snmpget, and grep; online mode also requires curl, sed, and internet access.

Checks run locally without contacting an SNMP device; bogus names act as negative controls.
Acceptance confirms protocol recognition, not a successful cryptographic exchange.
