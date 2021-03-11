# Unit Tests

## Baseline
1. Delete all Application Services using f5-automated-backup templates.
1. Create Application Service: bk_3.2.1_unit_testing
1. Versions
    * 13.1.3.4
    * 14.1.3
    * 15.1.2
    * 16.0.1

## Test 1 (UCS Passphrase)
1. UCS
1. Encrypt: Yes (default)
1. Passphrase: `~!@#$%^*()aB1-_=+:./?
1. Include private keys: Yes (default)
1. Frequency: Disabled (default)

Ensure iApp can be deployed without error.

## Test 2 (Local backups)
1. UCS
1. Encrypt: Yes (default)
1. Passphrase: `~!@#$%^*()aB1-_=+:./?
1. Include private keys: Yes (default)
1. __Every 1 minutes__
1. __On this F5__
1. __Select first file format option: ${host}_%Y%m%d_%H%M%S__
1. __Automatic Pruning: Disabled (default)__
1. __Amount of file: 3 (default)__

Ensure two files get created locally.

## Test 3 (Local backups with full pruning)
1. UCS
1. Encrypt: Yes (default)
1. Passphrase: `~!@#$%^*()aB1-_=+:./?
1. Include private keys: Yes (default)
1. Every 1 minutes
1. On this F5
1. Select first file format option: ${host}_%Y%m%d_%H%M%S
1. __Automatic Pruning: Prune All Archives__
1. Amount of file: 3 (default)

Ensure a new archive is created and only three (or four) remain.

## Test 4 (Local backups with iApp-limited pruning)
1. UCS
1. Encrypt: Yes (default)
1. Passphrase: `~!@#$%^*()aB1-_=+:./?
1. Include private keys: Yes (default)
1. Every 1 minutes
1. On this F5
1. Select first file format option: ${host}_%Y%m%d_%H%M%S
1. __Automatic Pruning: Only Prune iApp-Generated Archives__
1. __Unique Filename Suffix: unit-testing__
1. Amount of file: 3 (default)

Ensure a new archive is created and only three (or four) iApp archives remain.

## Test 5 (SCP backups)
1. UCS
1. Encrypt: Yes (default)
1. Passphrase: `~!@#$%^*()aB1-_=+:./?
1. Include private keys: Yes (default)
1. Every 1 minutes
1. __Remotely via SCP__
1. __Destination: 10.204.136.10__
1. __StrictHostKeyChecking: Yes (default)__
1. __Username: testuser__
1. __SSH private key: (paste as appropriate)__
1. __Cipher: (as appropriate)__
1. __Remote directory: (blank) (default)__
1. Select first file format option: ${host}_%Y%m%d_%H%M%S

Ensure a new archive is created and only three (or four) iApp archives remain.





1. "Include private keys": No


## Resources
while true; do ls -lah /var/local/ucs; echo; echo; sleep 30; done


## Ansible Playbook for building test user for SCP and SFTP
```
---
- name: Build test user for SCP and SFTP
  hosts: localhost
  vars:
    username: testuser
  tasks:
    - name: Create testuser
      user:
        name: "{{ username }}"
        state: present
        shell: /bin/bash

    - name: Generate ssh keys
      shell: rm /home/testuser/keyfile*; ssh-keygen -m pem -t rsa -b 2048 -q -N "" -C f5-backup-iapp-unit-tests -f /home/testuser/keyfile

    - name: List ssh private key
      command: cat /home/testuser/keyfile
      register: privatekey

    - name: List ssh public key
      command: cat /home/testuser/keyfile.pub
      register: publickey

    - debug:
        var: privatekey

    - debug:
        var: publickey

    - name: Set up authorized_key file
      authorized_key:
        user: "{{ username }}"
        state: present
        key: "{{ lookup('file', '/home/{{ username }}/keyfile.pub') }}"
```

```
cat /dev/zero | ssh-keygen -m pem -t rsa -b 2048 -q -N "" -C f5-backup-iapp-unit-tests -f /home/testuser/keyfile
cat /home/testuser/keyfile
cat /home/testuser/keyfile.pub

cat /home/testuser/.ssh/id_rsa
```

```
cat > /var/tmp/testuser.key
chmod 0500 /var/tmp/testuser.key
```

```
ssh testuser@lxjump.daniel.msplab.grp -i testuser.key -c aes256-ctr
```

## SSH Keys

ansible localhost -m openssh_keypair -a 'path=/home/testuser/keyfile2 owner=testuser mode=0600 size=2048 state=present type=rsa'
ansible localhost -m openssl_privatekey -a 'path=/home/testuser/keyfile size=2048 state=present type=RSA'

-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAxTcZVPdlO658DOK4fVPK9eXm03M7C+gLQap8FisFhdYj59Iz
zi7+GDNd6XVb+eG2uWrjMw2iF5g3asf7y708kvP/6o0N0GFHY9JdPe64PSzOHWw+
NGFz21cs2LafeSLc0AXuCngF8Rb3cIyuNHGfmWsO9cIAFASaCQWI2r8DNCFLZLI3
esq4lPUVVYSaGQWjYPpqGe6vNdhY6jo0wuIfN7rrzAQXH3X6dbSRuZQK7YVdhYGu
k1icVwtwyYT8sltmb1MNcUH58eCOBrPRFfZ/8mQgbEN07TO4iBWo8k1RE56lIkl/
kQr0z8UbiBTVr9XtA0abjRVF8yaHMoq8srpwUwIDAQABAoIBADjucgKkNHYpJah2
nrmXQeUAjEUIY8hJIU7Aj3e6zapYKh9XABuKV1HXKkol1fpp3VzjbVkkm2FiUMUj
nB2xsFXf2EX2mEFKg9heNwqU6lzGnW3C/KYUZ+Su4sRg2+KVXNc0jwY4pcZ2UdIM
2pFLJ76bOENb0Lf2qBzomxxCvgMDA8tCVyOqrheHkZMsIvlp8pveoDZMF2aiMQ5g
LHKosAi3NrF54x51Gguor01wU5TcTE7uhkFdTbcShcFng5zkEkfZl75ScRz1RWvr
quQcZsBv9VPqF1vy2XD7mYjME8EswuEnuCky28Wls/wtnV8+F9Gcbg6Qv9wkoXaz
Toe6YyECgYEA4wGRLhxVAwm/jv1fhqFTZzZnZal+SiuPiiTnuYfgL64gww42WxLH
8MqurM53UAbV3E3A81Q43fZxQVl9A6VaNSeFsZQwMWNlTUv14y1twRNZ2HRdtWkx
l//D+wdX+ViQ82iTFIqnpWpuMZt/cBQRnQEl/JOfTFDYqOjgocMD/IMCgYEA3md1
D57RRANDlRxMqra59gyZYEAnrmJIz9h6wMwrluNWwPywihLR8Xaza8iuDoW/mtRe
AQeEGtGPF4dXkGu3CcwITpcmfnr9t5mWvro50aeseKfr38YeqNKeh9JWJvXQMYRP
RxY0sekyP6yO/TdDWB4bYBSpWRXzPZI5CLIUE/ECgYEAmhqUPiNJqthRTHbBBJo8
DlMmeiNH8n4D4ZoQHSkajgO9hez+BXGIffR6BCHdaVxajkXSeN1yBWypkd14OqNj
y7Xa0qRw2vZI7OJmOCS831eNpJ3Kh76zxiYBG0bu9/yh2jvhrQ47pNXNnKudJa7a
DiWbbg2hFKPFkVUWOXo0GJUCgYAubIoS6KPl/ohs56tZNys6IQcjAEFINVvdhuKY
vAWdSXcicZyoNaV9MbniFdG/VkvYldvJezgoIPYtgyLUEqfyc5SIUyTF4gZz/Ktq
xJStHsLxrJuf6kscElrlHxK8rzL2IxgpTolRWcwTXoG6eX6lNiOguq9e2SYdBBjD
p+hpAQKBgBCGA+Tq9XEyZXV2PHf+1KHOPuX+ejuJBTIuq+eEAXL32DPshsHlqZEi
Ex3kvwxDMlKdmHN1YGGJkMWfYPykuvAznjeMTxd2bPSyu38kRZLfELxjGeVV3q9F
N2d4M5rYtcMsnlaK1s7Fc/RTvqj6UDHKfhP3X8iYiDA3lXR5Mewl
-----END RSA PRIVATE KEY-----
