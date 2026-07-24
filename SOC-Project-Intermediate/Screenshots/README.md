# Screenshot checklist

Add your own implementation screenshots to these folders:

- `AWS/`
- `Wazuh/`
- `Suricata/`
- `Alerts/`

## Redact before publishing

Remove or blur:

- AWS account ID
- public IPv4 addresses
- instance IDs
- private key names
- usernames and email addresses
- Wazuh passwords or tokens
- browser URLs containing public IPs
- billing information
- RDP passwords
- access keys and secret keys

## Suggested filenames

```text
AWS/01-vpc-created.png
AWS/02-security-groups.png
AWS/03-ec2-instances-redacted.png
Wazuh/01-agent-summary.png
Wazuh/02-windows-agent.png
Wazuh/03-ubuntu-agent.png
Suricata/01-service-running.png
Suricata/02-eve-json-alert.png
Alerts/01-windows-failed-login.png
Alerts/02-linux-fim.png
Alerts/03-suricata-http-test.png
Alerts/04-triage-timeline.png
```

## Capture quality

- Use a readable browser zoom.
- Include the page title and relevant filter.
- Capture only the needed area.
- Do not show passwords, tokens or personal tabs.
- Add a short caption in the README or documentation.
