# Notes about mount.cifs

## Example
mount -t cifs //<server ip>/<mountpoint> /var/tmp/cifs -o user=<USER>,password=<PASSWORD>,domain=<DOMAIN> -o vers=2.0

## Man Pages
`BIG-IP 14.1.3` excerpt from `man mount.cifs`
`BIG-IP 13.1.3.4` does not list `vers` options in `man mount.cifs`
```
       vers=
           SMB protocol version. Allowed values are:

           ▒   1.0 - The classic CIFS/SMBv1 protocol. This is the default.

           ▒   2.0 - The SMBv2.002 protocol. This was initially introduced in Windows Vista Service Pack 1, and Windows Server 2008. Note that the initial release version of Windows Vista spoke a slightly different dialect (2.000)
               that is not supported.

           ▒   2.1 - The SMBv2.1 protocol that was introduced in Microsoft Windows 7 and Windows Server 2008R2.

           ▒   3.0 - The SMBv3.0 protocol that was introduced in Microsoft Windows 8 and Windows Server 2012.

           Note too that while this option governs the protocol version used, not all features of each version are available.
```
```
       vers=arg
              SMB protocol version. Allowed values are:

              • 1.0 - The classic CIFS/SMBv1 protocol.

              • 2.0 - The SMBv2.002 protocol. This was initially introduced in
                Windows Vista Service Pack 1, and Windows  Server  2008.  Note
                that  the  initial  release  version  of Windows Vista spoke a
                slightly different dialect (2.000) that is not supported.

              • 2.1 - The SMBv2.1 protocol that was  introduced  in  Microsoft
                Windows 7 and Windows Server 2008R2.

              • 3.0  -  The  SMBv3.0 protocol that was introduced in Microsoft
                Windows 8 and Windows Server 2012.

              • 3.1.1 or 3.11 - The SMBv3.1.1 protocol that was introduced  in
                Microsoft Windows Server 2016.

              Note  too  that  while  this option governs the protocol version
              used, not all features of each version are available.

              The default since v4.13.5 is for the client and server to  nego‐
              tiate the highest possible version greater than or equal to 2.1.
              In kernels prior to v4.13, the default was 1.0. For kernels  be‐
              tween v4.13 and v4.13.5 the default is 3.0.
```

```
       sec=arg
              Security mode. Allowed values are:

              • none - attempt to connection as a null user (no name)

              • krb5 - Use Kerberos version 5 authentication

              • krb5i - Use Kerberos authentication and forcibly enable packet
                signing

              • ntlm - Use NTLM password hashing

              • ntlmi - Use NTLM password hashing and force packet signing

              • ntlmv2 - Use NTLMv2 password hashing

              • ntlmv2i - Use NTLMv2 password hashing and force packet signing

              • ntlmssp  -  Use  NTLMv2  password  hashing encapsulated in Raw
                NTLMSSP message

              • ntlmsspi - Use NTLMv2 password  hashing  encapsulated  in  Raw
                NTLMSSP message, and force packet signing

              The  default  in  mainline  kernel  versions  prior  to v3.8 was
              sec=ntlm. In v3.8, the default was changed to sec=ntlmssp.
```