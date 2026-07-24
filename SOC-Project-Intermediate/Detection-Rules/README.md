# Detection rules

## Suricata

`suricata-local.rules` contains a deterministic, benign HTTP test rule. It alerts when an HTTP request to TCP port `8080` contains `SOC-LAB-TEST` in the URI.

Copy it to:

```text
/etc/suricata/rules/local.rules
```

Validate:

```bash
sudo suricata -T -c /etc/suricata/suricata.yaml \
  -S /etc/suricata/rules/local.rules
```

## Wazuh

`wazuh-local_rules.xml` raises a Wazuh level 8 alert when the matching Suricata JSON signature is received.

Back up the existing Wazuh local rules before replacing or merging content.

Validate:

```bash
sudo /var/ossec/bin/wazuh-analysisd -t
```

Custom Wazuh rule IDs should remain in the recommended local/custom range and must not duplicate an existing rule.
