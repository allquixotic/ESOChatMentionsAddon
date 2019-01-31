# ESO ChatMentions Addon

This addon can perform any of the following actions whenever your name (or part of your name, or any other custom string you wish) is typed in chat by a user: 

 - It can play a "ding" sound (the notification sound).
 - It can ALL CAPS your name.
 - It can change the color of your name.
 - It can add an exclamation point icon next to your name.
 - (If pChat is disabled) It can underline your name.

Most of the configuration is documented by pressing `ESC`, go to `Settings`, `Addons`, then `ChatMentions`. Hover over configuration items for detailed usage details in a tooltip.

However, there are three chat commands:

 - `/cmadd <name>` - Add `name` to the *temporary* list of extra names to ping on. This list is deleted when your client exits, when you type `/reloadui`, or possibly when you zone.
 - `/cmdel <name>` - Delete `name` from the *temporary* list of extra names to ping on. 
 - `/cmlist` - Print out the current list of names for which you will be pinged.
 
 This addon is also hosted on [esoui.com](https://www.esoui.com/downloads/info2248-ChatMentions.html) and can be downloaded through Minion by searching for "ChatMentions".