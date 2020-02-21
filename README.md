# Drupal.org signing intermediate key rotation

Drupal.org uses chained signatures as defined at https://github.com/drupal/php-signify#chaining-with-csig to allow clients to verify code and other assets.

The general process for rotating Drupal.org’s intermediate key used for signing is:

1. Generate a key pair using Signify on the signing oracle.
2. Copy the public key from the signing oracle to the laptop performing rotation.
3. Determine an expiration date for this intermediate key
4. Using the intermediate public key and the expiration date, generate an expiring public key signature file (`.xpub`) by signing it using the root key
5. Include the appropriate `untrusted comment: …` lines in both the `intermediate.sec` and the `intermediate.xpub` files.
6. The intermediate keys and `.xpub` file can then be uploaded to the signing oracle and verified.
7. From here, the signing oracle can sign packages using its intermediate key. Combined with the `.xpub` data, this creates a `.csig`, which is verifiable with the root public key.

The final output looks like this example: https://bitbucket.org/drupalorg-infrastructure/drupal-signing-oracle-built/src/master-built/tests/Fixtures/ 


## Roles and Responsibilities

- *Signing Oracle:* a server accessible over message queue for online build signing
- *Root Authority:* Internet-connected computer with local access to a YubiHSM 2
- *Network:* Any mechanism for transfer between the systems


## Preparation

- SSH access to Drupal.org backend servers. Add to `.ssh/config`:
  ```
  Host *.drupal.bak
    ProxyCommand ssh -q -W %h:%p <username>@shell1.drupalsystems.org
  ```
- Phone for Duo TFA, for authenticating as root.
- YubiHSM SDK from https://developers.yubico.com/YubiHSM2/Releases/, run each command in bin with --help to get through some MacOS security prompts.
- Your HSM, open the case.
- The “YubiHSM - User” password ready to be copied from LastPass. It will reprompt for your LastPass master password, unless you’ve recently access it and told it not to.
- 2 terminals - one for running the YubiHSM connector server, one for the rest of the commands.
- www.drupal.org database connection for verification.


## Process

### Set up environment and generate the intermediate key.

```
$ mkdir workspace && cd workspace
$ …/signing/rotate-setup.sh
```

### Sign the intermediate.pub with the root.sec key.

1. Plug in your HSM.
2. In a separate terminal, start the YubiHSM SDK connector.
   ```
   $ yubihsm-connector -d
   ```
   You can check the status of your connector and device by visiting `http://127.0.0.1:12345/connector/status`
3. In the first terminal, connect to the HSM.
   ```
   $ yubihsm-shell
   yubihsm> connect
   yubihsm> session open 1
   ```
   You’ll be prompted for the “YubiHSM - User” password.
4. Sign `intermediate.pub` with the `root.sec` key to add to our expiring public key (`.xpub`), in a format that can be validated by Signify.
   ```
   yubihsm> sign eddsa 0 0x0003 ed25519 intermediate.tmp
   ```
   Exit and copy the output to `intermediate.xpub.signature.tmp`
   ```
   pbpaste > intermediate.xpub.signature.tmp
   ```
5. Exit the YubiHSM SDK connector and unplug the HSM.

### Create and upload the `xpub` file.

```
$ …/signing/rotate-create-xpub.sh
```

### Install the new intermediate key.

```
$ ssh sign.drupal.bak
sign$ chmod -v 440 intermediate-<YYYY-MM-DD>.*
sign$ sudo chown -v root:notary intermediate-<YYYY-MM-DD>.*
sign$ sudo mv -v intermediate-<YYYY-MM-DD>.sec /etc/drupal-signing-oracle/intermediate.sec
sign$ sudo mv -v intermediate-<YYYY-MM-DD>.xpub /etc/drupal-signing-oracle/intermediate.xpub
sign$ sudo systemctl restart signing-oracle
```

### Verify funtcionality, and re-sign release contents hashes.

Drupal.org and the automatic_updates module will validate the signed packages received using the known `root.pub` included in the module release.

1. Request a new in place update to verify, `https://www.drupal.org/in-place-updates/drupal/drupal-{version}-to-{version}.zip.csig` with a version combination which has not been requested before. For example, `https://www.drupal.org/in-place-updates/drupal/drupal-8.7.1-to-8.7.11.zip.csig`. See what has been generated to find a novel combination and track progress:
   ```
   mysql> SELECT n_from.title from_release, n_to.title to_release, from_unixtime(dipu.requested) requested, from_unixtime(dipu.generated) generated, from_unixtime(dipu.expiration) expiration, dipu.generated - dipu.requested delta, dipu.error FROM drupalorg_in_place_updates dipu LEFT JOIN node n_from ON n_from.nid = dipu.from_release_nid LEFT JOIN node n_to aaON n_to.nid = dipu.to_release_nid ORDER BY dipu.requested;
   ```
2. If it has not been requested before, you will see a Drupal.org page with “This update is being generated and is not available yet.” wait up to a minute for it to generate.
3. Request again, downloading the .csig file. Look at the contents and see the new expiration date.
4. Re-sign all release contents hashes using the `resign_release_contents_hashes-www.drupal.org` project on ctrl1, `http://localhost:8085/view/www/job/resign_release_contents_hashes-www.drupal.org/`
   - Configure to default `expiration` to the new expiration.
   - Run with `project` = `drupal` first.
   - Run with empty `project` to regenerate everything else.

In place updates artifacts will expire on cron and do not require intervention for key rotation.

### Clean up

```
$ cd ..
$ rm -r workspace
```
