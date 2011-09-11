---
layout: post
title: Debugging Preference Panes
tags: [development, os x]
---

I wrote my first OS X Preference Pane during the development of **Authoritize**. Creating the skeleton project is, as usual, very straightforward and you can immediately try out your PrefPane by dropping it into the ~/Library/PreferencePanes folder and opening System Preferences. It will appear in the Other category at the bottom of the System Preferences window.

But if you have a problem and need to resort to stepping through your code in the debugger it is not immediately obvious how to do so. Of course, [Google knows](http://www.google.com/search?hl=en&client=safari&rls=en-us&q=debugging+prefpanes&btnG=Search), but it took much longer than it should have done for me to drill down to find the answer. So to save you one or two mouse clicks here is how to do it, create a new custom executable (Project->New Custom Executable) and select the System Preferences app as the executable path.

That’s it, Simple eh?