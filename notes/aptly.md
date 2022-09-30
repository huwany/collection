# aptly

## summary

* Server OS: ubuntu server 16.04
* Client OS: precise/trusty/xenial/bionic

## install package

* echo deb http://repo.aptly.info/ squeeze main | sudo tee --append /etc/apt/sources.list.d/aptly.list
* wget -qO - https://www.aptly.info/pubkey.txt | sudo apt-key add -
* sudo apt-get update
* sudo apt-get install haveged dpkg-sig aptly

## config gpg key

* Change ~/.gnupg/gpg.conf

   ```bash
   r2@orbit-01:~$  vi ~/.gnupg/gpg.conf
   ...
   personal-digest-preferences SHA256
   cert-digest-algo SHA256
   default-preference-list SHA512 SHA384 SHA256 SHA224 AES256 AES192 AES CAST5 ZLIB BZIP2 ZIP Uncompressed
   ...
   ```

* create gpg key

   ```bash
   r2@orbit-01:~$ gpg --gen-key
   gpg (GnuPG) 1.4.20; Copyright (C) 2015 Free Software Foundation, Inc.
   This is free software: you are free to change and redistribute it.
   There is NO WARRANTY, to the extent permitted by law.
   
   Please select what kind of key you want:
      (1) RSA and RSA (default)
      (2) DSA and Elgamal
      (3) DSA (sign only)
      (4) RSA (sign only)
   Your selection? 4
   RSA keys may be between 1024 and 4096 bits long.
   What keysize do you want? (2048) 4096
   Requested keysize is 4096 bits
   Please specify how long the key should be valid.
            0 = key does not expire
         <n>  = key expires in n days
         <n>w = key expires in n weeks
         <n>m = key expires in n months
         <n>y = key expires in n years
   Key is valid for? (0) 0
   Key does not expire at all
   Is this correct? (y/N) y
   
   You need a user ID to identify your key; the software constructs the user ID
   from the Real Name, Comment and Email Address in this form:
       "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"
   
   Real name: Relay2, Inc.
   Email address: wanyong.hu@relay2.com
   Comment: Relay2 Private Repository
   You selected this USER-ID:
       "Relay2, Inc. (Relay2 Private Repository) <wanyong.hu@relay2.com>"
   
   Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
   You need a Passphrase to protect your secret key.
   
   gpg: gpg-agent is not available in this session
   You don't want a passphrase - this is probably a *bad* idea!
   I will do it anyway.  You can change your passphrase at any time,
   using this program with the option "--edit-key".
   
   We need to generate a lot of random bytes. It is a good idea to perform
   some other action (type on the keyboard, move the mouse, utilize the
   disks) during the prime generation; this gives the random number
   generator a better chance to gain enough entropy.
   ..............+++++
   ........+++++
   gpg: key F48A1216 marked as ultimately trusted
   public and secret key created and signed.
   
   gpg: checking the trustdb
   gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
   gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
   pub   4096R/F48A1216 2017-02-13
         Key fingerprint = 7539 B649 4D8A 5F33 229A  448A B3A8 36CE F48A 1216
   uid                  Relay2, Inc. (Relay2 Private Repository) <wanyong.hu@relay2.com>
   
   Note that this key cannot be used for encryption.  You may want to use
   the command "--edit-key" to generate a subkey for this purpose.
   ```

* export public key

   ```bash
   gpg --armor --output ~/r2repo.key --export  F48A1216
   ```

* export private key

   ```bash
   gpg --armor --output ~/r2repo_secret.key --export-secret-keys F48A1216
   ```

* import private key

   ```bash
   gpg --import r2repo_secret.key
   ```

* edit private key 

   > select trust 5 and save to quit.

   ```bash
   gpg --edit-key F48A1216
   ```

* List keys

   ```bash
   gpg --list-keys
   ```

## config aptly

* create aptly config file, sudo vi /etc/aptly.conf

  ```json
  {
    "rootDir": "/store/aptly",
    "downloadConcurrency": 4,
    "downloadSpeedLimit": 0,
    "architectures": ["i386", "amd64"],
    "dependencyFollowSuggests": false,
    "dependencyFollowRecommends": false,
    "dependencyFollowAllVariants": false,
    "dependencyFollowSource": false,
    "gpgDisableSign": false,
    "gpgDisableVerify": false,
    "downloadSourcePackages": false,
    "ppaDistributorID": "ubuntu",
    "ppaCodename": "",
    "skipContentsPublishing": false,
    "S3PublishEndpoints": {},
    "SwiftPublishEndpoints": {}
  }
  ```

## create repo

* create repository

  ```bash
  sudo aptly repo create r2repo-precise
  sudo aptly repo create r2repo-trusty
  sudo aptly repo create r2repo-xenial
  sudo aptly repo create r2repo-bionic
  sudo aptly repo create r2repo-focal -component="main" -architectures="amd64" -distribution="focal" 
  
  ```

* publish repository
  
  ```bash
  sudo aptly publish repo -distribution="precise" r2repo-precise
  sudo aptly publish repo -distribution="trusty" r2repo-trusty
  sudo aptly publish repo -distribution="xenial" r2repo-xenial
  sudo aptly publish repo -distribution="bionic" r2repo-bionic
  sudo aptly publish repo -distribution="focal" r2repo-focal
  ```

* add deb packages to repository
  
  ```bash
  sudo aptly repo add r2repo-${CODENAME} /home/r2/some-packages-dir-path
  ```

* update repository commit
  
  ```bash
  sudo aptly publish update precise
  sudo aptly publish update trusty
  sudo aptly publish update xenial
  sudo aptly publish update bionic
  sudo aptly publish update focal
  ```

* show packages
  
  ```bash
  sudo aptly repo show -with-packages r2repo-precise
  sudo aptly repo show -with-packages r2repo-trusty
  sudo aptly repo show -with-packages r2repo-xenial
  sudo aptly repo show -with-packages r2repo-bionic
  sudo aptly repo show -with-packages r2repo-focal
  ```

* remove packages from repository
  
  ```bash
  sudo aptly repo remove r2repo-focal example-helloworld_1.0.0.0_amd64.deb
  sudo aptly db cleanup
  ```

## how to using this private repository

* add repository to sources.list (for example with Ubuntu 16.04)
  
  ```bash
  echo "deb http://mirrors/ubuntu focal main" | sudo tee /etc/apt/sources.list.d/r2repo.list
  ```

* add repo key
  
  ```bash
  wget -qO - http://mirrors/keys/r2repo.key | sudo apt-key add -
  ```

* update apt cache
  
  ```bash
  sudo apt-get update
  ```

* install software
  
  ```bash
  sudo apt-get install example-helloworld
  ```
