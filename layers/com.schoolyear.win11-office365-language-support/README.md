# Microsoft Office for Windows 11 with language support

This layer configures a base layer for the image building process and the domains to whitelist in the proxy. The base layer already includes
Office. By doing this, it avoids a complete Office installation. The layer additionally also allows a user to select a different language than en-US for the Office apps. Optionally, the layer removes a Privacy first-run pop-up.

The layer only allows a small portion of the FQDNs used by Office, such that the online features such as file sync are not available.
Office activation is allowed to be performed over the network.

 Many thanks to Maarten Poell from Zuyd Hogeschool for his contributions.





