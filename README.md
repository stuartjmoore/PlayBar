I've found I don't have enough time to finish this project, yet I still use it everyday. Rather than let it die slowly, I'm open sourcing it, hoping it will find an audience.

# What is it?

![](https://raw.github.com/stuartjmoore/PlayBar/master/screenshot-closed.png)

PlayBar is a simple way to stream and queue MP3 files. It was designed for the purpose of listening to hour long podcasts without needed a separate window/dock icon (Quicktime) or having to add the files to any sort of database (iTunes).

You can download and open MP3s directly or drag a URL to the icon to have it stream directly. If a podcast is playing, PlayBar will queue the next one up.

Clicking the icon brings up the window, right-clicking brings up the menu, and middle-clicking pauses the episode.

# What's needed?

The design is a little lacking. It has some polish, but the text parsing is very, very poor. The title doesn't show up 50% of the time, and the playlist shows a confusing URL.

There is currently no save state. If you quit in the middle of an episode, you have to remember where you left off. Saving the timecode seems like it goes against the anti-database, but only episodes that are less than ~80% played need to be remembered.

![](https://raw.github.com/stuartjmoore/PlayBar/master/screenshot-open.png)