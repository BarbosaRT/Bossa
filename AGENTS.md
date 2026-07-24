# FOR AGENTS

# Project Context
lib
- models (models the bussiness logic of the app)
- src (contains the src)
    - audio (handles the audio / playlist execution)
    - color (color themes and related things)
    - data (handle music data (songs, playlists, etc.))
        - youtube (handles the different song sources that get audio from yt (YoutubeExplode, Piped, Invidious))
    - file (handles files in different plataforms)
    - services (handle various services (downloads, etc.))
    - styles (styles for ui)
    - ui (contains the ui)
    - url (handles the part that get stuff from the internet)
- utils (contains utils)

test (mirrors lib/ and tests each part of the code)

Bossa is a music player made in flutter with the intent of being one that 
