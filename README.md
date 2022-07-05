# mdeGranular

This is mdeGranular~, a real-time, multi-channel, multi-voice,
multi-transposition granular synthesis external for Max/MSP and PD.

mdeGranular's binaries get continously built through GitHub Actions.
You can find precompiled binaries readily available under this
repository's [Actions](../../actions)
tab. Just click on the latest 'workflow run' and you'll see the latest 
external objects listed under 'Artifacts'. NB **You have to be logged
in to github in order to access these**, so you'll need to make an account
first. There are also archives of these builds for each platform in the builds folder.

mdeGranular~.mxe64 = Max on Windows  
mdeGranular~.mxo = Max on Mac  
mdeGranular~.pd_linux = PD on Linux  
mdeGranular~.dll = PD on Windows  
mdeGranular~.pd_darwin = PD on Mac

Help files for both PD and MaxMSP may be found in the 'pd' or
'max' subdirectories respectively.

Documentation is on the [wiki](../../wiki).

## Compilation

Github actions should now take care of compilations (many thanks to the brilliant René-Maurice
Hanne for this!). However if you want to use XCode yourself on a Mac, keep reading.

To compile for MaxMSP on OSX you'll need XCode and the most recent 
[MaxSDK](https://cycling74.com/sdk/max-sdk-8.0.3/html/index.html).
There's a sample XCode project in the max folder. This was created for Max SDK
8.0.3 using XCode 11.3.1. It will not work directly as is, rather, you need to
put the xcode folder (containing mdegranular~.xcodeproj) into the MaxSDK folder
"source/audio" alongside the MaxMSP example projects. From there it should build
against the MaxMSP libraries.

NB this object is not yet working on Mac M1 computers.


Michael Edwards, March 9th 2020  
m@michael-edwards.org  
https://www.michael-edwards.org

