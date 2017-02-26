# CSM Scheduler Scraper
This is a series of utilities for scraping the CSM Scheduler website for commonly sought out tasks.

The scripts are a bit messy but they work. I think.

## Requirements

* [Coffeescript](http://coffeescript.org)
* [Node.js](https://nodejs.org)
* [Node Package Manger (NPM)](https://npmjs.com)

## Installation

1. Install requirements (listed above)
2. Clone the repo
3. Install requirements by running `npm install` from the repo directory

## User Guide

Run `coffee main.coffee` for a help message.

In general, the usage will follow the form `coffee main.coffee <utility_name> <arg1> <arg2> ...` with arguments as appropriate. 
The help message will offer a list of supported utilities and their expected arguments. 

The scripts typically will output things to a CSV of the user's choice. This is since we do most of our workflow via Google Docs 
and CSV's can be uploaded to Google Sheets very easily
