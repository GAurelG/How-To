# Getting ebooks with DRM on other devices

on windows:
  - buy ebooks with drm
  - install the adobe digital edition tool on the computer
  - create an adobe account on the adobe website
  - verify your email!
    + if you don't get a verification email: log in your account, 
      got to your profile and under your email address you should have
      a possibility to send a confirmation email
  - once done, open the adobe digital edition software
  - add your adobeID credential and let the software log you in.
  - you might get into problems if your time is wrongly set (in case using linux and windows in dualboot)
  - then use the download button from your ebook provider, it should download a \*.acsm file.
  - open the .acsm file with the adobe digital edition, you can read the ebook there.

## to read the ebook on other devices:

  - install calibre the ebook manager
  - install the deDRM plugin
  - restart calibre
  - use the "addbooks" to add the book from the "my digital editions" situated in Documents.
  - Calibre will make a readable copy of the epub in it's library
  - you can synchronize the ebook with your personal reading device
  
## Process once the plugin is installed:

  - Buy the books online
  - download the *.acsm file
  - in windows, open the *.acsm file with adobe digital edition (right click on the file)
  - this will make it apear in the book library of adobe digital edition
  - you can right click on the books in the adobe digital edition bookshelf to open the file explorer to the place the encrypted ebooks are stored
  - use Calibre on windows (with the plugin installed):
    + click the "add books"
    + navigate to the place the encrypted ebooks from digital edition are
    + select the book you want to read in calibre
    + Calibre will import and remove the DRM automatically at import
    + you should be able to read the ebooks directly from calibre or any other reader now. if not, then something failed
    
## Synchronising with nextcloud:

  - You can point Calibre on linux and windows to a folder that will be synchronised using nextcloud.
  - You can also copy the books manually from the calibre library to the nextcloud folder you want
  - On your phone, in the nextcloud app, go to the book folder and use the three dots menu to "synchronize". This should download the files on the phone.
  - In the e-reader app, add the books.
    + go to the location:
    Android / media / com.nextcloud.client / nextcloud / USERNAME@NEXTCLOUD.ADDRESS / THE / NEXTCLOUD / FILE / PATH/
    + you should then be able to select the files of the books you want and import them in your e-reader
    
  
## tool:

github of the plugin:
https://github.com/apprenticeharper/DeDRM_tools/releases

  - download the latest release
  - unzip the archive you downloaded
  - in calibre go to "plugin" > "add plugin from file" find the location of the .zip file for the apropriate version of calibre
