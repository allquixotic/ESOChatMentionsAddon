# ESO ChatMentions Addon

This addon can perform any of the following actions whenever your name (or part of your name, or any other custom string you wish) is typed in chat by a user: 

 - It can play a "ding" sound (the notification sound).
 - It can ALL CAPS your name.
 - It can change the color of your name.
 - It can add an exclamation point icon next to your name.
 - (If pChat is disabled) It can underline your name.
 
 IMPORTANT, PLEASE READ!! Version 2.0 and up **REQUIRES** that you **separately** install (via Minion, or downloading from esoui.com) the following libraries:
 - LibAddonMenu
 - LibStub
 - LibCustomMenu
 
 **Version 2.0 (June 2019)**: Added support to "Watch" the messages of a user, which will highlight messages sent by someone else whether or not they mention you! This can be enabled by right-clicking a name in the chat window, *or* by typing `/cmwatch` followed by the user's @handle. Note that you may need to use `/cmwatch Character Name` instead of @handle if the watched user is not your friend or in any of your guilds.
 
Version 2.0 also fixes the case (capital/lowercase) of mentioned words when you have the Capitalize option off. Now the original casing will be preserved.

Most of the configuration is documented by pressing `ESC`, go to `Settings`, `Addons`, then `ChatMentions`. Hover over configuration items for detailed usage details in a tooltip.

If you put an `!` (exclamation mark) in front of a custom name you'd like to monitor, it will only notify you if that name occurs on a "word boundary".
For example, if you add "!de" to your Extras list, you'd be notified for "de nada" but not "delicatessen". 
If you just added "de" to your Extras list, you'd be notified for "delicatessen" also.

However, there are three chat commands:

 - `/cmadd <name>` - Add `name` to the *temporary* list of extra names to ping on. This list is deleted when your client exits, when you type `/reloadui`, or possibly when you zone.
 - `/cmdel <name>` - Delete `name` from the *temporary* list of extra names to ping on. 
 - `/cmlist` - Print out the current list of names for which you will be pinged.
 
 This addon is also hosted on [esoui.com](https://www.esoui.com/downloads/info2248-ChatMentions.html) and can be downloaded through Minion by searching for "ChatMentions".
