# Microsoft Office for Windows 10

This properties-only layer configures a base layer for the image building process and the domains to whitelist in the proxy.
By using the Azure-provided default image, no Office installation needs to be performed during the image building process.

This layer only allows a small portion of the FQDNs used by Office, such that the online features such as file sync are not available.
Office activation is allowed to be performed over the network.

## 16 jan 2026 update

On the 16th of January 2026, Microsoft added an extra FQDN required for Office activation.
Without access to this domain, Office will show an activation error and block exam participants from using Office.

This FQDN is now added to the `properties.json5` in this layer, and we advise all customers using this layer to download this update for future image builds.
If you built your own custom Office layer based on this layer, we recommend updating that layer as well.

### Quick-fix

A change in a layer requires an image rebuild to take effect.
While we advise all users of this layer to perform such an image rebuild, there is a quick-fix available that takes effect immediately for all new exam deployments.

1. Find the `VM image version` resource that you are using for your Office exams in the Azure Portal.
   This resource will be in the Image Building resource group in your Subscription. The name of this resource group can be found in your AVD add-on, in the `Infrastructure` tab, as `Image Building Resource Group`.
   You can check in your AVD-addon, under `Apps`, which image definition and version you are currently using.
2. Go to the `Tags` of this VM image version resource and note down the value of the `SY_BUNDLE_URL` tag.
   It will point to a JSON file, hosted in an Azure storage account.
   The value will look like `https://<accountname>.blob.core.windows.net/resources/bundle-<name>-<date>.json`
3. Navigate to this storage account through the Azure Portal, go to `Containers > Resources`, and find the correct JSON file.
4. Click on that file and click `Edit`.
5. Find the line `"ols.officeapps.live.com:443"` and change it to `"ols.officeapps.live.com:443", "licensing.m365.svc.cloud.microsoft:443"`
6. Click `Save`
7. Verify your fix by deploying a new exam with your Office app, starting the exam as a student, and checking whether
   Office properly activates.
   