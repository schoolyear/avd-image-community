# Microsoft Office for Windows 11

This properties-only layer configures a base layer for the image building process and the domains to whitelist in the proxy.
By using the Azure-provided default image, no Office installation needs to be performed during the image building process.
It includes functionality to, optionally, disable the "Why Privacy Matters" first run Office pop-up.

This layer only allows a small portion of the FQDNs used by Office, such that the online features such as file sync are not available.
Office activation is allowed to be performed over the network.