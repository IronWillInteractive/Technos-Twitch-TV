# GitHub Pages Publish Tools

Use `Publish_StreamClient_To_GitHub.bat` after Stream Manager exports a `*_StreamClient.zip`.

Flow:
1. Unzip the generated `*_StreamClient.zip`.
2. Run `Tools/Publish_StreamClient_To_GitHub.bat`.
3. Enter your GitHub username, repo name, and path to the unzipped `*_StreamClient` folder.
4. The script copies that client to the repo root so its `index.html` is the GitHub Pages entry.
5. It also archives the same stream under `streams/<stream-name>/` so each new stream can have its own repo folder.
6. It creates `.github/workflows/pages.yml`, commits, pushes, and polls the Pages link for up to 5 minutes.

Use `End_Stream_Cleanup.bat` to remove an ended stream folder from `streams/<stream-name>/`, commit the deletion, and push.

Requires Windows PowerShell, Git, and GitHub CLI. The publish script attempts to install Git/GitHub CLI through winget when missing.
