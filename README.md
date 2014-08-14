grunt-polymer-atomshell-example
================================

Demo project/utility using grunt to build polymer + atom-shell apps

A demo custom element is provided in the example-element folder


more about polymer
-------------------
http://www.polymer-project.org/


more about atomshell
--------------------
https://github.com/atom/atom-shell




building a release
------------------
Various builds targets (browser, desktop, standalone or integration) are available ,
but it is advised to only build the specific version you require as some of these can
take a bit of time to generate.
The main point of this demo is , of course, building desktop apps ( you do not need atom-shell for
browser)

Once a build is complete, you will find the resulting files in the build/target-subtarget 
folder : for example:  **build/desktop-standalone** etc

To build a **standalone** app for usage on the desktop using the provided demo index.html

    $ grunt build:desktop:standalone

        
To build the example component for **integration** into a website:

    $ grunt build:browser:integration


optional build flags:
---------------------

 - --minify
 - --appname xxxx : where xxx is the name of the app you want (desktop only)
 - --compress : generated a zip file of the whole app folder (desktop only)

Notes:
------
 - tested on debian wheezey(mix of stable and unstable, yikes) 64 bit
 - in wheezy stable, there are issues with glibc, a mix of stable and unstable can help 
