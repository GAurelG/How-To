# Use Virtual environment:

This is a test, complete when more used

## To create a virtual environment:

### create a directory:

For my own organization I would create the directory in `/home/aurelien/Python/Virtualenv/VIRTUALENV_FOLDER/`

### create a virutal environment:

1. Python 2:
    + need the module `virtualenv`
    + then on the directory already created: `virtualenv DIRECTORY_NAME`
2. Python 3:
    + already in the python standard library
    + `pyvenv DIRECTORY_NAME`

### Working in a Virtual environment:

- **Activate** the environment:
    
    `source DIRECTORY_NAME/bin/activate` 

    On windows use the `bin\activate.bat` and for other shell look at `bin/` content in the directory.

    Now we are working in the virtual environment 

- **Exit** the virtual environment:
    
    `deactivate`

### Loading modules:

***To-Do***

### Increase Productivity Idea?

- make alias to {source virtualenv}? for trivial virtualenv? (ipython...)
