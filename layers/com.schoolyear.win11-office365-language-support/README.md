# Microsoft Office for Windows 11 with language support

This properties-only layer configures a base layer for the image building process and the domains to whitelist in the proxy.
By using the Azure-provided default image, no Office installation needs to be performed during the image building process.

This layer only allows a small portion of the FQDNs used by Office, such that the online features such as file sync are not available.
Office activation is allowed to be performed over the network.

This layer also allows a user to select a different language than en-US. Many thanks to Maarten Poell from Zuyd Hogeschool for his contributions.

