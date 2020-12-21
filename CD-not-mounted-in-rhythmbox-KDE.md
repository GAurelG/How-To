# Explaination for CD not appearing in rhythmbox under KDE

Rhythmbox needs the CD to be mounted using gvfs. KDE doesn't do it by default. In order to do it the command is:

    ```
    gio mount cdda://sr0
    ```

