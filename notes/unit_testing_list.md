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

-----BEGIN
OPENSSH
PRIVATE
KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn
NhAAAAAwEAAQAAAQEAr9YjWfpAUQXrzuzLQnFvtg7J5WaAG0dnpFSXgcNKQoYZt+Ylm8Cn
zxbD+jPltR34D2SN3Ro4HXs2HtSYrDQTGyIAIp6bodiVEJJRsJRW1Lks7ZQNUs/kTiIRs6
WQY+b9nRp83PJZ19ugHPXmAdRCz4E/2OvZiIMlNc18NyXw364iMfbW1w7WCm6asjpNKxtb
hVOeM8DunAX+8WHzuTl3oUH1B4XgllDSkomoh+3aQpy9xTtj7sOYyGKWbygVKU1bHYccdK
63ZmBISaaB9NeuPVso/qdfAYUEbFoFWReuj0E2LkJzArlYKxYiWyj2C4enVbKKpv94Oz1I
dEzYVdqoSwAAA8iFfdP1hX3T9QAAAAdzc2gtcnNhAAABAQCv1iNZ+kBRBevO7MtCcW+2Ds
nlZoAbR2ekVJeBw0pChhm35iWbwKfPFsP6M+W1HfgPZI3dGjgdezYe1JisNBMbIgAinpuh
2JUQklGwlFbUuSztlA1Sz+ROIhGzpZBj5v2dGnzc8lnX26Ac9eYB1ELPgT/Y69mIgyU1zX
w3JfDfriIx9tbXDtYKbpqyOk0rG1uFU54zwO6cBf7xYfO5OXehQfUHheCWUNKSiaiH7dpC
nL3FO2Puw5jIYpZvKBUpTVsdhxx0rrdmYEhJpoH01649Wyj+p18BhQRsWgVZF66PQTYuQn
MCuVgrFiJbKPYLh6dVsoqm/3g7PUh0TNhV2qhLAAAAAwEAAQAAAQEAkOHw3wLEW/50/ls+
X9D4KxqkYNDEXbXIQC8zZ0hyt72nE1AfTObBXnFzqYV5kHLRIl3IRpaEBkavoVerNLjzxT
eOxPfLZOAAc1cc2FJh+YVa76c+Ey4ZAAgybcPN5YM/FWPt3mAShzoAA9zZWEh9hF0LLsGm
zETDNEHMR+SLRMHo3Tj1W6vlz09ZX1bYqweva5twdJW/k1eVycMIB0SykCi+FAPVUARArS
BjKw9lk2ZI3Sb3/PWYohW+mDacprkl8WIZScVFoARH3cw2LjR9wlGWA6u8jxHFN9aWOMP3
uJWxEY1cA5pYpa5N/TzlShjkESVI9ULvYLnFk+PBnBY5gQAAAIEArvpBHI5bnEwfkzv7Wu
n/f1goBD/5O7tXcDjFUo8kbrxUTyUPSWQRBCy/lkL/CJ5ItfqsyLuQg6JcPj6SeBeTopwD
umiIVj+A7meciIen8lddLDZ6GnrnF0JpMISpou0SSFuOXgVjQeHrvH/HasD/ox7bO8oDJY
77LPnvCaZ9z3UAAACBANd2y7HopJMgKvbpv8Z9CjWDwWcPElWOKJR4XoP+5QaSeXVsIE8g
cDu1xEdKJEaJezPdXfajRot9y3ML81kjrGPCici03DE9zt7JxIL4nVHY+4+Zoo2BpskDz1
7wVUIFed9vUpWpsk2TDYuUjIIVr/aM9QSALaChyAakKyRMdnW9AAAAgQDQ6st7m6eeVtwP
kydawLmQ3aRJbGiRH1pM9b929fcFeg9aOjiyDvoSfo7XSdXwGPOXFnBT3aqcxEOyrm0lKl
BGkhiB4wZCBLgPJm8jMWzluj2nZvuQNzW+qZEH4cVN1aSNjWnFJX5zMYZVfQ8hBWaaqeZv
pkUw3Baj0x8ZJd/ipwAAAA5tYXJpeWFtQGx4anVtcAECAw==
-----END
OPENSSH
PRIVATE
KEY-----

## Testing Keys

f5masterkey=$(f5mku -K)
echo $f5masterkey

keyfilepath="/var/tmp/backup_3.2.2_test_sftp4.key"
echo ${keyfilepath}

echo "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" | openssl aes-256-ecb -salt -a -A -d -k ${f5masterkey} > ${keyfilepath}
cat ${keyfilepath}

keyfilelinecount=$(wc -l ${keyfilepath} |awk '{print $1}')
echo ${keyfilelinecount}


awk 'NR==1, NR==4 {print $0}' ORS=' ' ${keyfilepath} > ${keyfilepath}.tmp
echo >> ${keyfilepath}.tmp
awk -v count="${keyfilelinecount}" 'NR==5, NR==count-4 {print $0}' ${keyfilepath} >> ${keyfilepath}.tmp
awk -v count="${keyfilelinecount}" 'NR==count-3, NR==count {print $0}' ORS=' ' ${keyfilepath} >> ${keyfilepath}.tmp
echo >> ${keyfilepath}.tmp
cat ${keyfilepath}.tmp
mv -f ${keyfilepath}.tmp ${keyfilepath}
cat ${keyfilepath}.tmp
cat ${keyfilepath}

echo put /var/tmp/test.txt | sftp -b- -i /var/tmp/backup_3.2.2_test_sftp.key -c chacha20-poly1305@openssh.com -o StrictHostKeyChecking=yes  mariyam@10.204.136.10:./