# Upload this project to GitHub

Repository:

```text
SOC-Project-Intermediate
```

## Method A — GitHub Web

1. Extract the ZIP file.
2. Open your empty GitHub repository.
3. Choose **Add file** → **Upload files**.
4. Open the extracted `SOC-Project-Intermediate` folder.
5. Drag all items inside the folder into the upload area.
6. Wait for every file to finish uploading.
7. Commit message:

```text
docs: publish AWS SOC lab project
```

8. Choose **Commit directly to the main branch**.
9. Select **Commit changes**.
10. Open the repository and verify both architecture images load.

GitHub Web may not upload empty directories. This repository includes README files where needed, so the important folders are preserved.

## Method B — Git command line

Open a terminal inside the extracted project folder:

```bash
git init
git branch -M main
git add .
git commit -m "docs: publish AWS SOC lab project"
git remote add origin https://github.com/krishlj/SOC-Project-Intermediate.git
git push -u origin main
```

GitHub no longer accepts an account password for command-line HTTPS authentication. Use a supported Git credential flow, GitHub CLI, or a personal access token stored securely.

## Suggested future commits

```text
docs: add redacted AWS deployment screenshots
docs: add Wazuh endpoint evidence
docs: add Suricata alert evidence
docs: document Windows failed-login triage
docs: document Ubuntu FIM triage
fix: correct commands after lab validation
```

## Before publishing

```bash
git status
git diff --cached
```

Confirm no `.pem`, `.ppk`, credentials, tokens, account IDs or unredacted screenshots are included.
