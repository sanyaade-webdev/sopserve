# SopServe

<http://github.com/jkp/sopserve>

An application to provide easy access to sopcast video streams.

[![Build Status](https://secure.travis-ci.org/jkp/sopserve.png)](http://travis-ci.org/jkp/sopserve)

# What does it do?

Provides an API for discovering available Sopcast streams for popular sporting events and proxies access to those streams for clients.  The intention is that this will be used as a backend for a plugin to a media center application such as [Plex](http://plexapp.com), allowing users to browse events and view streams with ease.

# Why did you write this?

Because I got tired of SSH'ing into my server, starting a Sopcast client and forwarding ports to access streams from my client boxes.  Not only that but I had to coninually bounce back and forward between a terminal and the browser when I needed to find alternative streams for whatever reason.

# How does it work?

SopServe implements a screen-scraper that is able to parse and extract information from the excellent http://livetv.ru site - it uses this to provide a programatically accessible directory of current upcoming and broadcasts.

Additionally it can optionally be configured to harness a linux machine with the Sopcast linux client installed to initiate and proxy Sopcast streaming sessions directly to the client.

# Is that all?

SopServe is a work in progress.  Right now it is suitable for using as the backend for a client to present the streams but eventually I'd like to add the ability to present those streams in a browser via an HTML5 video element.  This would enable easy viewing from whatever location you like, possibly including devices runnign iOS as well.

# License

Open Source MIT License.
