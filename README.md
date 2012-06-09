The Big Idea
============

Ever wished that you could convert a file simply by changing its file extension? With AutoConvert, you can! After setting up various include/exclude settings, a small daemon will continually run in the background on your computer, waking up only when a file is renamed to have a different extension. 

The ultimate goal for this project is to have support for all common file formats: audio, images, videos, text and word files, etc. Although tons of external APIs will be necessary to achieve this goal, the plan for this project is to unify many different conversion APIs to make a superior end-user experience.

Progress
========

I have just finished implementing the basic backbone of this project: a file-system watcher, an abstract conversion class structure, and even a UI for conversion itself.

Converters, as I call them, are units which are capable of converting between certain file formats to others. Soon, I will implement a plug-in infrastructure which will allow external converters to be added as bundles, needing not to be compiled as part of the `ACDaemon` executable. Once I get this plug-in infrastructure up and running, I will begin to implement more complex converters as bundles.

License
=======

License pending...