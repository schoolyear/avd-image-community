# Microsoft Office for Windows 11 with language support

This layer configures a base layer for the image building process and the domains to whitelist in the proxy. The base layer already includes
Office. By doing this, it avoids a complete Office installation. The layer additionally also allows a user to (optionally) select a different language than en-US for the Office apps.
Also optionally, the layer removes a Privacy first-run pop-up.

The layer only allows a small portion of the FQDNs used by Office, such that the online features such as file sync are not available.
Office activation is allowed to be performed over the network.

Many thanks to Maarten Poell from Zuyd Hogeschool for his contributions.

Update September 2026:

New builds using this layer introduce a bug: students are regularly prompted for their log-in details when opening Office applications, instead of logging them in automatically as expected.
This bug is also present on VM's outside of Schoolyear. Please reach out to Microsoft if you need this to be resolved.
Note: When students close the Office application, and re-open it, they do not have to log-in and can continue the exam.
