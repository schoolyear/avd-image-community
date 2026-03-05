# Language support for Windows 11

This layer adds language support for Windows 11. It allows you to select a Windows display language during the image building process.
When you do not use this layer, the default display language is en-US.
When you switch to a European language, this normally introduces an extra sign-in due to the Digital Market Act. This layer optionally removes this extra sign-in.

The layer uses the properties 'pre' customization step feature to add additional installation steps before the Schoolyear base layer.

Note: this layer adds 1 hour to the image building process. It also lengthens the sysprep phase to ~25 minutes.

Many thanks to Maarten Poell from Zuyd Hogeschool for his contributions.



