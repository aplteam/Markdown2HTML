# The user command `Markdown2HTML`


## Overview 

The `Markdown2HTML` user command allows you to convert one or more Markdown text files to HTML files with ease.

Strictly speaking `Markdown2HTML` comes with these things:

1. A user command script that makes the stuff in the workspace useable from the user command framework.

1. A folder `Markdown2HTML` that contains the following:

   1. A workspace with all the stuff that can actually convert a markdown text file into an HTML file.

     The reason why this is a workspace is that for the time being the user command framework makes it difficult to store scripts in the same place as the user commands, does not recommend a way to save them elsewhere and does not support sub folders.

     We can only get around this by storing the stuff in a workspace.

   1. Two CSS files ruling the layout of the HTML files to be created.


## Installing the user command


### Version 17.0

Under version 17.0 the recommended way of installing the user comnmand is to copy the script into the default folder for personal user commands which is `%HomePath\Documents\MyUCMDs`.

Note that `%HomePath%` defaults to `C:\Users\{yourName}\`. `{yourname}` is what `⎕AN` returns in an APL session.

Putting the user command into this folder has an advantage and a disadvantage:

Pro

: It works out of the box: just copy the stuff over, start an instance of Dyalog 17.0 and the user command is available.

Cons

: You have to do the same things for every user that's supposed to have the user command at their disposal.


### Older version than 17.0

Because of the restrictions of the user command framework you cannot install a user command like `Markdown2HTML` in the default folder `SALT\Spice`.

It is therefore necessary to save them elsewhere and add the path the the SALT path scanned for user commands. See the SALT documentation for details.

## Updates

The fact that `Markdown2HTML`'s functionality is in a workspace has a nasty side effect: when a new version of the MarkAPL class becomes available there is no other way to update it then to create a new version of `Markdown2HTML`.

This issue will be addressed as soon as the APL packet manager is available.