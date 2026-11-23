# Releasing

Releases are Git tags. On a `vX.Y.Z` tag, CI builds the AppImage, the Flatpak, the APK and the Play Store bundle (`.aab`) and attaches each to the GitHub release; VirusTotal then scans the APK, AppImage and Flatpak and adds its report to the notes. The Flatpak is also published to a signed remote on GitHub Pages (`flatpak update` works).

1. Pick the version (`1.0.0`). Update:
    - [pubspec.yaml](./pubspec.yaml) → `version: 1.0.0+1` (the number after `+` is the Android versionCode; always increase it, Google Play rejects a repeat)
    - [lib/about.dart](./lib/about.dart) → `appVersion`
    - [metainfo](./linux/packaging/io.github.evandro777.EasyCalc.metainfo.xml) → add a `<release version="1.0.0" date="YYYY-MM-DD">` entry (newest first). `flatpak.yml` fails the tag without it.
    (`flutter test` checks the three match.)
2. Run `dart format lib test && flutter analyze && flutter test`.
3. Commit, merge to `master`, wait for CI.
4. Tag and push (the tag must equal the version, or the workflows fail):

    ```sh
    git tag v1.0.0 -m "EasyCalc 1.0.0"
    git push origin v1.0.0
    ```

5. Smoke-test the downloaded AppImage, Flatpak and APK.
6. Google Play: download `EasyCalc-<version>.aab` from the release and upload it in Play Console (Testing → Internal testing first, then promote to production).

## One-time setup

Actions and settings, that needs to be done once.

- AppImage updates: nothing to set up. The `.zsync` is built and attached to each release; `AppImageUpdate` reads the update info embedded in the file.

### Flatpak remote & GitHub Pages

- Settings → Pages → Source: **GitHub Actions**.
- Settings → Environments → `github-pages` → deployment branches and tags → Add deployment branch or tag
    - Ref type: Tag
    - Name pattern: `v*`
    - ℹ️ Pages creates the environment with a default-branch-only rule, so the first tag deploy is refused ("Tag v… is not allowed to deploy").
- Create a pair signing key.
    - In terminal: `linux/packaging/new-signing-key.sh`
    - `linux/packaging/signing-key.b64` is the **public** half, committed, users check signatures with it.
    - CI needs the **private** half to sign each release, so store it as a secret named `FLATPAK_GPG_PRIVATE_KEY`
- Settings → Secrets and variables → Actions → New repository secret
    - `Name`: `FLATPAK_GPG_PRIVATE_KEY`
    - `Secret`: Paste the contents of the private key, whole file, from `-----BEGIN PGP PRIVATE KEY BLOCK-----` to the `END` line, as the secret's value
    - **Never commit the private file!** GitHub will not show the secret again, so keep a private backup (a password manager); if the key is lost, a new key breaks every user's existing remote and they must re-add it.

### Android

- Android signing: tag builds fail without a release keystore (plain pushes and fork PRs fall back to the debug key). One-off setup, outside the repo and outside Dropbox:
    1. `keytool -genkeypair -v -keystore ~/.local/share/easycalc-release.jks -alias easycalc -keyalg RSA -keysize 4096 -validity 10000`
        - Fill a password twice, the same password is going to be in `ANDROID_KEYSTORE_PASSWORD`
        - Name: Can be the name of the app
        - The others answers are optional and can be "." for empty values
    2. Keystore:
        - Or go to Github: Settings → Secrets and variables → Actions → New repository secret
        - Name: `ANDROID_KEYSTORE_B64`
        - Secret: the output of `base64 -w0 ~/.local/share/easycalc-release.jks` (without the % in the end)
    3. Password:
        - Name: `ANDROID_KEYSTORE_PASSWORD`
        - Secret: the password typed before
    4. Alias:
        Name: `ANDROID_KEY_ALIAS`
        Secret: `EasyCalc`
    5. Back the keystore and password in a password manager.
- Google Play: create the app in [Play Console](https://play.google.com/console/) and enrol in **Play App Signing** (Google keeps the app signing key; the keystore above is only the *upload key*, so a lost keystore can be reset via Play support). The first `.aab` must be uploaded by hand; the app ID is `io.github.evandro777.easycalc`.

### Virus Total checking

Automatically check for virus on deploy, or delete `virustotal.yml`.

- Settings → Secrets and variables → Actions → New repository secret
- `Name`: `VIRUSTOTAL_API_KEY`
- `Secret`: Your Virus total api key
- Some antivirus may identify it as trojan, so you need to send the file to reanalyze:
    - [Microsoft Windows Defender](https://www.microsoft.com/en-us/wdsi/filesubmission)
