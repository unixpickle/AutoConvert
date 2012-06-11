The Big Idea
============

Ever wish that you could convert a file simply by changing its file extension? With AutoConvert, you can! After setting up various include/exclude path settings, a small daemon will continually run in the background on your computer, waking up only when a file is renamed to have a different extension. 

The ultimate goal of this project is to support every common file format: audio, images, videos, word processing files, and more.  In doing this, many 3rd party conversion APIs will be unified for the sake of a superior end-user experience.

Support for additional formats will be made possible through a simple plug-in architecture.  This architecture will make it super easy to expand the boundaries of your AutoConvert installation while preserving its unified and simplistic nature.

Progress
========

I (Alex Nichol) have completely finished implementing the basic backbone of this project: a file-system watcher, an abstract conversion class structure, a UI, and a plug-in interface.  All that is left now is the development of the plug-ins themselves.

I have written a simple plug-in for audio conversion called `BasicAudio`.  This plug-in compiles as part of the ACDaemon target; the ACDaemon target will even copy the compiled bundle to the product's `PlugIns` directory.  This plug-in shows off all of the basic features of AutoConvert: the progress indicator, live cancelling, support for various extensions in one plug-in, etc.

I have now implemented a plug-in which uses LAME to encode MP3 files, namely [BasicMP3](https://github.com/unixpickle/BasicMP3).  This plug-in comes pre-compiled as a bundle in the AutoConvert project; the source is not included in this repository for licensing reasons.  I still plan to implement a plug-in for FLAC encoding/decoding. However, I may do this down the road, since my top priority is currently video conversion.

For video conversion, my current plan is to encapsulate the ffmpeg library in order to transcode video across different formats and containers.  This plug-in will be rather massive, and may take a significant amount of time to be completed.  However, once this is complete, it will be easier than ever to convert between mkv, mov, m4v, mpg, avi, and many other video formats.

License
=======

This software is protected under the BSD license.

Copyright (c) 2012, Alex Nichol<br />
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
